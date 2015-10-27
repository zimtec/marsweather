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
    
    
    func retrieveLatestMarsWeather(retrieveCompletionHandler:(jsonValue: JSONValue) ->Void, retrieveErrorHandler:() -> Void) {
        self.retrieveData(self.latestMarsWeatherURLStr, retrieveCompletionHandler: { (jsonValue) -> Void in
            retrieveCompletionHandler(jsonValue: jsonValue)
            }, retrieveErrorHandler: { () -> Void in
                retrieveErrorHandler()
        })
        
    }
    
    
    
    func retrieveArchivedMarsWeather(retrieveCompletionHandler:(jsonValue: JSONValue) ->Void, retrieveErrorHandler:() -> Void) {
        
        self.retrieveData(self.marsWeatherArchiveURLStr, retrieveCompletionHandler: { (jsonValue) -> Void in
            retrieveCompletionHandler(jsonValue: jsonValue)
            }, retrieveErrorHandler: { () -> Void in
                retrieveErrorHandler()
        })
        
    }
    
    
    
    func retrieveData(urlString: String, retrieveCompletionHandler:(jsonValue: JSONValue) -> Void, retrieveErrorHandler:() -> Void) -> Void {
        let session = NSURLSession.sharedSession()
        
        let url = NSURL(string: urlString)!
     
        let task = session.dataTaskWithURL(url, completionHandler: {(data :NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if let retrievedData = data {
                //let jsonString = String(data: retrievedData, encoding: NSUTF8StringEncoding)
                //print(jsonString)
                let jsonDictionary = (try! NSJSONSerialization.JSONObjectWithData(retrievedData, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                if let json = JSONValue.fromObject(jsonDictionary) {                retrieveCompletionHandler(jsonValue: json)
                } else {
                    retrieveErrorHandler()
                }
            } else {
                retrieveErrorHandler()
            }
        })
            
        task.resume()
    }
    
}