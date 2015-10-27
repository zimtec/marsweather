//
//  CurrentMarsWeatherTableViewController.swift
//  MarsWeather
//
//  Created by Claus Zimmermann on 26.10.15.
//  Copyright © 2015 Claus Zimmermann. All rights reserved.
//

import UIKit

class CurrentMarsWeatherTableViewController: UITableViewController {
    
    var jsonMarsReportObject : JSONValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.title = "Mars Weather"
        
        let rightButton = UIBarButtonItem(title: "Reload", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("loadMarsWeatherData"))
        
        self.navigationItem.rightBarButtonItem = rightButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Error while loading data. Make sure you are connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
           
            // try to reload the weather data
            self.loadMarsWeatherData()
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func loadMarsWeatherData() {
        // set previous json data to nil in order to reset the table
        self.jsonMarsReportObject = nil
        
        // reload table with blank data
        self.tableView.reloadData()
        
        MarsWeatherDownloadManager.sharedInstance.retrieveLatestMarsWeather({(jsonValue) -> Void in
            // mars weather data has been successfully retrieved
            if let jsonReportObject = jsonValue["report"] {
                
                // in this controller we  work  only with the json report object. So for convenience reasons set a reference to the report object here
                self.jsonMarsReportObject = jsonReportObject

                // make sure reloading table is executed on the main queue since we update the screen here
                dispatch_sync(dispatch_get_main_queue()){
                    self.tableView.reloadData()
                }
                
            }
            },  retrieveErrorHandler: { () -> Void in
                //error while retrieving weather data
                
                // make sure gui code gets called on the main thread
                dispatch_sync(dispatch_get_main_queue()){
                    self.showError()
                }
        })
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.loadMarsWeatherData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // only if the jsonMarsReportObject is valid, weather data will be shown in the first section
        return self.jsonMarsReportObject != nil ? 1 : 0;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if let sortedKeys = self.jsonMarsReportObject?.sortedKeys {
            // count the json child attributes of the report object. Each child will be displayed in one row
            count = sortedKeys.count
        }
        

        return count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentMarsWeatherTableCell", forIndexPath: indexPath)

        if let jsonReportObject = self.jsonMarsReportObject {
            
            // get all child attributes for the json report object and store them in attributeNames (sorted)
            if let attributeNames = jsonReportObject.sortedKeys {
                
                // get the json atttribute name of the report child for the current row and store it in attributeName
                let attributeName = attributeNames[indexPath.row]
                
                cell.textLabel?.text = attributeName
                
                // get the json value for the corresponding json attribute name
                cell.detailTextLabel?.text = jsonReportObject[attributeName]?.valueAsString
            }
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Current Weather data"
    }

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
