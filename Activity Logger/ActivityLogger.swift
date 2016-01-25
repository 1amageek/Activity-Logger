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
import CoreMotion
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
        self.startUpdatingLocation()
    }
    
    func stop() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    
    func startUpdatingLocation() {
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
            self.locationManager.startMonitoringSignificantLocationChanges()
            break
        }
    }
    
    /*
    func startUpdatingActivity() {
        if CMMotionActivityManager.isActivityAvailable() {
            let mainQueue: NSOperationQueue = NSOperationQueue.mainQueue()
            self.motionActivityManager.startActivityUpdatesToQueue(mainQueue, withHandler: { (motionActivity: CMMotionActivity?) -> Void in
                let log: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: self.managedObjectContext) as! Log
                log.timeStamp = NSDate()
                
                if motionActivity?.confidence == CMMotionActivityConfidence.High {
                    log.confidence = "High"
                } else if motionActivity?.confidence == CMMotionActivityConfidence.Medium {
                    log.confidence = "Medium"
                } else {
                    log.confidence = "Low"
                }
                
                log.automotive = NSNumber(bool: (motionActivity?.automotive)!)
                log.unknown = NSNumber(bool: (motionActivity?.unknown)!)
                log.walking = NSNumber(bool: (motionActivity?.walking)!)
                log.stationary = NSNumber(bool: (motionActivity?.stationary)!)
                log.running = NSNumber(bool: (motionActivity?.running)!)

                //self.saveContext()
                
                print(motionActivity)
                
            })
        }
    }
    */
    
    
    private(set) lazy var locationManager: CLLocationManager = {
        var locationManager = CLLocationManager()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        return locationManager
    }()
    
    private(set) lazy var motionActivityManager: CMMotionActivityManager = {
        var motionActivityManager = CMMotionActivityManager()
        return motionActivityManager
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
        
        let tmpContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        tmpContext.parentContext = self.managedObjectContext
        
        tmpContext.performBlock { () -> Void in
            
            let toDate = NSDate()
            let fetchRequest = NSFetchRequest(entityName: "Log")
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
            //fetchRequest.predicate = NSPredicate(format: "timeStamp = %@", NSDate())
            fetchRequest.fetchLimit = 1
            fetchRequest.sortDescriptors = [sortDescriptor]
            do {
                
                let logs: [Log] = try tmpContext.executeFetchRequest(fetchRequest) as! [Log]
                
                if let lastLog: Log = logs.last {
                    
                    let mainQueue = NSOperationQueue.mainQueue()
                    let handler: CMMotionActivityQueryHandler = { motionActivities, error in
                        
                        guard let motionActivities = motionActivities else {
                            return
                        }
                        
                        var moved: Bool = false
                        for (_, motionActivity) in (motionActivities.enumerate()) {
                            // 移動したことを確認
                            if motionActivity.running || motionActivity.walking || motionActivity.cycling || motionActivity.automotive {
                                print(motionActivity)
                                moved = true
                            }
                        }
                        
                        if moved {
                            print("Moved")
                            let location: CLLocation = locations.last!
                            let locationLog: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: self.managedObjectContext) as! Log
                            locationLog.timeStamp = NSDate()
                            locationLog.latitude = location.coordinate.latitude
                            locationLog.longitude = location.coordinate.longitude
                            self.saveContext()
                        }
                        
                    }
                    
                    self.motionActivityManager.queryActivityStartingFromDate(lastLog.timeStamp!, toDate: toDate, toQueue: mainQueue, withHandler: handler)
                }
                
                else {
                    let location: CLLocation = locations.last!
                    let locationLog: Log = NSEntityDescription.insertNewObjectForEntityForName("Log", inManagedObjectContext: self.managedObjectContext) as! Log
                    locationLog.timeStamp = NSDate()
                    locationLog.latitude = location.coordinate.latitude
                    locationLog.longitude = location.coordinate.longitude
                    self.saveContext()
                }
              
            } catch {
                
            }
        }
    
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
