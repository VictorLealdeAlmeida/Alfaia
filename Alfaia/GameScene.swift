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
    static let EmptyNote: UInt32 = 0b11
    static let Baque: UInt32 = 0b110
    static let Alfaia: UInt32 = 0b111

}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var note = SKSpriteNode(imageNamed: "")
    var left = SKSpriteNode()
    var galho = SKSpriteNode()
    var alfaia = SKSpriteNode()

    var timer = NSTimer()
    
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
        
        self.runAction(SKAction.playSoundFileNamed("luanda.mp3", waitForCompletion: false))
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVectorMake(0, 0)
        label = childNodeWithName("labelSKS") as! SKLabelNode
        label.position = CGPoint(x: size.width * 0.5, y: size.height * 0.6)
     //   let actionMove = SKAction.fadeAlphaTo(0, duration: 0.2)
     //   label.runAction(SKAction.sequence([actionMove]))

        
       
        self.createCircle()
        self.createBaquetas()
        self.createAlfaia()
        createBaquetasAux()
        
        NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector:#selector(getPattern), userInfo: nil, repeats: false)
        
        self.trackManager = TrackManager(level: SongLevel.LevelOne)
        
//        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(bump))
//        self.addGestureRecognizer(tap)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(GameScene.controllerDidConnect(_:)),
            name: GCControllerDidConnectNotification,
            object: nil)
        
        if let controller = GCController.controllers().first {
            self.startMonitoringMotion(controller)
        }
    }
    
    
    func createBaquetasAux() {
        galho = SKSpriteNode(imageNamed: "graveto")
        galho.setScale(0.3)
       // galho.zRotation = CGFloat(M_PI)
        galho.position = CGPoint(x: self.size.width * -0.12, y: self.size.height * 0.35)
        galho.anchorPoint = CGPoint(x:CGFloat(-0.7),y:CGFloat(0))
        
        addChild(galho)
        
    }
    
    func bump2(){
        let actionMove2 = SKAction.rotateToAngle(-0.4, duration: 0.25, shortestUnitArc: true)
        let actionMoveTwo2 = SKAction.rotateToAngle(0.25, duration: 0.25, shortestUnitArc: true)
        galho.runAction((SKAction.sequence([actionMove2, actionMoveTwo2])))
    }
    
    func bump(){
       // powerBump = 1
        
        let actionMove = SKAction.rotateToAngle(0.6, duration: 0.25, shortestUnitArc: true)
        let actionMoveTwo = SKAction.rotateToAngle(-0.25, duration: 0.25, shortestUnitArc: true)
        left.runAction((SKAction.sequence([actionMove, actionMoveTwo])))
        
        NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector:#selector(bump2), userInfo: nil, repeats: false)
        
        if self.notesGenerated.count <= 0 {
            return
        }
        let note = self.notesGenerated.removeFirst()
        if note.name == "EmptyNote" {
            return
        }
        if selected{
            //Transiçao
            note.physicsBody = nil
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Arretado!"
            score = score + 10
            NSNotificationCenter.defaultCenter().postNotificationName("mudouScore", object: nil, userInfo: ["score": score])
            selected = false
        }else{
            note.physicsBody = nil
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.25)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Vish!"
        }
        self.activeNotes -= 1
        if self.isSequenceOver && self.activeNotes == 0 {
            //            self.getPattern()
            self.showGestureRecognition()
            self.isSequenceOver = false
        }
    }
    
    
    
/*    var powerBump = 0
    func selectBump(){
        if powerBump == 0{
            let actionMove = SKAction.rotateToAngle(0.25, duration: 0.25, shortestUnitArc: true)
            let actionMoveTwo = SKAction.rotateToAngle(-0.25, duration: 0.25, shortestUnitArc: true)
            left.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMove, actionMoveTwo])))
        }else if powerBump == 1{
            let actionMove = SKAction.rotateToAngle(0.6, duration: 0.25, shortestUnitArc: true)
            let actionMoveTwo = SKAction.rotateToAngle(-0.25, duration: 0.25, shortestUnitArc: true)
            left.runAction(SKAction.repeatActionForever(SKAction.sequence([actionMove, actionMoveTwo])))
            powerBump = 0
        }
    }*/
    
    func createAlfaia(){
        alfaia = SKSpriteNode(imageNamed: "alfaia")
        alfaia.setScale(0.30)
        alfaia.position = CGPoint(x: self.size.width * 0.33, y: self.size.height * 0.22)
      //  alfaia.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: alfaia.frame.width, height:alfaia.frame.height/10), center: CGPointMake(0, 10))
       // alfaia.physicsBody?.categoryBitMask = PhysicsCategories.Alfaia
       // left.physicsBody?.collisionBitMask = PhysicsCategories.None
       // alfaia.physicsBody?.contactTestBitMask = PhysicsCategories.Baque
        addChild(alfaia)
    }
    
    func createBaquetas() {
        left = SKSpriteNode(imageNamed: "baqueta")
        left.setScale(0.4)
        left.position = CGPoint(x: self.size.width * 0.53, y: self.size.height * 0.45)
        left.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: left.frame.width/6, height: left.frame.height/2), center: CGPointMake(-left.frame.height * 4.2, 10))
        left.physicsBody?.categoryBitMask = PhysicsCategories.Baque
        left.physicsBody?.collisionBitMask = PhysicsCategories.None
        left.physicsBody?.contactTestBitMask = PhysicsCategories.Circle
        left.anchorPoint = CGPoint(x:CGFloat(1),y:CGFloat(0))
        
        addChild(left)
        
    }
    
    func shakeView(){
        let actionMove = SKAction.rotateToAngle(0.1, duration: 0.1, shortestUnitArc: true)
        let actionMoveTwo = SKAction.rotateToAngle(0, duration: 0.1, shortestUnitArc: true)
        let actionMoveFour = SKAction.rotateToAngle(-0.1, duration: 0.1, shortestUnitArc: true)
        alfaia.runAction(SKAction.sequence([actionMove, actionMoveTwo, actionMoveFour, actionMoveTwo]))

        
        
    }
    
    func getPattern() {
        guard let newPattern = trackManager.nextBumpPattern() else {
            return
            NSNotificationCenter.defaultCenter().postNotificationName("EndGame", object: nil)
        }
        self.notesSequence = newPattern["right"]!
        let action = SKAction.repeatAction(SKAction.sequence([SKAction.runBlock(createNote), SKAction.waitForDuration(0.9)]), count: self.notesSequence.count)
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
        
        let spriteName = showNote ? "baque" : "vazio"
        if showNote {
//            spriteName = "bola-cinza"
//            return
        }
        note = SKSpriteNode(imageNamed: spriteName)
        note.xScale = 0.0003*size.width
        note.yScale = 0.0003*size.width
        note.position = CGPoint(x: 0, y: size.height * 0.3)
        note.physicsBody = SKPhysicsBody(circleOfRadius: note.size.width/2)
        if showNote {
            note.physicsBody?.categoryBitMask = PhysicsCategories.Note
            note.physicsBody?.contactTestBitMask = PhysicsCategories.Circle
        } else {
            note.physicsBody?.categoryBitMask = PhysicsCategories.EmptyNote
            note.physicsBody?.contactTestBitMask = PhysicsCategories.None
            note.name = "EmptyNote"
        }
        
        note.physicsBody?.collisionBitMask = PhysicsCategories.None
        label.text = ""
        
        //Transiçao
        let actionMove = SKAction.moveToX(size.width + note.size.height, duration: 3)
        let actionMoveDone = SKAction.removeFromParent()
        note.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        addChild(note)
        self.notesGenerated.append(note)
        self.activeNotes += 1
    }
    
    func createCircle(){
        let circle = SKSpriteNode(imageNamed: "circ")
        circle.xScale = 0.00065*size.width
        circle.yScale = 0.00032*size.width
        circle.position = CGPoint(x: self.size.width * 0.23, y: self.size.height * 0.33)
        
        circle.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: circle.frame.width, height:circle.frame.height/3), center: CGPointMake(60, -40))
        circle.physicsBody?.categoryBitMask = PhysicsCategories.Circle
        circle.physicsBody?.collisionBitMask = PhysicsCategories.None
        circle.physicsBody?.contactTestBitMask = PhysicsCategories.Note | PhysicsCategories.Baque
        
        
        circle.alpha = 0
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
        
        if (firstBody.node?.name == "EmptyNote" || secondBody.node?.name == "EmptyNote") {
            return
        }else if(firstBody.categoryBitMask == PhysicsCategories.Note && secondBody.categoryBitMask == PhysicsCategories.Circle){
                noteDidCollideWithCircle(firstBody.node as! SKSpriteNode, circle: secondBody.node as! SKSpriteNode)
        }
        if(firstBody.categoryBitMask == PhysicsCategories.Baque && secondBody.categoryBitMask == PhysicsCategories.Circle){
            shakeView()
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
        
        if (firstBody.node?.name == "EmptyNote" || secondBody.node?.name == "EmptyNote") {
            selected = false
            return
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
        print("Ëntrou")
    }
    
    func noteDidCollideWithCircleEnd(note:SKSpriteNode, circle:SKSpriteNode){
        selected = false
        print("Saiu")

        if self.notesGenerated.count <= 0 {
            return
        }
        self.notesGenerated.removeFirst()
        self.activeNotes -= 1
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
