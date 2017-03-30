//
//  CloudSightConnection.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

public class CloudSightConnection: NSObject {
    public var consumerKey: String = ""
    public var consumerSecret: String = ""
    static  var _instance = CloudSightConnection()
    
    public class func sharedInstance() -> CloudSightConnection {
       return _instance
    }
    
    func authorizationHeaderWithUrl(url: String) ->NSString {
        return authorizationHeaderWithUrl(url, withParameters: [:])
    }
    
    func authorizationHeaderWithUrl(url: String, withParameters parameters: NSDictionary ) ->NSString {
        return authorizationHeaderWithUrl(url, withParameters: parameters, withMethod: kBFOAuthGETRequestMethod)
    }
    
    func authorizationHeaderWithUrl(url: String, withParameters parameters: NSDictionary , withMethod method: String) ->NSString {
        assert(!consumerKey.isEmpty , "consumerKey property is set to nil, be sure to set credentials")
        assert(!consumerSecret.isEmpty, "consumerSecret property is set to nil, be sure to set credentials")
        
        let oauth = BFOAuth(consumerKey: self.consumerKey, consumerSecret:self.consumerSecret, accessToken:"", tokenSecret:"")
        
        oauth.requestURL = NSURL(string: url)!
        oauth.requestMethod = method
        oauth.requestParameters = parameters
        return oauth.authorizationHeader()
    }
}
