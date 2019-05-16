//
//  BoutTimeGame.swift
//  BoutTime
//
//  Created by Luis Laborda on 4/30/19.
//  Copyright © 2019 Luis Laborda. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Enums
enum TimelineDataSourceError: Error {
    case invalidResource
    case conversionFailure
    case emptyData
}

enum PlistKeyName: String {
    case event
    case link
    case order
    case date
}



// MARK: - Protocols
protocol Event {
    var event: String { get set }
    var link: String { get set }
    var order: Int { get set }
}

protocol BoutTimeGame {
    var totalRounds: Int { get set }
    var score: Int { get set }
    var listOfEvents: [SingleEvent]? { get set }
    var timer: GameTimer { get }

    init(timerInterval: TimeInterval, timerRepeat:Bool, timerSetTime: Int, totalRounds: Int?)
    func obtainEventList()
    func swapEvent(indexA: Int, indexB: Int, labelA: UILabel, labelB: UILabel)
    func verifyAnswer() -> Bool
}

protocol Timeable {
    var timer: Timer? { get set }
    var defaultNumSeconds: Int { get }
    var interval: TimeInterval { get }
    var repeats: Bool { get }
    var seconds: Int { get set }
    var countdownLabel: UILabel? { get set }
    
    init(interval: TimeInterval, repeats: Bool, setTimer: Int?)
    
    func start(countdownLbl: UILabel)
    func stop()
    func update()
}



// MARK: - Structs
struct SingleEvent: Event {
    var event: String
    var link: String
    var order: Int
}



// MARK: - Classes
class PlistTimelineDataSource {
    
    /**
     Obtains all the data in the plist.
     
     - Parameters:
        - name: the name of the file.
        - type: typee of the file.
     
     - Throws:
         - `TimelieDataSourceError.invalidResource`
            if `path` doesn't exist
        - `TimelieDataSourceError.conversionFailure`
            if `data` is not an array
     
     - Returns: An array of AnyObject Class Type.
     */
    static func dictionary(fromFile name: String, ofType type: String) throws -> [AnyObject] {
        
        /// Path to the file
        guard let path = Bundle.main.path(forResource: name, ofType: type) else {
            throw TimelineDataSourceError.invalidResource
        }
        
        /// contents of the file
        guard let data = NSArray(contentsOfFile: path) as [AnyObject]? else {
            throw TimelineDataSourceError.conversionFailure
        }
        
        return data
    }
}



/// Obtain random Events from a datasource
class RandomEventGenerator {
    
    /**
     Selects n number of events at random from a datasource.
     
     - Parameter numberOfQuestions: total number of events to pick from datasource.
     - Parameter datasource: and array with all the event information.
     
     - Throws: `TimelieDataSourceError.emptyData`
                if `randomEventDict` doesn't contain any event
     
     - Returns: An array of single events.
     */
    static func pull(numberOfQuestions: Int, from datasource: [AnyObject]) throws -> [SingleEvent] {
        
        /// stores the selected events
        var questionnaire: [SingleEvent] = []
        
        /// name of the keys in the dictionary to avoid hard code which can lead to mistakes
        let eventKeyName: String = PlistKeyName.event.rawValue
        let orderKeyName: String = PlistKeyName.order.rawValue
        let linkKeyName: String = PlistKeyName.link.rawValue
        
        /// get random events
        var n = 0
        while n < numberOfQuestions {
            if let randomEventDict = datasource.randomElement(),
                let event = randomEventDict[eventKeyName] as? String,
                let order = randomEventDict[orderKeyName] as? Int,
                let link = randomEventDict[linkKeyName] as? String {

                let newItem = SingleEvent(event: event, link: link, order: order)
                
                // to avoid duplicate random selected events
                // https://developer.apple.com/documentation/swift/array/2297359-contains
                let containsEvent =  questionnaire.contains(where: { $0.order == order })
                
                if containsEvent == true {
                    continue
                }
                questionnaire.append(newItem)
                n += 1
            } else {
                throw TimelineDataSourceError.emptyData
            }
        }
        
        return questionnaire
    }
}

class GameTimer: Timeable {
    
    /// Timer
    var timer: Timer?
    
    /// default number od seconds
    var defaultNumSeconds: Int = 60
    
    /// Number of secods for each play, default to 60
    var seconds: Int {
        didSet {
            if seconds < 0 {
                timer?.invalidate()
            }
        }
    }
    
    /// interval in seconds
    var interval: TimeInterval
    
    /// repeat timer yes or no
    var repeats: Bool
    
    /// label to display the timer
    var countdownLabel: UILabel?
    
    required init(interval: TimeInterval, repeats: Bool = true, setTimer: Int? = 60) {
        self.interval = interval
        self.repeats = repeats
        
        if let newTime = setTimer {
            self.seconds = newTime
        } else {
            self.seconds = defaultNumSeconds
        }
    }
    
    public func start(countdownLbl: UILabel) {
        self.countdownLabel = countdownLbl
        timer = Timer.scheduledTimer(timeInterval: self.interval, target: self, selector: #selector(update), userInfo: nil, repeats: self.repeats)
    }
    
    public func stop() {
        self.timer?.invalidate()
    }
    
    @objc internal func update() {
        if let label = countdownLabel {
            label.text = "\(seconds)"
        }
        self.seconds -= 1
    }
}



/// Motherboard of the game
class Game: BoutTimeGame {
    
    let timelineDataSource: String = "TimelineDataSource"
    let plist: String = "plist"
    
    /// total number of rounds per game
    var totalRounds: Int = 6
    
    /// keeps track of the score
    var score: Int = 0
    
    /// an array that contains single events
    var listOfEvents: [SingleEvent]?
    
    /// countdown
    var timer: GameTimer
    
    /**
     Initializes a new game with the necessary questions and the number of rounds per game
     
     - Parameters:
        - totalRounds: (not required) in case you want to change the number of rounds
     
     - Returns: A brand new game
     */
    required init(timerInterval: TimeInterval, timerRepeat:Bool, timerSetTime: Int, totalRounds: Int?) {
        /// set total number of rounds per game
        if let rounds = totalRounds {
            self.totalRounds = rounds
        }
        
        /// sets the timer
        self.timer = GameTimer.init(interval: timerInterval, repeats: timerRepeat, setTimer: timerSetTime)
    }
    
    /**
     Obtains a new set of events
     
     - Parameters: nil
     
     - Returns: nil
     */
    public func obtainEventList() {
        do {
            let data = try PlistTimelineDataSource.dictionary(fromFile: timelineDataSource, ofType: plist)
            let events = try RandomEventGenerator.pull(numberOfQuestions: 4, from: data)
            
            self.listOfEvents = events
        } catch let error {
            fatalError("\(error)")
        }
    }
    
    
    public func swapEvent(indexA: Int, indexB: Int, labelA: UILabel, labelB: UILabel) {
        
        guard let _ = self.listOfEvents else {
            return
        }
        
        self.listOfEvents!.swapAt(indexA, indexB)
        labelA.text = self.listOfEvents![indexA].event
        labelB.text = self.listOfEvents![indexB].event
        
    }
    
    /**
     checks if the events are in chronological order
     
     - Parameters: nil
     
     - Returns: Bool
            - true: they are in the correct chronological order
            - false: they are NOT in the correct chronological order
     */
    public func verifyAnswer() -> Bool {
        var correctAns: Bool = false
        
        if let events = listOfEvents {
            if (events[0].order < events[1].order) && (events[1].order < events[2].order) && (events[2].order < events[3].order) {
                score += 1
                correctAns = true
            }
        }
        
        return correctAns
    }

}
