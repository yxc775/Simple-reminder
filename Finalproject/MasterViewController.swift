//
//  MasterViewController.swift
//  Final project
//
//  Created by Yufan Chen on 2018/4/23.
//  Copyright © 2018年 Yufan Chen. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate, UNUserNotificationCenterDelegate{

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    /*Example code of creating a trigger
    @IBAction func action(_ sender: Any){
        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.subtitle = "the 5 seconds are really up"
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 50, repeats: false);
        let request = UNNotificationRequest(identifier: "timerdone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: {didallow, error in })
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    @objc
    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }*/

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.currentIndex = indexPath
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [fetchedResultsController.object(at: indexPath).notificationKey!])
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        cell.textLabel!.text = event.content!.description
        let date = event.deadline!.description(with: NSLocale.current);
        let head = "on "
        cell.detailTextLabel!.text = head + date;
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
    func createNotification(view:UIViewController, identifier: String){
        let calendar = Calendar.current
        let notification = UNMutableNotificationContent()
        notification.title = "Reminder"
        let head = "on "
        var dateComponent: DateComponents?
        
        if let editview = view as? EditViewController{
        notification.subtitle = head + editview.date!.date.description(with: NSLocale.current)
        notification.body = editview.content!.text!
        dateComponent = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: editview.date!.date)
        }
        
        if let editview = view as? DetailViewController{
        notification.subtitle = head + editview.stored!.description(with: NSLocale.current)
        notification.body = editview.storec!
        dateComponent = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: editview.stored!)
        }
        notification.sound = UNNotificationSound.default();
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent!, repeats: false)
        let request = UNNotificationRequest(identifier:identifier, content:notification,trigger:trigger)
        
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil);
    }
    
    
    @IBAction func myUnwindAction( _ unwindSegue: UIStoryboardSegue){
        if let vc = unwindSegue.source as? EditViewController{
            let context = self.fetchedResultsController.managedObjectContext
            let newEvent = Event(context: context)
            
            // If appropriate, configure the new managed object.
            newEvent.deadline = vc.date!.date
            newEvent.content = vc.content!.text
            newEvent.priority = vc.priority!.value
            newEvent.notificationKey = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date()).description
            
            createNotification(view: vc, identifier: newEvent.notificationKey!);
            
          
            // Save the context.
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        if let vc = unwindSegue.source as? DetailViewController{
            let object = fetchedResultsController.object(at: vc.currentIndex!);
            if (vc.isChanged){
                object.setValue(vc.storec!, forKey: "content")
                object.setValue(vc.stored!, forKey: "deadline")
                object.setValue(vc.storep!, forKey: "priority")
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [fetchedResultsController.object(at: vc.currentIndex!).notificationKey!])
                
            object.setValue(Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: Date()).description,forKey: "notificationKey")
                
                createNotification(view: vc, identifier: object.notificationKey!)
                
                do {
                    try fetchedResultsController.managedObjectContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
             self.tableView.reloadData()
            }
            else{
                
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Mark as Finished"
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

