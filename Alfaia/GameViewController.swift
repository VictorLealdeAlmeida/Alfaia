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

    @IBOutlet var skView: SKView!
    @IBOutlet weak var labelStore: UILabel!
    @IBOutlet weak var progView: UIProgressView!
    var timeScore = NSTimer()
    var counter = 0
    var score = 0
    
    var time = 0.0
    var timer = NSTimer()
    
    var bgView: FLAnimatedImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
       
//            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            skView.showsPhysics = false
            skView.allowsTransparency = true
            
        }
        
        let tapMenu = UITapGestureRecognizer(target: self, action: #selector(GameViewController.terminaCaralho))
        tapMenu.allowedPressTypes = [UIPressType.Menu.rawValue]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.updateScore),name: "mudouScore", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(GameViewController.endGame), name: "EndGame", object: nil)
        
         // self.progView.transform = CGAffineTransformMakeRotation((CGFloat(M_PI/2)))
        
        self.progView.setProgress(1, animated: true)
        self.displayVideo()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector:#selector(GameViewController.setProgress), userInfo: nil, repeats: true)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? EndViewController {
            vc.counter = sender as! Int
        }
    }
    
    func terminaCaralho() {
//        if let points = notification.userInfo!["points"] as? Int {
            self.performSegueWithIdentifier("endSegue", sender: 50)
//        }
    }
    
    func endGame(notification: NSNotification) {
        if let points = notification.userInfo!["points"] as? Int {
            self.performSegueWithIdentifier("endSegue", sender: points)
        }
    }
    
    func displayVideo() {
//        let texture = SKTexture(data: data, size: self.frame.size)
//        let background = SKSpriteNode(texture: texture)
//        background.zPosition = -1000
//        self.addChild(background)
        
        for i in 0...5 {
            let urlImg: NSURL = NSBundle.mainBundle().URLForResource("\(i)", withExtension: "gif")!
            let data: NSData = NSData(contentsOfURL: urlImg)!
            
            let image = FLAnimatedImage(animatedGIFData: data)
            image.frameCacheSizeMax = 20
            let imageView = FLAnimatedImageView()
            imageView.animatedImage = image
            imageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)

            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(10*i) * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if self.bgView == nil {
                    self.view.addSubview(imageView)
                    self.view.sendSubviewToBack(imageView)
                }
                self.bgView = imageView
            }
        }
        
        for i in 6...10 {
            let urlImg: NSURL = NSBundle.mainBundle().URLForResource("\(i%6)", withExtension: "gif")!
            let data: NSData = NSData(contentsOfURL: urlImg)!
            
            let image = FLAnimatedImage(animatedGIFData: data)
            image.frameCacheSizeMax = 20
            let imageView = FLAnimatedImageView()
            imageView.animatedImage = image
            imageView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
            
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(10*i) * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                if self.bgView == nil {
                    self.view.addSubview(imageView)
                    self.view.sendSubviewToBack(imageView)
                }
                self.bgView = imageView
            }
        }
    }
    
    func setProgress() {
        time += 0.0018
        progView.progress = Float(time/94)
        if time >= 94 {
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
