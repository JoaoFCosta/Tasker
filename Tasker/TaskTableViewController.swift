//
//  TaskTableViewController.swift
//  Tasker
//
//  Created by Joao Costa on 23/09/15.
//  Copyright © 2015 Joao Costa. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let text: String                        = self.taskText.text!
        let description: String?                = (self.taskDescription.text!.isEmpty) ? nil : self.taskDescription.text
        var notification: UILocalNotification?  = nil
        
        // Setup notification if the user whishes to be notified.
        if self.notificationSwitch.on {
            // Check if there was an already scheduled notification and delete it.
            if let notification = self.task?.notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            
            notification = UILocalNotification()
            notification!.fireDate = self.notificationDate.date
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
    
    @IBAction func cancel (sender: UIButton) {
        // Check if the user is adding a task, this can be done because the segue
        // for adding a meal must go trough a navigation controller first
        // and the editing segue doesn't.
        let isAddingTask = presentingViewController is UINavigationController
        
        if isAddingTask { dismissViewControllerAnimated(true, completion: nil) }
        else            { self.navigationController?.popViewControllerAnimated(true) }

    }
}