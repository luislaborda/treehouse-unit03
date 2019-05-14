//
//  ViewController.swift
//  BoutTime
//
//  Created by Luis Laborda on 4/25/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//
// Resources:
// Gesture Recognizer:
// https://www.ioscreator.com/tutorials/detect-shake-gestures-ios-tutorial
//
// Segues:
// https://developer.apple.com/documentation/uikit/uiviewcontroller/1621490-prepare

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
    
    let timer: Int = 5
    let numberOfRounds: Int = 3
    
    /// Game motherboard
    var game: BoutTimeGame
    
    // Monitors changes to the label
    var timerLabelObserver: NSKeyValueObservation?
    
    required init?(coder aDecoder: NSCoder) {
        // Initialization of the game's motherboard
        self.game = Game.init(timerInterval: 1.0, timerRepeat: true, timerSetTime: timer, totalRounds: numberOfRounds)
        super.init(coder: aDecoder)
    }
    
    // MARK: -
    // MARK: Override Meethods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disables the buttons view details of each events.
        // these sits on top of the labels
        self.disableEventsBtns()
        
        self.game = Game.init(timerInterval: 1.0, timerRepeat: true, timerSetTime: 5, totalRounds: 6)
        
        self.newRound()
        nextRoundBtn.isHidden = true
        nextRoundBtn.titleLabel?.text = ""
        
        // 3. checks when label is == 0 (Not tought in class )
        timerLabelObserver = timerLabel.observe(\.text) { (lbl,ob) in
            if let text = lbl.text {
                if text == "0" {
                    self.checkAnswer()
                }
            }
        }
    }
    
    // MARK: Segues passing information
    // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621490-prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webViewController: WebViewController = segue.destination as! WebViewController
        
        if let url = sender as? String {
            webViewController.address = url
        }
    }
    
    // MARK: Gesture recognizer
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.checkAnswer()
        }
    }
    
    
    // MARK: -
    // MARK: Game UI Logic Methods

    private func checkAnswer() {
        
        // hides the time label
        timerLabel.isHidden = true
        timerLabel.text = ""
        
        // shows the result button
        nextRoundBtn.isHidden = false
        nextRoundBtn.titleLabel?.text = ""
        
        // verifies if events are in the correct order
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
        
        // info label
        infoLabel.text = "Tap events to learn more"
        enableEventsBtns()
        
        if game.totalRounds == 0 {
            // show score
            print("End of Game: \(game.score)")
        }
    }
    
    private func newRound() {
        if game.totalRounds == 0 {
            game.totalRounds = numberOfRounds
        }
        
        game.obtainEventList()
        if let events = game.listOfEvents {
            eventLabel_1.text = events[0].event
            eventLabel_2.text = events[1].event
            eventLabel_3.text = events[2].event
            eventLabel_4.text = events[3].event
        }
        
        game.timer.seconds = timer
        game.timer.start(countdownLbl: timerLabel)
    }
    
    // MARK: -
    // MARK: IBActions
    
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
    
    
    @IBAction func nextRoundPressed(_ sender: UIButton) {
        sender.isHidden = true
        timerLabel.isHidden = false
        timerLabel.text = ""
        infoLabel.text = "Shake to complete"
        disableEventsBtns()
        self.newRound()
    }
    
    @IBAction func showDetails(_ sender: UIButton) {
        var eventId: Int = 0
        switch sender.tag {
        case 201:
            eventId = 0
        case 202:
            eventId = 1
        case 203 :
            eventId = 2
        default:
            eventId = 3
        }
        
        if let eventURL = game.listOfEvents?[eventId].link {
            performSegue(withIdentifier: "showDetail", sender: eventURL)
        }
    }
    
    
    // MARK: -
    // MARK: UI Helper Methods

    fileprivate func disableEventsBtns() {
        // disables the swap events buttons
        for n in 1...6 {
            if let button = self.view.viewWithTag(n) as? UIButton {
                button.isEnabled = true
            }
        }
        event1Btn.isEnabled = false
        event2Btn.isEnabled = false
        event3Btn.isEnabled = false
        event4Btn.isEnabled = false
    }
    
    fileprivate func enableEventsBtns() {
         // enables the swap events buttons
        for n in 1...6 {
            if let button = self.view.viewWithTag(n) as? UIButton {
                button.isEnabled = false
            }
        }
        event1Btn.isEnabled = true
        event2Btn.isEnabled = true
        event3Btn.isEnabled = true
        event4Btn.isEnabled = true
    }
}

