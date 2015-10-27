//
//  MarsWeatherDownloadManager.swift
//  MarsWeather
//
//  Created by Claus Zimmermann on 26.10.15.
//  Copyright © 2015 Claus Zimmermann. All rights reserved.
//

import Foundation


class MarsWeatherDownloadManager {
    
    // URL string to the latest weather information
    let latestMarsWeatherURLStr = "http://marsweather.ingenology.com/v1/latest/?format=json"
    
    // URL string to the weather archive information
    let marsWeatherArchiveURLStr = "http://marsweather.ingenology.com/v1/archive/?format=json"
    
    
    //singleton Pattern
    static let sharedInstance = MarsWeatherDownloadManager()
    
    
    // retrieves latest/current weather data
    func retrieveLatestMarsWeather(retrieveCompletionHandler:(jsonValue: JSONValue) ->Void, retrieveErrorHandler:() -> Void) {
        
        self.retrieveData(self.latestMarsWeatherURLStr, retrieveCompletionHandler: { (jsonValue) -> Void in
                retrieveCompletionHandler(jsonValue: jsonValue)
            }, retrieveErrorHandler: { () -> Void in
                retrieveErrorHandler()
        })
        
    }
    
    
    // retrieves archived weather data
    func retrieveArchivedMarsWeather(retrieveCompletionHandler:(jsonValue: JSONValue) ->Void, retrieveErrorHandler:() -> Void) {
        
        self.retrieveData(self.marsWeatherArchiveURLStr, retrieveCompletionHandler: { (jsonValue) -> Void in
               retrieveCompletionHandler(jsonValue: jsonValue)
            }, retrieveErrorHandler: { () -> Void in
                retrieveErrorHandler()
        })
        
    }
    
    
    // generic method to retrieve weather data. Parameter urlString will determine which json service will be used
    func retrieveData(urlString: String, retrieveCompletionHandler:(jsonValue: JSONValue) -> Void, retrieveErrorHandler:() -> Void) -> Void {
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: urlString)!
     
        let task = session.dataTaskWithURL(url, completionHandler: {(data :NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let retrievedData = data {
                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(retrievedData, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let json = JSONValue.fromObject(jsonDictionary) {
                    
                    // data has been successfully retrieved, so call the completion handler
                    retrieveCompletionHandler(jsonValue: json)
                    
                } else {
                    
                    // error while creating the json value, so call the error handler to handle the error
                    retrieveErrorHandler()
                    
                }
            } else {
                
                // error while retrieving the data, so call the error handler to handle the error
                retrieveErrorHandler()
                
            }
        })
        
        // start the task asynchronously
        task.resume()
        
    }
    
}