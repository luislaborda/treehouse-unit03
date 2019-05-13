//
//  ViewController.swift
//  BoutTime
//
//  Created by Luis Laborda on 4/25/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var playingView: UIView!
    @IBOutlet weak var countdownView: UIView!
    
    @IBOutlet weak var eventLabel_1: UILabel!
    @IBOutlet weak var eventLabel_2: UILabel!
    @IBOutlet weak var eventLabel_3: UILabel!
    @IBOutlet weak var eventLabel_4: UILabel!
    @IBOutlet weak var event1Btn: UIButton!
    @IBOutlet weak var event2Btn: UIButton!
    @IBOutlet weak var event3Btn: UIButton!
    @IBOutlet weak var event4Btn: UIButton!
    @IBOutlet weak var nextRoundBtn: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    /// Game motherboard
    var game: BoutTimeGame
    
    // Monitors changes to the label
    var timerLabelObserver: NSKeyValueObservation?
    
    required init?(coder aDecoder: NSCoder) {
        // Initialization of the game's motherboard
        self.game = Game.init(timerInterval: 1.0, timerRepeat: true, timerSetTime: 10, totalRounds: 6)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disableBtns()

        // obtain list of events and show on each label
        game.obtainEventList()
        if let events = game.listOfEvents {
            eventLabel_1.text = events[0].event
            eventLabel_2.text = events[1].event
            eventLabel_3.text = events[2].event
            eventLabel_4.text = events[3].event
        }
        
        nextRoundBtn.isHidden = true
        
        // start the timer
        game.timer.start(countdownLbl: timerLabel)
        
        // checks when label is == 0
        timerLabelObserver = timerLabel.observe(\.text) { (lbl,ob) in
            if let text = lbl.text {
                if text == "0" {
                    self.checkAnswer()
                }
            }
        }
    }
    
    private func checkAnswer() {
        
        timerLabel.isHidden = true
        timerLabel.text = "-"
        nextRoundBtn.isHidden = false
        nextRoundBtn.titleLabel?.text = ""
        nextRoundBtn.contentMode = .scaleToFill
        
        let correctOrder = game.verifyAnswer()
        
        if correctOrder == true {
            /// display button correct
            if let bgImage: UIImage = UIImage(named: "next_round_success") {
                nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
                
            }
        } else {
            /// display button incorrect
            if let bgImage: UIImage = UIImage(named: "next_round_fail") {
                nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
            }
        }
    }
    
    @IBAction func swapListOfEvents(_ sender: UIButton) {
        
        guard let totalNumEvents = game.listOfEvents?.count else {
            return
        }
        
        /// index of the events array (0 - 3)
        var index:Int = totalNumEvents
        
        /// User selected label tag id
        var labelTagId: Int = 0
        
        /// Tag id of the label will swap text
        var swapLabelWithTagId: Int = 0
        var swapEventId:Int = 0
        
        /// Direction to sawp text
        var moveDirection: String = "down"
        
        switch sender.tag {
            case 1:
                labelTagId = 101
                index = 0
                moveDirection = "down"
            case 2:
                labelTagId = 102
                index = 1
                moveDirection = "up"
            case 3:
                labelTagId = 102
                index = 1
                moveDirection = "down"
            case 4:
                labelTagId = 103
                index = 2
                moveDirection = "up"
            case 5:
                labelTagId = 103
                index = 2
                moveDirection = "down"
            default:
                labelTagId = 104
                index = 3
                moveDirection = "up"
        }
        
        if moveDirection == "down" {
            swapLabelWithTagId = labelTagId + 1
            swapEventId = index + 1
        } else {
            swapLabelWithTagId = labelTagId - 1
            swapEventId = index - 1
        }
        
        if let userSelectedLabel = self.view.viewWithTag(labelTagId) as? UILabel,
            let nextLabel = self.view.viewWithTag(swapLabelWithTagId) as? UILabel {
                game.swapEvent(indexA: index, indexB: swapEventId, labelA: userSelectedLabel, labelB: nextLabel)
        }
    }
    
    fileprivate func flipButon(nextRound: Bool) {
        if nextRound == true {
            timerLabel.isHidden = true
            nextRoundBtn.isHidden = false
        } else {
            timerLabel.isHidden = false
            nextRoundBtn.isHidden = true
        }
    }
    
    fileprivate func disableBtns() {
        event1Btn.isEnabled = false
        event2Btn.isEnabled = false
        event3Btn.isEnabled = false
        event4Btn.isEnabled = false
    }
    
    fileprivate func enableBtns() {
        event1Btn.isEnabled = true
        event2Btn.isEnabled = true
        event3Btn.isEnabled = true
        event4Btn.isEnabled = true
    }
}

