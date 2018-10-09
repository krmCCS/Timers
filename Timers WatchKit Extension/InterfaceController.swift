//
//  InterfaceController.swift
//  Timers WatchKit Extension
//
//  Created by Kevin R Mullen on 10/8/18.
//  Copyright © 2018 Kevin R Mullen. All rights reserved.
//

import WatchKit
import Foundation

enum clockState{
    
    case ACTIVE, STOPPED, RESET
}

enum clockCommand{
    
    case START, STOP, RESET
}

class InterfaceController: WKInterfaceController {
    
    var timerMasterClock = Timer()
    
    var timerAccumulator: Int = 0
    
    var dateStart: Date = Date()
    var dateStop: Date = Date()
    
    var dateDeactivated: Date = Date()
    var dateWillAppear: Date = Date()
    
    var timeInterval: TimeInterval = TimeInterval()
    
    var clockMainState: clockState = .RESET
    
    @IBOutlet weak var labelClock: WKInterfaceLabel!
    
    @IBOutlet weak var timerMainDisplay: WKInterfaceTimer!
    
    @IBOutlet weak var buttonStartStop: WKInterfaceButton!
    
    @IBAction func buttonStartStopPressed() {
        
        switch clockMainState {
            
        case .ACTIVE:
            //GO TO STOPPED
            timerMasterClockAction(.STOP)
            buttonStartStop.setTitle("START")
            buttonStartStop.setBackgroundColor(UIColor.darkGray)
            timerMainDisplay.stop()
            
            clockMainState = .STOPPED
            
        case .RESET:
            //GO TO ACTIVE
            timerMasterClockAction(.START)
            timerMainDisplay.setDate(Date()-TimeInterval(timerAccumulator))
            
            buttonStartStop.setTitle("PAUSE")
            buttonStartStop.setBackgroundColor(UIColor.orange)
            timerMainDisplay.start()
            
            clockMainState = .ACTIVE
            
            
        case .STOPPED:
            //GO TO ACTIVE
            timerMasterClockAction(.START)
            timerMainDisplay.setDate(Date()-TimeInterval(timerAccumulator))
            
            buttonStartStop.setTitle("PAUSE")
            buttonStartStop.setBackgroundColor(UIColor.orange)
            timerMainDisplay.start()
            clockMainState = .ACTIVE
            
        }
        
        
    }
    
    func timerMasterClockAction(_ command: clockCommand){
        
        switch command{
            
        case .RESET:
            if timerMasterClock.isValid {
                timerMasterClock.invalidate()
            }
        case .STOP:
            
            if timerMasterClock.isValid {
                timerMasterClock.invalidate()
            }
            
            
        case .START:
            
            if !timerMasterClock.isValid {
                
                DispatchQueue.main.async { [unowned self] in
                    self.timerMasterClock = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InterfaceController.timerAction), userInfo: nil, repeats: true)
                    
                }
            }
            
        }
        
    }
    
    var clockAlert = 5 + 1 // seconds
    
    @objc func timerAction(){
        timerAccumulator += 1
        labelClock.setText(String(timerAccumulator))
        if timerAccumulator >= Int(clockAlert){
            timerMainDisplay.setTextColor(UIColor.orange)
        }
    }
    
    @IBOutlet weak var buttonReset: WKInterfaceButton!
    
    @IBAction func buttonResetPressed() {
        
        timerMasterClockAction(.RESET)
        
        timerAccumulator = 0
        
        labelClock.setText(String(timerAccumulator))
        timerMainDisplay.setTextColor(UIColor.white)
        
        //        timerMasterClockAction(.STOP)
        buttonStartStop.setTitle("START")
        buttonStartStop.setBackgroundColor(UIColor.darkGray)
        timerMainDisplay.setDate(Date())
        timerMainDisplay.stop()
        
        clockMainState = .STOPPED
        
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        clockMainState = .RESET
        timerAccumulator = 0
        timerMainDisplay.setDate(Date()) // basically 0
        timerMainDisplay.stop()
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if clockMainState == .ACTIVE{
            
            
            dateWillAppear = Date()
            
            timerAccumulator += Int(dateWillAppear.timeIntervalSince(dateDeactivated))
            
            
            timerMainDisplay.setDate(Date()-TimeInterval(timerAccumulator))
            
            timerMasterClockAction(.START)
            
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        dateDeactivated = Date()
        timerMasterClockAction(.STOP)
        
    }
    
}
