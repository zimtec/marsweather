//
//  ArchivedMarsWeatherTableViewController.swift
//  MarsWeather
//
//  Created by Claus Zimmermann on 26.10.15.
//  Copyright © 2015 Claus Zimmermann. All rights reserved.
//

import UIKit

class ArchivedMarsWeatherTableViewController: UITableViewController {

    var jsonMarsArchiveResultObject : JSONValue?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Archive Weather Data"
        
        let rightButton = UIBarButtonItem(title: "Reload", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("loadMarsArchivedData"))
        
        self.navigationItem.rightBarButtonItem = rightButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    func showError() {
        let alert = UIAlertController(title: "Error", message: "Error while loading archived data. Make sure you are connected to the internet", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .Default, handler: { action in
            // try to reload the weather data
            self.loadMarsArchivedData()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func loadMarsArchivedData() {
        // set previous json data to nil in order to reset the table
        self.jsonMarsArchiveResultObject = nil
        
        // reload the table with blank data
        self.tableView.reloadData()
        
        MarsWeatherDownloadManager.sharedInstance.retrieveArchivedMarsWeather({(jsonValue) -> Void in
            
            // mars weather archive data has been successfully retrieved
            if let jsonResultObject = jsonValue["results"] {
                
                // in this controller we will work only with the json object 'results'. So for convenience reasons set a reference to the 'results' json object here
                self.jsonMarsArchiveResultObject = jsonResultObject

                // make sure reloading the table will be executed on the main queue since we update the screen here
                dispatch_sync(dispatch_get_main_queue()){
                    self.tableView.reloadData()
                }
                
            }
            },  retrieveErrorHandler: { () -> Void in
                //error while retrieving weather data
                
                // make sure gui code gets called on the main queue since we update the screen
                dispatch_sync(dispatch_get_main_queue()){
                    self.showError()
                }
        })
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        self.loadMarsArchivedData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var resultCount = 0
        
        if let resultsArray = self.jsonMarsArchiveResultObject?.array {
            // Count the number of child array entries for the json object 'result'. This value will determine the number of sections in the table
            resultCount = resultsArray.count
        }
        
        return resultCount
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        
        if let availableParameters = self.jsonMarsArchiveResultObject?[section]?.sortedKeys {
            // Count the number of json attributes for the json array entry corresponding to the current section. This will determine the number of rows in the table section
            numberOfRowsInSection = availableParameters.count
        }
        
        return numberOfRowsInSection
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("archivedMarsWeatherCell", forIndexPath: indexPath)

        if let resultArray = self.jsonMarsArchiveResultObject?.array {
            
            // get the json attribute names for the corresponding json array entry and store a reference to it in jsonAttributeNames (sorted)
            if let jsonAttributeNames = resultArray[indexPath.section].sortedKeys {
                
                // get the corresponding attribute name for the current row and store it in jsonAttributeName
                let jsonAttributeName = jsonAttributeNames[indexPath.row]
                
                cell.textLabel?.text = jsonAttributeName
                
                // set the detail label to the json value corresponding to the jsonAttributeName
                cell.detailTextLabel?.text = self.jsonMarsArchiveResultObject?[indexPath.section]?[jsonAttributeName]?.valueAsString
            }
        }
        
        return cell
    }
    

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionTitle = ""
        
        if let resultArray = self.jsonMarsArchiveResultObject?.array {
            if let jsonArchivedSample = resultArray[section].object {
                
                // use the terrestrial date for the section header
                if let terrestialDate = jsonArchivedSample["terrestrial_date"]?.string {
                    sectionTitle = terrestialDate
                }
                
            }
        }
        
        return sectionTitle
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
