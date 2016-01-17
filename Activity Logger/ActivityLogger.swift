//
//  ActivityLogger.swift
//  Activity Logger
//
//  Created by 1amageek on 2016/01/17.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class ActivityLogger: NSObject, CLLocationManagerDelegate {
    
    static let sharedLogger: ActivityLogger = {
        let logger = ActivityLogger()
        // setup
        
        return logger
    }()
    
    override init() {
        super.init()
        self.start()
    }
    
    func start() {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()        
        switch status {
        case .AuthorizedAlways:
            // 常に許可
            self.locationManager.startMonitoringSignificantLocationChanges()
            break
        case .Denied:
            // 拒否されている
            break
        case .NotDetermined:
            // 選択されていない
            self.locationManager.requestAlwaysAuthorization()
            break
        case .Restricted:
            // 使用制限されている
            break
        case .AuthorizedWhenInUse:
            // 使用中のみ許可
            //self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
            break
        }
    }
    
    func stop() {
        //self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    private(set) lazy var locationManager: CLLocationManager = {
       var locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(__FUNCTION__)
        if status == .AuthorizedAlways {
            //self.locationManager.startUpdatingLocation()
            self.locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(__FUNCTION__)
        let location: CLLocation = locations.last!
        let locationLog: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: self.managedObjectContext) as! Log
        locationLog.timeStamp = NSDate()
        locationLog.latitude = location.coordinate.latitude
        locationLog.longitude = location.coordinate.longitude
        
        self.saveContext()
        
        
        let localNotification: UILocalNotification = UILocalNotification()
        localNotification.fireDate = NSDate()
        localNotification.alertTitle = "Activity Log"
        localNotification.alertBody = location.description
        localNotification.alertAction = "OK"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(__FUNCTION__)
    }
    
    var managedObjectContext: NSManagedObjectContext!
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}
