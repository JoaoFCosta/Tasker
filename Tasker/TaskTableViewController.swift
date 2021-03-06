//
//  TaskTableViewController.swift
//  Tasker
//
//  Created by Joao Costa on 23/09/15.
//  Copyright © 2015 Joao Costa. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController, UITextFieldDelegate,
UITextViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var taskText:            UITextField!
    @IBOutlet weak var taskDescription:     UITextView!
    @IBOutlet weak var notificationSwitch:  UISwitch!
    @IBOutlet weak var notificationDate:    UIDatePicker!
    /*
    Task is either set by the 'TasksTableViewController' when editing a task,
    or is set by 'TaskViewController' when creating a new task, so that the new
    task is reachable by the 'TasksTablewViewContoller' when updating the list.
    */
    var task:                                   Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI Elements if the user is editing an existing task.
        if let task = task {
            self.taskText.text = task.taskText
            
            if let description = task.taskDescription {
                self.taskDescription.text       = description
            } else { self.taskDescription.text  = "" }
            
            if let notification = task.notification {
                self.notificationSwitch.on      = true
                self.notificationDate.date      = notification.fireDate!
            }
        }
        
        self.taskText.delegate                  = self
        self.taskDescription.delegate           = self
        
        self.setupNotificationSettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let text: String                        = self.taskText.text!
        let description: String?                = (self.taskDescription.text!.isEmpty) ? nil : self.taskDescription.text
        var notification: UILocalNotification?  = nil
        
        // Setup notification if the user whishes to be notified.
        if self.notificationSwitch.on {
            
            // Check if there was an already scheduled notification and
            // Check if current date is different from the older date and delete the old notification.
            if let notification = self.task?.notification where
                self.notificationDate.date != self.task?.notification?.fireDate {
                    UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            
            // Create a new notification.
            notification            = UILocalNotification()
            notification!.category  = "TASK_CATEGORY"
            notification!.alertBody = text
            notification!.fireDate  = self.notificationDate.date
            notification!.soundName = UILocalNotificationDefaultSoundName
            notification!.userInfo  = ["TaskTitle": text]
            
            // Schedule the notification.
            UIApplication.sharedApplication().scheduleLocalNotification(notification!)
        }
        else {
            // Check if there was a notification created already and delete it.
            if let notification = self.task?.notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
        }
        
        // Set the task to be passed to the 'TasksTableViewController' after the segue.
        print(notification?.userInfo as! [String: String])
        self.task       = Task(task: text, description: description, notification: notification)
    }
    
    @IBAction func cancel (sender: UIButton) {
        // Check if the user is adding a task, this can be done because the segue
        // for adding a meal must go trough a navigation controller first
        // and the editing segue doesn't.
        let isAddingTask = presentingViewController is UINavigationController
        
        if isAddingTask { dismissViewControllerAnimated(true, completion: nil) }
        else            { self.navigationController?.popViewControllerAnimated(true) }
        
    }
    
    // MARK: UITextFieldDelegate
    
    // Method run when 'return' key is pressed.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        self.taskText.resignFirstResponder()
        return true
    }
    
    // MARK: UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.taskDescription.resignFirstResponder()
        }
        return true
    }
    
    // MARK: UIDatePicker
    
    /* Verify if the specified date is not a past date */
    @IBAction func dateChanged(sender: UIDatePicker) {
        // Verify if a past date was specified and change it to the current hour.
        if sender.date.timeIntervalSinceNow < 0.0 {
            sender.date = NSDate(timeIntervalSinceNow: 0.0)
        }
        
    }
    
    /**
    Setup notification actions using UIMutableUserNotificationAction and UIMutableUserNotificationCategory.
    */
    func setupNotificationSettings () {
        // Setup Notifications.
        // Create notification actions.
        let doneAction                      = UIMutableUserNotificationAction()
        doneAction.identifier               = "DONE"
        doneAction.title                    = "Done"
        doneAction.activationMode           = UIUserNotificationActivationMode.Background
        doneAction.destructive              = true
        doneAction.authenticationRequired   = true
        
        let snoozeAction                    = UIMutableUserNotificationAction()
        snoozeAction.identifier             = "SNOOZE"
        snoozeAction.title                  = "Snooze"
        snoozeAction.activationMode         = UIUserNotificationActivationMode.Background
        snoozeAction.destructive            = false
        snoozeAction.authenticationRequired = false
        
        // Create notifications category.
        let taskCategory            = UIMutableUserNotificationCategory()
        taskCategory.identifier     = "TASK_CATEGORY"
        
        let defaultActions  = [doneAction, snoozeAction]
        let minimalActions  = [doneAction, snoozeAction]
        
        taskCategory.setActions(defaultActions, forContext: .Default)
        taskCategory.setActions(minimalActions, forContext: .Minimal)
        
        // Set of all categories.
        let categories = Set([taskCategory])
        
        // Register notification settings.
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge], categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
}
