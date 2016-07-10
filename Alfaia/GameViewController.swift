//
//  GameViewController.swift
//  Alfaia
//
//  Created by Victor Leal Porto de Almeida Arruda on 09/07/16.
//  Copyright (c) 2016 Victor Leal Porto de Almeida Arruda. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    @IBOutlet weak var labelStore: UILabel!
    var time = NSTimer()
    var counter = 0
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
       
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            skView.showsPhysics = true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,selector: #selector(GameViewController.updateScore),name: "mudouScore", object: nil)

    }
    
    func updateScore(notification: NSNotification) {
        let newScore = notification.userInfo!["score"] as! Int
        counter = newScore - score
        print(score)
        playLabelScore()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    //Fazer efeito legal na label do score
    func playLabelScore(){
        time = NSTimer.scheduledTimerWithTimeInterval(0.005, target:self, selector: #selector(GameViewController.upLabelScore), userInfo: nil, repeats: true)
    }
    
    func clearLabelScore(){
        counter = 0
        time.invalidate()
    }
    
    func upLabelScore(){
        if (counter > 0){
            score += 1
            counter -= 1
            self.labelStore.text = String(score)
        } else {
            time.invalidate()
        }
    }
}
