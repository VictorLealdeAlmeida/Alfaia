//
//  EndViewController.swift
//  Alfaia
//
//  Created by Bruno Barbosa on 7/10/16.
//  Copyright © 2016 Fade. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {

    @IBOutlet var pointsLbl: UILabel!
    var points: Int = 0
    
    var counter: Int = 0
    
    var timeScore: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        playLabelScore()
    }
    
    func playLabelScore(){
        timeScore = NSTimer.scheduledTimerWithTimeInterval(0.005, target:self, selector: #selector(GameViewController.upLabelScore), userInfo: nil, repeats: true)
    }
    
    func upLabelScore(){
        if (counter > 0){
            self.points += 1
            counter -= 1
            self.pointsLbl.text = String(self.points)
        } else {
            timeScore!.invalidate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restart(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
