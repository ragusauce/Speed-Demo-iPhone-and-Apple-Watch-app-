//
//  InterfaceController.swift
//  Speed Demo WatchKit Extension
//
//  Created by Shane Ragusa on 6/28/17.
//  Copyright © 2017 Shane Ragusa. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation
import WatchConnectivity


class InterfaceController: WKInterfaceController, CLLocationManagerDelegate, WCSessionDelegate{
    
    @IBOutlet var speedLabel: WKInterfaceLabel!

    let locationManager:CLLocationManager = CLLocationManager()
    var watchManager:WCSession = WCSession.default()
    var updating = false;
    var watchSpeed: Double = 0.0
    var speedString: String = ""
    var locationTimer: Timer!
    @IBOutlet var button: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        
        super.awake(withContext: context)
        
        configureLocationServices()
        setUpWCSession()

    }
    
    override func willActivate() {

        super.willActivate()
   
    }
    
    override func didDeactivate() {

        super.didDeactivate()
    }
    
    
    @IBAction func startButton() {
        if (!updating){
            startReceivingLocationChanges()
            sendStatusToPhone(message: "Watch is tracking speed")
            button.setTitle("Stop")
        }
        else{
            stopReceivingLocationChanges()
            sendStatusToPhone(message: "Watch is currently not tracking speed")
            button.setTitle("Start")
        }
        
    }
    
    //Ensures location services are enabled on the device if possible
    func configureLocationServices(){
        
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus{
            
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            
            default: break
        }
    }
    
    //Starts collection data from location services
    func startReceivingLocationChanges(){
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways{
            configureLocationServices()
            return
        }
        
        if !CLLocationManager.locationServicesEnabled(){
            configureLocationServices()
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.delegate = self
        updating = true;
        
        locationTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(getCurrentLocation), userInfo: nil, repeats: true)
        
    }
    
    func getCurrentLocation(){
        locationManager.requestLocation()
    }
    
    //Stops collecting data from location services
    func stopReceivingLocationChanges(){
        locationManager.stopUpdatingLocation()
        locationTimer.invalidate()
        updating = false;
    }
    
    //Continuously updates the speed of the device
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
        watchSpeed = Double(round(1000*lastLocation.speed)/1000)
        
        speedString = "\(watchSpeed) m/sec"
        
        speedLabel.setText(speedString)
        
        sendSpeedToPhone(message: watchSpeed)
        
    }
    
    //Handles error with location services
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied{
            stopReceivingLocationChanges()
        }
        
    }
    
    //Configures and activates a WCSession
    func setUpWCSession(){
        watchManager.delegate = self
        watchManager.activate()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sendSpeedToPhone(message: Double){
        if(watchManager.isReachable){
            watchManager.sendMessage(["speed": message], replyHandler: nil, errorHandler: nil)
        }
    }
    
    func sendStatusToPhone(message: String){
        if(watchManager.isReachable){
            watchManager.sendMessage(["status": message], replyHandler: nil, errorHandler: nil)
        }
    }
    
    
    
    

    
}
