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
    @IBOutlet weak var progView: UIProgressView!
    var timeScore = NSTimer()
    var counter = 0
    var score = 0
    
    var time = 0.0
    var timer = NSTimer()
    
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
        
         // self.progView.transform = CGAffineTransformMakeRotation((CGFloat(M_PI/2)))
        
        self.progView.setProgress(10, animated: true)
        self.displayVideo()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector:#selector(GameViewController.setProgress), userInfo: nil, repeats: true)
    
    }
    
    func displayVideo() {
        let urlImg: NSURL = NSBundle.mainBundle().URLForResource("nuanda", withExtension: "gif")!
        let data: NSData = NSData(contentsOfURL: urlImg)!
        
//        let image = UIImage.animatedImageNamed("tutorial_01", duration: NSTimeInterval)
//        let imageView = UIImageView
        
        let image = FLAnimatedImage(animatedGIFData: data)
        image.frameCacheSizeMax = 20
        let imageView = FLAnimatedImageView()
        imageView.animatedImage = image
        imageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
//        let image = UIImage(named: "bola")
//        let imageView = UIImageView(image: image)
//        imageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
//        self.view.addSubview(imageView)
    }
    
    func setProgress() {
        time += 0.0018
        progView.progress = Float(time)
        if time >= 1 {
            timer.invalidate()
        }
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
        timeScore = NSTimer.scheduledTimerWithTimeInterval(0.005, target:self, selector: #selector(GameViewController.upLabelScore), userInfo: nil, repeats: true)
    }
    
    func upLabelScore(){
        if (counter > 0){
            score += 1
            counter -= 1
            self.labelStore.text = String(score)
        } else {
            timeScore.invalidate()
        }
    }
}
