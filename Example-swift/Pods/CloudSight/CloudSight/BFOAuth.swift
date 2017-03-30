//
//  BFOAuth.swift
//  CloudSight
//
//  Created by OCR Labs on 3/9/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit
import CCommonCrypto

let kBFOAuthGETRequestMethod = "GET"
let kBFOAuthPOSTRequestMethod = "POST"
let kBFOAuthPUTRequestMethod = "PUT"
let kBFOAuthDELETERequestMethod = "DELETE"
let kBFOAuthPATCHRequestMethod = "PATCH"

let kBFOAuthConsumerKey = "oauth_consumer_key";
let kBFOAuthNonce       = "oauth_nonce";
let kBFOAuthTimestamp   = "oauth_timestamp";
let kBFOAuthVersion     = "oauth_version";
let kBFOAuthSignatureMethod = "oauth_signature_method";
let kBFOAuthAccessToken = "oauth_token";
let kBFOAuthSignature   = "oauth_signature";

let BFOAuthUTCTimeOffset = 0
public class BFOAuth {
    private var signatureSecret: String = ""
    private var params = [:]
    
    var requestURL = NSURL()
    var requestMethod = ""
    var requestParameters = [:]
    
    init(consumerKey: String, consumerSecret: String, accessToken: String, tokenSecret: String) {
        
        params = NSDictionary(dictionary: [
            kBFOAuthConsumerKey : consumerKey,
            kBFOAuthNonce : nonce(),
            kBFOAuthTimestamp : timestamp(),
            kBFOAuthVersion : "1.0",
            kBFOAuthSignatureMethod : "HMAC-SHA1",
            kBFOAuthAccessToken : accessToken
            ]
        )
        signatureSecret = String(format: "%@&%@",  consumerSecret, tokenSecret)
    }
    
    func parametersForSignature() -> NSDictionary
    {
        if requestParameters.count == 0 {
            return params
        }
        let mergedParams = NSMutableDictionary(dictionary: params)
        mergedParams.addEntriesFromDictionary(self.requestParameters as [NSObject : AnyObject])
        return mergedParams
    }
    
    func signatureBase() -> String{
        let p3 = NSMutableString(capacity: 256)
        let keys:Array = parametersForSignature().allKeys.sort({ String($0).compare(String($1)) == NSComparisonResult.OrderedAscending})
        for key in keys {
            let value = String(parametersForSignature().objectForKey(key)!)
            p3.add(String(key).pcen()).add("=").add(value.pcen()).add("&")
        }
        p3.chomp()

        return String(format: "%@&%@%%3A%%2F%%2F%@%@&%@",
            self.requestMethod,
            self.requestURL.scheme.lowercaseString,
            self.requestURL.host!.lowercaseString.pcen(),
            self.requestURL.path!.pcen(),
            String(p3).pcen())
    }
    
    func base64(input: UnsafeMutablePointer<Void> ) -> String {
        let data = NSData(bytesNoCopy: input, length: 20)
        // Convert to Base64
        let base64String = data.base64EncodedStringWithOptions([])
        return base64String
    }
    
    func signature() -> String
    {
        
        let sigbase = signatureBase().dataUsingEncoding(NSUTF8StringEncoding)
        let secret = signatureSecret.dataUsingEncoding(NSUTF8StringEncoding)
        
        let digest = UnsafeMutablePointer<Void>.alloc(20)
        let cx = UnsafeMutablePointer<CCHmacContext>.alloc(1)
        CCHmacInit(cx,  CCHmacAlgorithm(kCCHmacAlgSHA1), secret!.bytes, secret!.length);
        CCHmacUpdate(cx, sigbase!.bytes, sigbase!.length);
        CCHmacFinal(cx, digest);
        
        return base64(digest);
    }
    
    func authorizationHeader() -> NSString
    {
        let header = NSMutableString(capacity: 512)
        header.add("OAuth ")
        for key in params.allKeys
        {
            header.add(String(key)).add("=\"").add(String(params.objectForKey(key)!)).add("\", ")
        }
        header.add(String(format:"%@=\"", kBFOAuthSignature)).add(self.signature().pcen()).add("\"")
        return header
    }
    
    func nonce() -> String
    {
        return NSUUID().UUIDString
    }
    
    func timestamp() -> String
    {
        return String(format: "%lu", Int(NSDate().timeIntervalSince1970) + BFOAuthUTCTimeOffset)
    }
}

extension String {
    func pcen() -> String
    {
        let charset = NSCharacterSet(charactersInString: "!*'();:@&=+$,/?%#[]").invertedSet
        let escaped = self.stringByAddingPercentEncodingWithAllowedCharacters(charset)
        return escaped!
    }
}

extension NSNumber {
    func pcen() -> String
    {
        return self.stringValue
    }
}

extension NSMutableString {
    func add(s: String) -> NSMutableString{
        self.appendString(s)
        return self;
    }
    
    func chomp() -> NSMutableString
    {
        let N = self.length - 1
        if N >= 0
        {
            self.deleteCharactersInRange(NSMakeRange(N, 1))
        }
        return self
    }
}