//
//  CloudSightImageRequestDelegate.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

protocol CloudSightImageRequestDelegate {
    
    func cloudSightRequest(sender: CloudSightImageRequest, didReceiveToken token: String, withRemoteURL url: String)
   
    func cloudSightRequest(sender: CloudSightImageRequest, didFailWithError error: NSError)

}
