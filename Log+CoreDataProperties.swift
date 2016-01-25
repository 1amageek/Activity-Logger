//
//  Log+CoreDataProperties.swift
//  Activity Logger
//
//  Created by 1amageek on 2016/01/24.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Log {

    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var timeStamp: NSDate?
    @NSManaged var confidence: String?
    @NSManaged var stationary: NSNumber?
    @NSManaged var walking: NSNumber?
    @NSManaged var running: NSNumber?
    @NSManaged var automotive: NSNumber?
    @NSManaged var unknown: NSNumber?

}
