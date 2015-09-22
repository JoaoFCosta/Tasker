//
//  ViewController.swift
//  Tasker
//
//  Created by Joao Costa on 31/08/15.
//  Copyright (c) 2015 Joao Costa. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var taskTextField:           UITextField!
    @IBOutlet weak var descriptionTextField:    UITextField!
    @IBOutlet weak var datePicker:              UIDatePicker!
    @IBOutlet weak var alarmSwitch:             UISwitch!
    /*
    Task is either set by the 'TasksTableViewController' when editing a task,
    or is set by 'TaskViewController' when creating a new task, so that the new
    task is reachable by the 'TasksTablewViewContoller' when updating the list.
    */
    var task:                                   Task?
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Handle the text field's user input trough delegate callbacks.
        self.taskTextField.delegate         = self
        self.descriptionTextField.delegate  = self
        
        // Configure text fields if the user is editing an existing task.
        if let task = task {
            self.taskTextField.text         = task.taskText
            self.descriptionTextField.text  = (task.taskDescription != nil) ? task.taskDescription : ""
            
            // Check if theres a notification created.
            if let notification = self.task?.notification {
                self.datePicker.date    = notification.fireDate!
                self.alarmSwitch.on     = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UITextFieldDelegate
    
    // Called when the return key is pressed on the keyboard.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let text: String                        = self.taskTextField.text!
        let description: String?                = (self.descriptionTextField.text!.isEmpty) ? nil : self.descriptionTextField.text
        var notification: UILocalNotification?  = nil
        
        // Setup notification if the user whishes to be notified.
        if self.alarmSwitch.on {
            // Check if there was an already scheduled notification and delete it.
            if let notification = self.task?.notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            
            notification = UILocalNotification()
            notification!.fireDate = self.datePicker.date
            notification!.alertBody = self.task?.valueForKey("taskText") as? String
            notification!.alertAction = "Ok"
            notification!.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification!)
        }
        else {
            // Check if there was a notification created already and delete it.
            if let notification = self.task?.notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
        }
        
        // Set the task to be passed to the 'TasksTableViewController' after the segue.
        self.task       = Task(task: text, description: description, notification: notification)
    }
    
    // Go back to the root view controller when the 'Cancel' button is pressed.
    @IBAction func cancel (sender: UIButton) {
        // Check if the user is adding a task, this can be done because the segue
        // for adding a meal must go trough a navigation controller first
        // and the editing segue doesn't.
        let isAddingTask = presentingViewController is UINavigationController

        if isAddingTask { dismissViewControllerAnimated(true, completion: nil) }
        else            { self.navigationController?.popViewControllerAnimated(true) }
    }

}

