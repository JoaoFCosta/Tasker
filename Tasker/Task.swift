//
//  Task.swift
//  Tasker
//
//  Created by Joao Costa on 31/08/15.
//  Copyright (c) 2015 Joao Costa. All rights reserved.
//

import UIKit

class Task: NSObject, NSCoding {
    
    // MARK: Properties
    
    var taskText:           String
    var taskDescription:    String?
    var notification:       UILocalNotification?
    
    // MARK: Archiving Paths
    
    static let DocumentsDirectory   = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL           = DocumentsDirectory.URLByAppendingPathComponent("tasks")
    
    // MARK: Types
    
    struct PropertyKey {
        static let taskKey          = "task"
        static let descriptionKey   = "description"
        static let notificationKey  = "notification"
    }
    
    // MARK: Initialization
    
    init? (task: String, description: String?, notification: UILocalNotification?) {
        self.taskText           = task
        self.taskDescription    = description
        self.notification       = notification
        
        // Needed to fix an error.
        super.init()
        
        if self.taskText.isEmpty { return nil }
    }
    
    private override init () {
        self.taskText           = ""
        self.taskDescription    = nil
        self.notification       = nil
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.taskText, forKey: PropertyKey.taskKey)
        aCoder.encodeObject(self.taskDescription, forKey: PropertyKey.descriptionKey)
        aCoder.encodeObject(self.notification, forKey: PropertyKey.notificationKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        
        self.taskText           = aDecoder.decodeObjectForKey(PropertyKey.taskKey) as! String
        self.taskDescription    = aDecoder.decodeObjectForKey(PropertyKey.descriptionKey) as! String?
        self.notification       = aDecoder.decodeObjectForKey(PropertyKey.notificationKey) as! UILocalNotification?
    }
}