//
//  CurrentMarsWeatherTableViewController.swift
//  MarsWeather
//
//  Created by Claus Zimmermann on 26.10.15.
//  Copyright © 2015 Claus Zimmermann. All rights reserved.
//

import UIKit

class CurrentMarsWeatherTableViewController: UITableViewController {
    
    var jsonMarsReportValues : JSONValue?
    
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
        let alert = UIAlertController(title: "Error", message: "Error while loading data", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            // try to reload the weather data
            self.loadMarsWeatherData()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func loadMarsWeatherData() {
        self.jsonMarsReportValues = nil
        self.tableView.reloadData()
        MarsWeatherDownloadManager.sharedInstance.retrieveLatestMarsWeather({(jsonValue) -> Void in
            // mars weather data has been successfully retrieved
            if let jsonReportValue = jsonValue["report"] {
                // we  work in this controller only with the report child values. So for convenience reasons set a reference to the report here
                self.jsonMarsReportValues = jsonReportValue
                
                dispatch_sync(dispatch_get_main_queue()){
                    // make sure reloading table is executed in the main queue, we update the screen here
                    self.tableView.reloadData()
                }
            }
            },  retrieveErrorHandler: { () -> Void in
                //error while retrieving weather data
                dispatch_sync(dispatch_get_main_queue()){
                    // make sure gui code gets called on the main thread
                    self.showError()
                }
        })
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.loadMarsWeatherData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.jsonMarsReportValues != nil ? 1 : 0;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        
        if let sortedKeys = self.jsonMarsReportValues?.sortedKeys {
            count = sortedKeys.count
        }
        

        return count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CurrentMarsWeatherTableCell", forIndexPath: indexPath)

        
        if let jsonReport = self.jsonMarsReportValues {
            if let parameterKeys = jsonReport.sortedKeys {
                let parameterName = parameterKeys[indexPath.row]
                cell.textLabel?.text = parameterName
                cell.detailTextLabel?.text = jsonReport[parameterName]?.valueAsString
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
