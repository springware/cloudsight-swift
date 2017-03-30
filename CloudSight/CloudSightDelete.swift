//
//  CloudSightDelete.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

let kTPImageDeleteURL = "https://api.cloudsightapi.com/image_requests/%@"

public class CloudSightDelete: NSObject {
    var session: NSURLSession? = nil
    var token: String
    
    init(token: String) {
        self.token = token
    }
    
    deinit {
        self.cancel()
    }
    
    func startRequest() {
        // Start next request to poll for image

        let deleteUrl = String(format: kTPImageDeleteURL, token)
        let authHeader = CloudSightConnection.sharedInstance().authorizationHeaderWithUrl(deleteUrl, withParameters: [:], withMethod: kBFOAuthDELETERequestMethod)
        
        // Setup connection session
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": "application/json", "Authorization": authHeader]
        session = NSURLSession.init(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        
        let request =  NSMutableURLRequest(URL: NSURL(string:deleteUrl)!)
        request.HTTPMethod = kBFOAuthDELETERequestMethod
        let task = session!.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            // Ignore
        })
        task.resume()
        session!.finishTasksAndInvalidate()
    }
    
    func cancel() {
        session!.invalidateAndCancel()
    }
}
