//
//  GameScene.swift
//  Alfaia
//
//  Created by Victor Leal Porto de Almeida Arruda on 09/07/16.
//  Copyright (c) 2016 Victor Leal Porto de Almeida Arruda. All rights reserved.
//

import SpriteKit

struct PhysicsCategories{
    static let None: UInt32 = 0
    static let Note: UInt32 = 0b1 //1
    static let Circle: UInt32 = 0b10 //4
    static let xx: UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var note = SKSpriteNode(imageNamed: "")
    var noteActual = SKSpriteNode(imageNamed: "")
    var label = SKLabelNode()

    
    override func didMoveToView(view: SKView) {
        
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
        label.text = "--"
        
        //Transiçao
        let actionMove = SKAction.moveToX(size.width + note.size.width, duration: 3)
        let actionMoveDone = SKAction.removeFromParent()
        note.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
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
        print("Entrou")
        selected = true
    }
    
    func noteDidCollideWithCircleEnd(note:SKSpriteNode, circle:SKSpriteNode){
        print("Saiu")
        selected = false
    }
    
    func batida(){
        if selected{
            //Transiçao
            note.removeAllActions()
            let actionMove = SKAction.fadeAlphaTo(0, duration: 0.2)
            note.runAction(SKAction.sequence([actionMove]))
            label.text = "Acertou"
            selected = false
        }else{
            label.text = "Errou"
        }
        
    }
    

    override func update(currentTime: CFTimeInterval) {
        
    }
}
