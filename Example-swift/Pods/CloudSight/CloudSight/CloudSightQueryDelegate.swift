//
//  CloudSightQueryDelegate.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

public protocol CloudSightQueryDelegate {
    
    func cloudSightQueryDidFinishIdentifying(query: CloudSightQuery)
    
    func cloudSightQueryDidFail(query: CloudSightQuery, withError error: NSError)
    
    func cloudSightQueryDidUpdateTag(query: CloudSightQuery)
    
    func cloudSightQueryDidFinishUploading(query: CloudSightQuery)
}