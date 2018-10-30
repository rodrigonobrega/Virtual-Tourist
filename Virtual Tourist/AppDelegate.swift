//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 02/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var showErrorDescription:Bool = true
    private static let segueDetailViewController = "segueDetailViewController"
    private static let modelName = "Virtual_Tourist"
    
    let dataController = DataController(modelName: AppDelegate.modelName)

    
    // MARK: - Virtual Tourist Application
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        dataController.load()
        let mapViewController = window?.rootViewController as! MapViewController
        mapViewController.dataController = dataController
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveViewContext()
    }
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppDelegate.modelName)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.printErrorDescription(error: error)
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveViewContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                self.printErrorDescription(error: error)            }
        }
    }
    
    func printErrorDescription(error: Error?) {
        if showErrorDescription {
            if let error = error as NSError? {
                print("\(Constants.ErrorMessage.errorDescription) \(error), \(error.userInfo)")
            }
        }
    }
    
}
