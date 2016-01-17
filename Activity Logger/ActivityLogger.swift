//
//  ActivityLogger.swift
//  Activity Logger
//
//  Created by 1amageek on 2016/01/17.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//

import Foundation
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
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(__FUNCTION__)
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "inc.stamp.Activity_Logger" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Activity_Logger", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
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
