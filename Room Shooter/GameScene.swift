//
//  GameScene.swift
//  Room Shooter
//
//  Created by Bjarte Sjursen on 19.02.2016.
//  Copyright (c) 2016 Sjursen Software. All rights reserved.
//s

import SpriteKit
import Darwin
import Foundation
import SocketIOClientSwift

class GameScene: SKScene {

    var player = SKSpriteNode();
    var wPressed = false;
    var aPressed = false;
    var sPressed = false;
    var dPressed = false;
    let socket = SocketIOClient(socketURL: NSURL(string: "http://192.168.1.113:3000")!, options: [.Log(false), .ForcePolling(true)])
    
    override func didMoveToView(view: SKView) {
        
        player.position = CGPointMake(200, 200)
        
        socket.on("connect") {data, ack in
            print("got connected");
            //self.socket.emit("addPlayer", ["xLocation": self.player.position.x, "yLocation": self.player.position.y, "orientation":self.player.zRotation]);
        }
        
        
        socket.on("currentAmount") {data, ack in
            if let cur = data[0] as? Double {
                self.socket.emitWithAck("canUpdate", cur)(timeoutAfter: 0) {data in
                    self.socket.emit("update", ["amount": cur + 2.50])
                }
                
                ack.with("Got your currentAmount", "dude")
            }
        }
        
        socket.on("addPlayer") {data, ack in
            
            print("\(data)");
            
            //self.player = SKSpriteNode(imageNamed:"Spaceship");
            
        }
        
        socket.connect()
        
        player.setScale(0.5)
        
        self.addChild(player)
        
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
    
    override func keyDown(theEvent: NSEvent) {
 
        switch(theEvent.characters!){
            case "w":
                wPressed=true;
                break;
            case "a":
                aPressed=true;
                break;
            case "s":
                sPressed=true;
                break;
            case "d":
                dPressed=true;
                break;
            case "":
                break;
            default:
                print("Other pressed");
                break;
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        
        switch(theEvent.characters!){
            case "w":
                wPressed=false;
                break;
            case "a":
                aPressed=false;
                break;
            case "s":
                sPressed=false;
                break;
            case "d":
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
        //self.socket.emit("update", ["xLocation": player.position.x, "yLocation":player.position.y, "orientation":player.zRotation]);
        let movePlayer = SKAction.moveTo(CGPointMake(moveX, moveY), duration: 0.1);
        player.runAction(movePlayer);

        
    }
}
