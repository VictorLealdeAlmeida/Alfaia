//
//  GameScene.swift
//  Alfaia
//
//  Created by Victor Leal Porto de Almeida Arruda on 09/07/16.
//  Copyright (c) 2016 Victor Leal Porto de Almeida Arruda. All rights reserved.
//

import UIKit
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
    
    var notesGenerated: [SKNode] = []
    
    var trackManager: TrackManager!
    var notesSequence: [Bool] = []
    var gesturesSequence: [UISwipeGestureRecognizerDirection] = []
    
    var isSequenceOver: Bool = false
    var activeNotes: Int = 0
    
    override func didMoveToView(view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        label = childNodeWithName("labelSKS") as! SKLabelNode
        label.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
       
        createCircle()
//        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(createNote),SKAction.waitForDuration(0.8)])))
        
        self.trackManager = TrackManager(level: SongLevel.LevelOne)
        self.getPattern()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bump))
        view.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(GameScene.controllerDidConnect(_:)),
            name: GCControllerDidConnectNotification,
            object: nil)
        
        if let controller = GCController.controllers().first {
            self.startMonitoringMotion(controller)
        }

    }
    
    func getPattern() {
        guard let newPattern = trackManager.nextBumpPattern() else {
            return
            // CHAMAR FUNÇÃO PRA TERMINAR FASE
        }
        self.notesSequence = newPattern["right"]!
        let action = SKAction.repeatAction(SKAction.sequence([SKAction.runBlock(createNote), SKAction.waitForDuration(0.7)]), count: self.notesSequence.count)
        runAction(SKAction.sequence([action,SKAction.runBlock(terminou)]))
    }
    
    func showGestureRecognition() {
        guard let newPattern = trackManager.nextGesturePattern() else {
            self.getPattern()
            return
        }
        self.gesturesSequence = newPattern
        self.showNextGesture()
    }
    
    func showNextGesture() {
        if self.gesturesSequence.count <= 0 {
            self.getPattern()
            return
        }
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.showNextGesture))
        swipe.direction = self.gesturesSequence.removeFirst()
        self.view?.addGestureRecognizer(swipe)
        switch swipe.direction {
        case UISwipeGestureRecognizerDirection.Up:
            self.label.text = "CIMA"
        case UISwipeGestureRecognizerDirection.Down:
            self.label.text = "BAIXO"
        case UISwipeGestureRecognizerDirection.Left:
            self.label.text = "ESQUERDA"
        case UISwipeGestureRecognizerDirection.Right:
            self.label.text = "DIREITA"
        default:
            self.label.text = "???"
        }
    }
    
    func recognizeSwipe() {
        
    }
    
    func terminou() {
        print("terminou")
        self.isSequenceOver = true
    }
    
    func createNote(){
        let showNote = self.notesSequence.removeFirst()
        
        var spriteName = "bola"
        if !showNote {
            spriteName = "bola-cinza"
            return
        }
        note = SKSpriteNode(imageNamed: spriteName)
        note.xScale = 0.00003*size.width
        note.yScale = 0.00003*size.width
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
        self.notesGenerated.append(note)
        self.activeNotes += 1
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
        self.addChild(circle)
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
        
        if (firstBody.categoryBitMask == PhysicsCategories.Note && secondBody.categoryBitMask == PhysicsCategories.Circle) {
            noteDidCollideWithCircleEnd(firstBody.node as! SKSpriteNode, circle: secondBody.node as! SKSpriteNode)
        }
        if self.isSequenceOver && self.activeNotes == 0 {
//            self.getPattern()
            self.showGestureRecognition()
        }
    }
    
    var selected = false
    func noteDidCollideWithCircle(note:SKSpriteNode, circle:SKSpriteNode){
        selected = true
    }
    
    func noteDidCollideWithCircleEnd(note:SKSpriteNode, circle:SKSpriteNode){
        selected = false
        if self.notesGenerated.count <= 0 {
            return
        }
        self.notesGenerated.removeFirst()
        self.activeNotes -= 1
    }
    
    func bump(){
        if self.notesGenerated.count <= 0 {
            return
        }
        let note = self.notesGenerated.removeFirst()
        if selected{
            //Transiçao
            note.physicsBody = nil
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Acertou"
            score = score + 10
            NSNotificationCenter.defaultCenter().postNotificationName("mudouScore", object: nil, userInfo: ["score": score])
            selected = false
        }else{
            note.physicsBody = nil
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Errou"
        }
        self.activeNotes -= 1
        if self.isSequenceOver && self.activeNotes == 0 {
//            self.getPattern()
            self.showGestureRecognition()
            self.isSequenceOver = false
        }
    }
    

    override func update(currentTime: CFTimeInterval) {
        
    }
    
    
}

// Movement Related Stuff
extension GameScene {
    func controllerDidConnect(notification: NSNotification) {
        let controller = GCController.controllers().first
        self.startMonitoringMotion(controller!)
    }
    
    func startMonitoringMotion(controller: GCController) {
        controller.motion?.valueChangedHandler = { (motion : GCMotion) -> () in
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
            
            self.bump()
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
