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
//
// Deleagte:
// https://stackoverflow.com/questions/40126662/how-to-pass-data-from-modal-view-controller-back-when-dismissed
// by: Suhit Patil (https://stackoverflow.com/users/1570808/suhit-patil)

import UIKit

// for delegation purposes - stars a new game
protocol Restartable: class {
    func newGame(restart: Bool)
}

class ViewController: UIViewController, Restartable {

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
    
    let timer: Int = 30
    let numberOfRounds: Int = 6
    
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

        self.initialUI()
        self.newGame(restart: false)
        
        // Perhaps I can start the timer but I want separate the timer out of the VIEW trying to follow the MVC pattern
        // checks when label is == 0
        // Source
        // https://stackoverflow.com/questions/51292802/how-to-always-observe-the-text-of-label-and-change-color-in-swift-4
        timerLabelObserver = timerLabel.observe(\.text) { (lbl,ob) in
            if let text = lbl.text {
                if text == "0" {
                    self.game.timer.stop()
                    self.checkAnswer()
                }
            }
        }
    }
    
    // MARK: Segues passing information
    // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621490-prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let webViewController: WebViewController = segue.destination as! WebViewController
            
            if let url = sender as? String {
                webViewController.address = url
            }
        }
        
        if segue.identifier == "results" {
            if let scoreViewController: ScoreViewController = segue.destination as? ScoreViewController {
                if let score = sender as? Int {
                    scoreViewController.delegate = self
                    scoreViewController.score = "\(score)/\(numberOfRounds)"
                }
            }
        }
    }
    
    
    // MARK: Gesture recognizer
    
    // From: https://www.ioscreator.com/tutorials/detect-shake-gestures-ios-tutorial
    override func becomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.checkAnswer()
        }
    }
    
    
    // MARK: -
    // MARK: Game UI and Logic Methods
    
    /**
     Starts a new game or play again
    */
    func newGame(restart: Bool) {
        print("play again")
        
        // Disables the view detail buttons of each events.
        // these sits on top of the labels in the UI
        self.disableEventsBtns()
        
        // start a new round
        self.newRound()
        
        if restart == true {
            self.initialUI()
            self.game.totalRounds = self.numberOfRounds
        }
    }
    
    /**
     verifies if the events are in chronological order and displays the outcome
    */
    private func checkAnswer() {
        
        game.totalRounds -= 1
        self.game.timer.stop()
        
        // verifies if events are in the correct order
        let correctOrder = game.verifyAnswer()
        
        // play sound
        self.game.playSound(state: correctOrder)
    
        self.roundUI(order:correctOrder )
        self.enableEventsBtns()
    }
    
    
    /**
     - Sets a new round
    */
    private func newRound() {
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
    
    /**
     - Reorder the model array and switches labels text
    */
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
    
    
    /**
     play next round of the game
    */
    @IBAction func nextRoundPressed(_ sender: UIButton) {
        
        if game.totalRounds == 0 {
            performSegue(withIdentifier: "results", sender: game.score)
        } else {
            sender.isHidden = true
            self.initialUI()
            self.disableEventsBtns()
            self.newRound()
        }
    }
    
    /**
     Invokes perform segue to the WebViewController
    */
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
    // MARK: UI Methods
    
    fileprivate func initialUI() {
        timerLabel.text = ""
        timerLabel.isHidden = false
        
        nextRoundBtn.setTitle("", for: .normal)
        nextRoundBtn.isHidden = true
        
        infoLabel.text = "Shake to complete"
    }
    
    
    fileprivate func roundUI(order isCorrect: Bool) {
        
        if game.totalRounds == 0 {
            if isCorrect == true {
                /// display correct view results button
                if let bgImage: UIImage = UIImage(named: "view_results_success") {
                    nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
                }
            } else {
                /// display incorrect view results button
                if let bgImage: UIImage = UIImage(named: "view_results_fail") {
                    nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
                }
            }
        } else {
            if isCorrect == true {
                /// display correct
                if let bgImage: UIImage = UIImage(named: "next_round_success") {
                    nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
                }
            } else {
                /// display incorrect
                if let bgImage: UIImage = UIImage(named: "next_round_fail") {
                    nextRoundBtn.setBackgroundImage(bgImage, for: .normal)
                }
            }
        }
        
        timerLabel.text = ""
        timerLabel.isHidden = true
        
        nextRoundBtn.isHidden = false
        
        infoLabel.text = "Tap events to learn more"
    }
    
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
        // enables the swap buttons
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

