//
//  ViewController.swift
//  Speed Demo
//
//  Created by Shane Ragusa on 6/28/17.
//  Copyright © 2017 Shane Ragusa. All rights reserved.
//

import UIKit
import CoreLocation
import WatchConnectivity
import UserNotifications

class ViewController: UIViewController, WCSessionDelegate, UNUserNotificationCenterDelegate{
    
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    var watchManager: WCSession!
    
    var alertSpeed: Double = 10.0
    
    @IBOutlet weak var alertSpeedLabel: UILabel!
    
    @IBOutlet weak var alertSpeedSlider: UISlider!
    
    let center = UNUserNotificationCenter.current()
    
    var trigger = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(WCSession.isSupported()){
            watchManager = WCSession.default()
            watchManager.delegate = self
            watchManager.activate()
        }
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
        if(message.keys.contains("speed")){
            let speed = message["speed"] as! Double
            if(speed>alertSpeed && !trigger){
                sendSpeedAlert()
                trigger = true
            }
            
            else if(speed<alertSpeed){
                trigger = false
            }
            
            DispatchQueue.main.async {
                self.changeSpeedText(speed: speed)
            }
            
        }

        else if(message.keys.contains("status")){
            let status = message["status"] as! String
            DispatchQueue.main.async {
                self.changeStatusText(status: status)
            }

        }
    
    }
    
  
    
    func changeSpeedText(speed: Double){
        speedLabel.text = "\(speed) m/sec"
    }
    
    func changeStatusText(status: String){
        statusLabel.text = status
    }
    
    //Triggers an alert on the phone when the watch has a certain speed
    func sendSpeedAlert(){
        
        let content = UNMutableNotificationContent()
        
        
        content.title = "ALERT"
        content.body = "The watch's current speed is over \(alertSpeed) m/sec"
        content.sound = UNNotificationSound.default()
        content.setValue("YES", forKey: "shouldAlwaysAlertWhileAppIsForeground")

        let request = UNNotificationRequest(identifier: "any", content: content, trigger: nil)
        
        center.add(request, withCompletionHandler: nil )
    }
    
    
    //Triggered when the slider value is changed
    @IBAction func changeAlertSpeed(_ sender: Any) {
        alertSpeed = Double(round(1000*alertSpeedSlider.value)/1000)
        alertSpeedLabel.text = "Alert Speed: \(alertSpeed) m/sec"
    }
    
    
    
}

