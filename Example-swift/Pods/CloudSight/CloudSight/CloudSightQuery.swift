//
//  CloudSightQuery.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit
import CoreLocation
import CoreGraphics

public class CloudSightQuery : NSObject, CloudSightImageRequestDelegate  {
    let kTPQueryCancelledError = 9030;
    
    var request: CloudSightImageRequest? = nil
    var response: CloudSightImageResponse? = nil
    var destroy: CloudSightDelete? = nil
    var queryDelegate: CloudSightQueryDelegate
    
    public var title: String = ""
    public var skipReason: String = ""
    public var token: String = ""
    public var remoteUrl: String = ""

    public init(image: NSData, atLocation location: CGPoint, withDelegate delegate: CloudSightQueryDelegate, atPlacemark placemark: CLLocation, withDeviceId deviceId: String) {
        self.queryDelegate = delegate
        super.init()
        self.request = CloudSightImageRequest(image: image, atLocation:location, withDelegate:self, atPlacemark:placemark, withDeviceId:deviceId)
        
    }
    
    deinit {
        
    }
    
    func cancelAndDestroy()
    {
        self.request!.cancel()
        self.response!.cancel()
        
        self.destroy = CloudSightDelete(token: self.token);
        self.destroy!.startRequest()
    }
    
    func stop()
    {
        self.cancelAndDestroy()
        
        let error = NSError(domain: NSBundle(forClass: self.dynamicType).bundleIdentifier!, code: kTPQueryCancelledError, userInfo: [NSLocalizedDescriptionKey : "User cancelled request"])
        self.queryDelegate.cloudSightQueryDidFail(self, withError:error)
    }
    
    public func start()
    {
        self.request!.startRequest()
    }
    
    func description1() -> String
    {
        return String(format: "token: '%@', remoteUrl: '%@', title:'%@', skipReason:'%@'", self.token, self.remoteUrl, self.title, self.skipReason)

    }
    
    func name() -> String
    {
        if self.title.isEmpty
        {
            return self.skipReason
        }
        return self.title
    }
    
    func cloudSightRequest(sender:CloudSightImageRequest, didReceiveToken token:String, withRemoteURL url: String)
    {
        self.response = CloudSightImageResponse(token: token, withDelegate:self.queryDelegate, forQuery:self)
        self.response!.pollForResponse()
        self.token = token;
        self.remoteUrl = url;
        self.queryDelegate.cloudSightQueryDidFinishUploading(self)
    }
    
    func cloudSightRequest(sender: CloudSightImageRequest, didFailWithError error:NSError)
    {
        self.queryDelegate.cloudSightQueryDidFail(self, withError:error);
    }

}
