//
//  GameScene.swift
//  Room Shooter
//
//  Created by Bjarte Sjursen on 19.02.2016.
//  Copyright (c) 2016 Sjursen Software. All rights reserved.
//

import SpriteKit
import Darwin
import Foundation
import SocketIOClientSwift

class GameScene: SKScene, SKPhysicsContactDelegate {

    var players = [SKSpriteNode]();
    let player = SKSpriteNode(imageNamed:"Spaceship");
    var wPressed = false;
    var aPressed = false;
    var sPressed = false;
    var dPressed = false;
    let socket = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.113:3000")!, options: [.Log(false), .ForcePolling(true)]);
    let fire = SKEmitterNode(fileNamed: "Fire.sks");
    
    let spaceShipCategory : UInt32 = 0x1 << 0;
    let missileCategory : UInt32 = 0x1 << 1;
    
    override func didMoveToView(view: SKView) {
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame);
        self.physicsWorld.contactDelegate = self;
        
        socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        socket.on("addPlayer") {data, ack in
            
            var newPlayerX = CGFloat();
            var newPlayerY = CGFloat();
            var newPlayerZRotation = CGFloat();
            
            
            if let item = data[0] as? [String: AnyObject] {
                if let xLocation = item["xLocation"] as? CGFloat {
                    newPlayerX = xLocation;
                    print("\(xLocation)");
                }
                if let yLocation = item["yLocation"] as? CGFloat {
                    newPlayerY = yLocation;
                    print("\(yLocation)");
                }
                if let zRotation = item["zRotation"] as? CGFloat {
                    newPlayerZRotation = zRotation;
                    print("\(zRotation)");
                }
                
            }
            
            let newPlayer = SKSpriteNode(imageNamed: "Spaceship");
            newPlayer.position.x = newPlayerX;
            newPlayer.position.y = newPlayerY;
            newPlayer.zRotation = newPlayerZRotation;
            newPlayer.setScale(0.5);
            self.players.append(newPlayer);
            self.addChild(newPlayer);
            
        }
        
        socket.on("update") {data, ack in
            
            var newPlayerX = CGFloat();
            var newPlayerY = CGFloat();
            var newPlayerZRotation = CGFloat();
            
            
            if let item = data[0] as? [String: AnyObject] {
                if let xLocation = item["xLocation"] as? CGFloat {
                    newPlayerX = xLocation;
                    print("\(xLocation)");
                }
                if let yLocation = item["yLocation"] as? CGFloat {
                    newPlayerY = yLocation;
                    print("\(yLocation)");
                }
                if let zRotation = item["zRotation"] as? CGFloat {
                    newPlayerZRotation = zRotation;
                    print("\(zRotation)");
                }
            }
            if (!self.players.isEmpty){
                self.players[0].position.x = newPlayerX;
                self.players[0].position.y = newPlayerY;
                self.players[0].zRotation = newPlayerZRotation;
                self.players[0].setScale(0.5);
            }
            
        }
        
        socket.connect()
        
        let newPlayer = SKSpriteNode(imageNamed: "Spaceship");
        newPlayer.position.x = 500;
        newPlayer.position.y = 500;
        newPlayer.setScale(0.5);
        newPlayer.physicsBody = SKPhysicsBody(texture: newPlayer.texture!, size: newPlayer.size);
        newPlayer.physicsBody!.affectedByGravity = false;
        newPlayer.physicsBody!.categoryBitMask = spaceShipCategory;
        newPlayer.physicsBody!.collisionBitMask = missileCategory | spaceShipCategory;
        newPlayer.physicsBody!.contactTestBitMask = missileCategory | spaceShipCategory;
        self.players.append(newPlayer);
        self.addChild(newPlayer);

        
        player.position = CGPointMake(200, 200);
        player.setScale(0.2);
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size);
        player.physicsBody?.affectedByGravity = false;
        player.physicsBody!.categoryBitMask = spaceShipCategory;
        player.physicsBody!.collisionBitMask = missileCategory | spaceShipCategory;
        player.physicsBody!.contactTestBitMask = missileCategory | spaceShipCategory;
        
        self.addChild(player)

        fire?.setScale(2.0);
        fire!.position = CGPointMake(player.position.x-200, player.position.y-380);
        fire!.emissionAngle = player.zRotation-CGFloat(M_PI/2);
        fire!.particleSpeed = 0;
        player.addChild(fire!);

        self.backgroundColor = NSColor.blackColor();
        
    }
    
    override func mouseDown(theEvent: NSEvent) {

    }
    
    override func mouseDragged(theEvent: NSEvent) {
        
        let mousePosition = theEvent.locationInNode(self);
        let playerPosition = player.position;
        let deltaX = playerPosition.x - mousePosition.x;
        let deltaY = playerPosition.y - mousePosition.y;
        let rotationAngle = atan2(deltaY,deltaX)+CGFloat(M_PI/2);
        player.zRotation = rotationAngle;
        
    }
    
    func shoot(){
    
        let rocket = SKSpriteNode(imageNamed: "rocket.001.png");
        rocket.setScale(0.05);
        rocket.position.x = self.player.position.x + 50*cos(self.player.zRotation+CGFloat(M_PI/2));
        rocket.position.y = self.player.position.y + 50*sin(self.player.zRotation+CGFloat(M_PI/2));
        rocket.zRotation = self.player.zRotation;
        
        rocket.physicsBody = SKPhysicsBody(texture: rocket.texture!, size: rocket.size);
        rocket.physicsBody!.affectedByGravity = false;
        rocket.physicsBody!.categoryBitMask = missileCategory;
        rocket.physicsBody!.collisionBitMask = spaceShipCategory|missileCategory;
        rocket.physicsBody!.contactTestBitMask = spaceShipCategory|missileCategory;
        
        rocket.physicsBody?.velocity.dx = 4000*cos(rocket.zRotation+CGFloat(M_PI/2));
        rocket.physicsBody?.velocity.dy = 4000*sin(rocket.zRotation+CGFloat(M_PI/2));

        self.addChild(rocket);

        
    }
    
    func didBeginContact(contact: SKPhysicsContact){
        
        if((contact.bodyA.categoryBitMask == spaceShipCategory && contact.bodyB.categoryBitMask == missileCategory)||(contact.bodyB.categoryBitMask == spaceShipCategory && contact.bodyA.categoryBitMask == missileCategory)){
            
            let queue1 = dispatch_queue_create("firstQueue", nil);
            let explosion = SKEmitterNode(fileNamed: "Fire.sks");
            
            explosion?.emissionAngle = 0;
            explosion?.emissionAngleRange = CGFloat(2*M_PI);
            explosion?.particleBirthRate = 100;
            explosion?.particleLifetime = 2;
            explosion?.speed = 100;
            
            if (contact.bodyA.categoryBitMask == spaceShipCategory){
                
                let toExecute = {
                    explosion?.position = (contact.bodyA.node?.position)!;
                    contact.bodyA.node?.removeFromParent();
                    contact.bodyB.node?.removeFromParent();
                    self.addChild(explosion!);
                    self.runAction(SKAction.waitForDuration(1), completion: {
                        explosion!.speed = 0;
                        explosion!.particleBirthRate = 0;
                    })
                };
                
                dispatch_async(queue1, toExecute);
                
                
            }
            else if(contact.bodyB.categoryBitMask == spaceShipCategory){
                
                let toExecute = {
                
                    explosion?.position = (contact.bodyB.node?.position)!;
                    contact.bodyB.node?.removeFromParent();
                    contact.bodyA.node?.removeFromParent();
                    self.addChild(explosion!);
                    self.runAction(SKAction.waitForDuration(1), completion: {
                        explosion!.speed = 0;
                        explosion!.particleBirthRate = 0;
                    })
                    
                };
                
                dispatch_async(queue1, toExecute);
                
            }

        }
        
    }
    
    override func keyDown(theEvent: NSEvent) {
 
        switch(theEvent.characters!){
            case "w":
                fire!.particleSpeed = 100;
                wPressed=true;
                break;
            case "a":
                fire!.particleSpeed = 100;
                aPressed=true;
                break;
            case "s":
                fire!.particleSpeed = 100;
                sPressed=true;
                break;
            case "d":
                fire!.particleSpeed = 100;
                dPressed=true;
                break;
            case "":
                break;
            case " ":
                shoot();
                break;
            default:
                print("Other pressed");
                break;
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        switch(theEvent.characters!){
            case "w":
                fire!.particleSpeed = 0;
                wPressed=false;
                break;
            case "a":
                fire!.particleSpeed = 0;
                aPressed=false;
                break;
            case "s":
                fire!.particleSpeed = 0;
                sPressed=false;
                break;
            case "d":
                fire!.particleSpeed = 0;
                dPressed=false;
                break;
            case "":
                break;
            default:
                print("Other pressed");
                break;
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        
        var moveX = player.position.x;
        var moveY = player.position.y;
        
        if(wPressed==true){
            moveY+=20;
        }
        if(aPressed==true){
            moveX-=20;
        }
        if(sPressed==true){
            moveY-=20;
        }
        if(dPressed==true){
            moveX+=20;
        }
        
        self.socket.emit("update", ["xLocation": player.position.x, "yLocation":player.position.y, "zRotation":player.zRotation]);
        let movePlayer = SKAction.moveTo(CGPointMake(moveX, moveY), duration: 0.1);
        player.runAction(movePlayer);
        
    }
}
