//
//  Log+CoreDataProperties.swift
//  Activity Logger
//
//  Created by 1amageek on 2016/01/18.
//  Copyright © 2016年 Stamp inc. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Log {

    @NSManaged var timeStamp: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?

}
