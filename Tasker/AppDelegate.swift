//
//  AppDelegate.swift
//  Tasker
//
//  Created by Joao Costa on 31/08/15.
//  Copyright (c) 2015 Joao Costa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        print(notificationSettings.types.rawValue)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Received Local Notification:\n")
        print(notification.alertBody)
    }
    
    /* Method run when the user selects to execute an action from a notification. */
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        // Done action selected, delete the task.
        if identifier == "DONE" {
            NSNotificationCenter.defaultCenter().postNotificationName("deleteTask", object: notification.userInfo!.first!.1 as! String)
        }
        // Snooze action selected, snooze the notification.
        else if identifier == "SNOOZE" {
            NSNotificationCenter.defaultCenter().postNotificationName("snoozeTask", object: notification.userInfo!.first!.1 as! String)
        }
        
        // Call the completion handler to alert iOS everything worked fine.
        completionHandler()
    }
}