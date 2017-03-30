//
//  CloudSightImageResponse.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

public class CloudSightImageResponse: NSObject {
    let kTPImageResponseTroubleError = 9020
    let kTPImageResponseTimeoutError = 9021
    let kTPImageResponseURL = "https://api.cloudsightapi.com/image_responses/%@"
    var query: CloudSightQuery
    var currentTimer = NSTimer()
    var session = NSURLSession()
    var cancelled: Bool
    var delegate: CloudSightQueryDelegate
    var token: String = ""
    var loadPartialResponse: Bool = false
    
    init(token: String, withDelegate delegate: CloudSightQueryDelegate, forQuery _query: CloudSightQuery) {
        cancelled = false;
        self.token = token;
        self.delegate = delegate;
        query = _query;
    }
    
    deinit {
        self.cancel()
    }
    
    func handleErrorForCode(code: Int, withMessage message: String)
    {
        let error = NSError(domain: NSBundle(forClass: self.dynamicType).bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey : message])
        self.delegate.cloudSightQueryDidFail(query, withError: error)
    }
    
    func pollForResponse() {
        if cancelled {
            return
        }
        
        // Start next request to poll for image
        let responseUrl = String(format: kTPImageResponseURL, self.token)
        let params: NSDictionary = [:];
        
        let authHeader = CloudSightConnection.sharedInstance().authorizationHeaderWithUrl(responseUrl, withParameters: params)
        
        // Setup connection session
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": "application/json", "Authorization": authHeader]
        session = NSURLSession.init(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        let responseUrlWithParameters = NSURL (string:responseUrl);
        //responseUrlWithParameters = responseUrlWithParameters.
        //    [responseUrlWithParameters URLWithQuery:[NSString URLQueryWithParameters:params]];
        
        let request = NSMutableURLRequest(URL: responseUrlWithParameters!)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if self.cancelled {
                return
            }
            
            if error != nil || data == nil {
                self.handleErrorForCode(self.kTPImageResponseTroubleError, withMessage: error!.localizedDescription)
                return
            }
            
            do {
                // Sanity check - sometimes server fails in the response (500 error, etc)
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                if statusCode != 200 || dict.allKeys.count == 0
                {
                    self.handleErrorForCode(self.kTPImageResponseTroubleError, withMessage: String(data:data!, encoding: NSUTF8StringEncoding)!)
                    return
                }
                
                // Handle the CloudSight image response
                let taggedImageStatus = String(dict.objectForKey("status")!)
                if taggedImageStatus == "not completed"
                {
                    self.restart()
                }
                else if taggedImageStatus == "skipped"
                {
                    var taggedImageString = dict.objectForKey("reason")!
                    if taggedImageString is NSNull
                    {
                        taggedImageString = ""
                    }
                    
                    self.query.skipReason = String(taggedImageString)
                    self.delegate.cloudSightQueryDidFinishIdentifying(self.query)
                }
                else if taggedImageStatus == "in progress" || taggedImageStatus == "completed"
                {
                    var taggedImageString = dict.objectForKey("name")!
                    if taggedImageString is NSNull
                    {
                        taggedImageString = ""
                    }

                    self.query.title = String(taggedImageString)
                    if taggedImageStatus == "in progress"
                    {
                        self.restart()
                        self.delegate.cloudSightQueryDidUpdateTag(self.query)
                    }
                    else
                    {
                        self.delegate.cloudSightQueryDidFinishIdentifying(self.query)
                    }
                }
                else if taggedImageStatus == "timeout"
                {
                    self.handleErrorForCode(self.kTPImageResponseTimeoutError, withMessage: "Timeout, please try again")
                }
                
            } catch {
                print("error: \(error)")
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func cancel() {
        currentTimer.invalidate();
        
        cancelled = true;
        session.invalidateAndCancel();
    }
    
    func restart() {
        if cancelled {
            return
        }
        
        // Callback happens from another queue during response
        dispatch_async(dispatch_get_main_queue(), {
            // Restart the request loop after a 1s delay
            self.currentTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "pollForResponse", userInfo: nil, repeats: false)})
    }
}
