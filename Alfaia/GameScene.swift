//
//  GameScene.swift
//  Alfaia
//
//  Created by Victor Leal Porto de Almeida Arruda on 09/07/16.
//  Copyright (c) 2016 Victor Leal Porto de Almeida Arruda. All rights reserved.
//

import SpriteKit
import GameController

struct PhysicsCategories{
    static let None: UInt32 = 0
    static let Note: UInt32 = 0b1 //1
    static let Circle: UInt32 = 0b10 //4
    static let xx: UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var note = SKSpriteNode(imageNamed: "")

    var label = SKLabelNode()
    var score = 0
    
    var lastTimeDetected: NSDate?
    
    override func didMoveToView(view: SKView) {
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(GameScene.controllerDidConnect(_:)),
            name: GCControllerDidConnectNotification,
            object: nil)
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        label = childNodeWithName("labelSKS") as! SKLabelNode
        label.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
       
        createCircle()
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(createNote),SKAction.waitForDuration(2)])))
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(batida))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)

    }
    
    func createNote(){
        note = SKSpriteNode(imageNamed: "bola")
        note.xScale = 0.00005*size.width
        note.yScale = 0.00005*size.width
        note.position = CGPoint(x: size.width * 0.0, y: size.height * 0.7)
        note.physicsBody = SKPhysicsBody(circleOfRadius: note.size.width/2)
        note.physicsBody?.categoryBitMask = PhysicsCategories.Note
        note.physicsBody?.collisionBitMask = PhysicsCategories.None
        note.physicsBody?.contactTestBitMask = PhysicsCategories.Circle
        label.text = ""
        
        //Transiçao
        let actionMove = SKAction.moveToX(size.width + note.size.width, duration: 3)
        let actionMoveDone = SKAction.removeFromParent()
        note.runAction(SKAction.sequence([actionMove, actionMoveDone]))
//        print(score)
        
        addChild(note)
    }
    
    func createCircle(){
        let circle = SKSpriteNode(imageNamed: "circ")
        circle.xScale = 0.00035*size.width
        circle.yScale = 0.00035*size.width
        circle.position = CGPoint(x: size.width * 0.5, y: size.height * 0.7)
        circle.physicsBody = SKPhysicsBody(circleOfRadius: note.size.width/2)
        circle.physicsBody?.categoryBitMask = PhysicsCategories.Circle
        circle.physicsBody?.collisionBitMask = PhysicsCategories.None
        circle.physicsBody?.contactTestBitMask = PhysicsCategories.Note
        addChild(circle)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if (contact.bodyA.node?.name > contact.bodyB.node?.name) {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else{
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if(firstBody.categoryBitMask == PhysicsCategories.Note && secondBody.categoryBitMask == PhysicsCategories.Circle){
                noteDidCollideWithCircle(firstBody.node as! SKSpriteNode, circle: secondBody.node as! SKSpriteNode)
        }
 
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if (contact.bodyA.node?.name > contact.bodyB.node?.name) {
            firstBody = contact.bodyA;
            secondBody = contact.bodyB;
        }
        else{
            firstBody = contact.bodyB;
            secondBody = contact.bodyA;
        }
        
        if(firstBody.categoryBitMask == PhysicsCategories.Note && secondBody.categoryBitMask == PhysicsCategories.Circle){
            noteDidCollideWithCircleEnd(firstBody.node as! SKSpriteNode, circle: secondBody.node as! SKSpriteNode)
        }
    }
    
    var selected = false
    func noteDidCollideWithCircle(note:SKSpriteNode, circle:SKSpriteNode){
        selected = true
    }
    
    func noteDidCollideWithCircleEnd(note:SKSpriteNode, circle:SKSpriteNode){
        selected = false
    }
    
    func batida(){
        if selected{
            //Transiçao
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Acertou"
            score = score + 10
            NSNotificationCenter.defaultCenter().postNotificationName("mudouScore", object: nil, userInfo: ["score": score])
            selected = false
        }else{
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Errou"
        }
        
    }
    

    override func update(currentTime: CFTimeInterval) {
        
    }
    
    func controllerDidConnect(note : NSNotification) {
        let controller = GCController.controllers().first
        controller?.motion?.valueChangedHandler = { (motion : GCMotion) -> () in
            self.checkBump(xValue: motion.userAcceleration.x, yValue: motion.userAcceleration.y, zValue: motion.userAcceleration.z, zGravity: motion.gravity.z)
            
        }
    }
    
    func checkBump(xValue xValue: Double, yValue: Double, zValue: Double, zGravity: Double) {
        if xValue < -1.5 && zValue < -1.5 {
            let currentTime = NSDate()
            if self.lastTimeDetected == nil {
                self.lastTimeDetected = currentTime
            } else if currentTime.timeIntervalSinceDate(self.lastTimeDetected!) < 0.3 {
                return
            }
            self.lastTimeDetected = currentTime
            print("Entrou")
            
            self.batida()
            print("BUMP")
//            print("x: \(xValue)     y: \(yValue)     z: \(zValue)     gravity: \(zGravity)")
            //            self.displayGestureLabel("Bump")
        } else if xValue < -1 && zValue < -1 {
            //            print("Not")
            //            print("x: \(xValue)     y: \(yValue)     z: \(zValue)     gravity: \(zGravity)")
        }
        //            print("x: \(xValue)     z: \(zValue)")
    }
    
    func checkHandsUp(xValue xValue: Double, yValue: Double, zValue: Double, zGravity: Double) {
        if xValue < -1 && yValue > 1 && yValue < 3 && zValue > 1.0 {
//            print("x: \(xValue)     y: \(yValue)     z: \(zValue)")
            //            self.displayGestureLabel("HandsUp")
        }
    }
    
    //    func displayGestureLabel(gestureName: String) {
    //        self.gestureLbl.text = gestureName
    //        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
    //        dispatch_after(delayTime, dispatch_get_main_queue()) {
    //            self.gestureLbl.text = "Nenhum gesto"
    //        }
    //    }
}
