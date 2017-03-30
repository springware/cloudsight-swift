//
//  CloudSightUploadProgressDelegate.swift
//  CloudSight
//
//  Created by OCR Labs on 3/7/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit

protocol CloudSightUploadProgressDelegate{
    
    func cloudSightRequest(sender: CloudSightImageRequest, setProgress value: Float)
}
