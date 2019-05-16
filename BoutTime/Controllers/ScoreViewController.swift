//
//  ScoreViewController.swift
//  BoutTime
//
//  Created by Luis Laborda on 5/15/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    var delegate: Restartable?
    
    var score: String?
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let totalScore = score {
           scoreLabel.text = totalScore
        } else {
            scoreLabel.text = ""
        }
        
    }

    @IBAction func playAgain(_ sender: UIButton) {
        delegate?.newGame(restart: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
