//
//  TasksTableViewController.swift
//  Tasker
//
//  Created by Joao Costa on 31/08/15.
//  Copyright (c) 2015 Joao Costa. All rights reserved.
//

import UIKit

class TasksTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The edit button will make the delete buttons on the left appear.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // Load any saved tasks if there are any.
        if let savedTasks = self.loadSavedTasks() {
            self.tasks = savedTasks
        }
        
        // Ask user permission to set notifications.
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deleteTask:", name: "deleteTask", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "snoozeTask:", name: "snoozeTask", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Number of sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // Number of rows.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }

    // Method run to render every row.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let task    = self.tasks[indexPath.row]
        
        if let description = task.taskDescription {
            let cell                        = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath)
            cell.textLabel?.text            = task.taskText
            cell.detailTextLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.text      = description
            return cell
        } else {
            let cell                        = tableView.dequeueReusableCellWithIdentifier("TaskTextCell", forIndexPath: indexPath)
            cell.textLabel?.text            = task.taskText
            cell.detailTextLabel?.text      = "No Description"
            return cell
        }
    }

    // Override to support conditional editing of the table view.
    // If this method does not return true it won't be possible to delete rows because of the segue
    // triggered when the user taps the 'UITableViewCell'.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Remove notification for the task.
            if let notification = self.tasks[indexPath.row].notification {
                UIApplication.sharedApplication().cancelLocalNotification(notification)
            }
            
            // Delete the row from the data source, the deletion from the data source must come first
            // or the app will crash.
            self.tasks.removeAtIndex(indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            // Update the tasks stored on disk.
            self.saveTasks()
        }   
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail" {
            let destinationViewController   = segue.destinationViewController as! TaskTableViewController
            let indexPath                   = self.tableView.indexPathForCell(sender as! UITableViewCell)
            
            // Set up the destination 'TaskViewController' task for editing.
            destinationViewController.task  = self.tasks[indexPath!.row]
        }
    }
    
    // This method is run every time the 'Save' button is pressed in 'TaskViewController'.
    @IBAction func unwindToTasksList (sender: UIStoryboardSegue) {
        if let sender = sender.sourceViewController as? TaskTableViewController, task = sender.task {
            
            if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                // Update an existing task.
                self.tasks[selectedIndexPath.row] = task
                self.tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
            }
            else  {
                // Add a new task.
                let newIndexPath = NSIndexPath(forRow: self.tasks.count, inSection: 0)
                self.tasks.append(task)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
            }
            
            // Save tasks whenever a task is created or updated.
            self.saveTasks()
        }
    }
    
    // MARK: NSCoding
    
    func saveTasks () {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(tasks, toFile: Task.ArchiveURL.path!)
        
        if !isSuccessfulSave { print("Failed to save tasks...") }
    }
    
    func loadSavedTasks () -> [Task]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(Task.ArchiveURL.path!) as? [Task]
    }
    
    // MARK: Notifications
    
    /**
        Delete the task associated with the given NSNotification.
    
        - parameter notification: Notification that triggers the task remotion.
    */
    func deleteTask (notification: NSNotification) {
        var taskToDelete: Task
        let taskTitle = notification.object as! String
        
        for task in self.tasks {
            if task.taskText == taskTitle {
                taskToDelete = task
                let taskIndex = self.tasks.indexOf(taskToDelete)
                self.tasks.removeAtIndex(taskIndex!)
                self.tableView.reloadData()
                saveTasks()
            }
        }
    }
    
    func printAMessage (notification: NSNotification) {
        print("Hello there!")
    }

}
