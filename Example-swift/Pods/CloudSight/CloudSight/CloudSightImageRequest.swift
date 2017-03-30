//
//  CloudSightImageRequest.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit
import CoreLocation

class CloudSightImageRequest : NSObject, NSURLSessionDataDelegate {
   
    var session: NSURLSession
    var cancelled: Bool
    
    let kTPImageRequestInvalidError = 9010
    let kTPImageRequestTroubleError = 9011
    let kTPImageRequestURL = "https://api.cloudsightapi.com/image_requests"
    
    var delegate: CloudSightImageRequestDelegate
    var uploadProgressDelegate: CloudSightUploadProgressDelegate? = nil
    
    var token: String = ""
    var remoteUrl: String = ""
    var language: String = ""
    var locale: String = ""
    var image: NSData
    var location: CGPoint
    
    var placemark: CLLocation 
    var deviceId: String
    
    init(image: NSData, atLocation location: CGPoint, withDelegate delegate: CloudSightImageRequestDelegate, atPlacemark placemark: CLLocation, withDeviceId deviceId: String) {
        cancelled = false;
        self.image = image;
        self.location = location;
        
        let localeIdentifier = NSLocale.currentLocale().localeIdentifier
        let regex = try! NSRegularExpression(pattern: "@.*", options: [.CaseInsensitive])
        let localeIdentifierWithoutCalendar = regex.stringByReplacingMatchesInString(localeIdentifier, options: .ReportProgress, range: NSMakeRange(0, localeIdentifier.characters.count), withTemplate: "")
        
        self.locale = localeIdentifierWithoutCalendar;
        self.language = NSLocale.preferredLanguages().first!
        
        self.placemark = placemark;
        self.deviceId = deviceId;
        
        self.session = NSURLSession()
        self.delegate = delegate;
    }
    
    deinit {
        self.cancel()
    }
    
    func setDelegate(delegate: CloudSightImageRequestDelegate) {
        self.delegate = delegate
    }
    
    func buildRequestParameters() -> NSDictionary {
        let params: NSMutableDictionary =
        [
            "image_request[locale]" : locale,
            "image_request[language]" : language,
            "image_request[latitude]" : NSNumber(double: placemark.coordinate.latitude),
            "image_request[longitude]" : NSNumber(double: placemark.coordinate.longitude),
            "image_request[altitude]" : NSNumber(double: placemark.altitude)
        ]
        
        if !deviceId.isEmpty
        {
            params.setValue(deviceId, forKey: "image_request[device_id]")
        }
    
        if location.x != 0.000000 || location.y != 0.000000
        {
            let focusX = String(format: "%f", location.x)
            params.setValue(focusX, forKey: "focus[x]")
            let focusY = String(format: "%f", location.y)
            params.setValue(focusY, forKey: "focus[y]")
        }
    
        return params;
    }
    
    func handleErrorForCode(code: Int, withMessage message: String)
    {
        let error = NSError(domain: NSBundle(forClass: self.dynamicType).bundleIdentifier!, code: code, userInfo: [NSLocalizedDescriptionKey : message])
        delegate.cloudSightRequest(self, didFailWithError:error)
    }
    
    func startRequest() {
        let requestUrl = NSURL(string: kTPImageRequestURL)!
        let params = buildRequestParameters()
        
        // Setup OAuth1 headers
        let authHeader = CloudSightConnection.sharedInstance().authorizationHeaderWithUrl(kTPImageRequestURL, withParameters: params, withMethod: kBFOAuthPOSTRequestMethod)

        // Build Request
        let imageRequestKey = "image_request[image]";
        let filename = "image.jpg";
        let boundary = "tpRequestFormBoundary";
        
        let request =  NSMutableURLRequest(URL: requestUrl)
        request.HTTPMethod = kBFOAuthPOSTRequestMethod
        
        let contentType = String(format: "multipart/form-data; boundary=%@", boundary)
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        
        let body = NSMutableData()
        params.enumerateKeysAndObjectsUsingBlock { (key, obj, stop) -> Void in
            body.appendData(String(format: "--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(String(format: "Content-Disposition: form-data; name=\"%@\"\r\n\r\n", String(key) ).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(String(format: "%@\r\n", String(obj)).dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        // Image attachament part
        if image.length > 0
        {
            body.appendData(String(format: "--%@\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(String(format: "Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", imageRequestKey, filename).dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(String("Content-Type: image/jpeg\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(image)
            body.appendData(String("\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        }
        
        body.appendData(String(format: "--%@--\r\n", boundary).dataUsingEncoding(NSUTF8StringEncoding)!)
        request.setValue(String(format: "%u", UInt(body.length)), forHTTPHeaderField: "Content-Length")
        request.HTTPBody = body
        
        // Setup connection session
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.HTTPAdditionalHeaders = ["Accept": "application/json", "Authorization": authHeader]
        session = NSURLSession.init(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if self.cancelled {
                return
            }
            
            if error != nil || data == nil {
                self.handleErrorForCode(self.kTPImageRequestInvalidError, withMessage: "Trouble sending image")
                return
            }
            
            do {
                let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                let statusCode = (response as? NSHTTPURLResponse)?.statusCode
                if statusCode != 200 || dict.allKeys.count == 0
                {
                    self.handleErrorForCode(self.kTPImageRequestInvalidError, withMessage: String(data:data!, encoding: NSUTF8StringEncoding)!)
                    return
                }
                else if dict.allKeys.count >= 0 && dict.objectForKey("error") != nil {
                    self.handleErrorForCode(self.kTPImageRequestTroubleError, withMessage: String(dict.objectForKey("error")))
                    return
                }
                
                self.token = String(dict.objectForKey("token")!)
                self.remoteUrl = String(dict.objectForKey("url")!)
                self.delegate.cloudSightRequest(self, didReceiveToken:self.token, withRemoteURL: self.remoteUrl)
            } catch {
                print("error: \(error)")
            }
        })
        self.delegate.cloudSightRequest(self, didReceiveToken: self.token, withRemoteURL: self.remoteUrl)
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func cancel() {
        cancelled = true;
        session.invalidateAndCancel();
    }
    
    @objc func URLSession(session: NSURLSession, task:NSURLSessionTask, didSendBodyData bytesSent:Int64, totalBytesSent:Int64, totalBytesExpectedToSend:Int64){
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend);
        self.uploadProgressDelegate!.cloudSightRequest(self, setProgress: progress)
    }
}