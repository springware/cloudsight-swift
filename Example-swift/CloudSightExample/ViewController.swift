//
//  ViewController.swift
//  CloudSightExample
//
//  Created by OCR Labs on 3/24/17.
//  Copyright © 2017 OCR Labs. All rights reserved.
//

import UIKit
import CloudSight
import CoreLocation

class ViewController: UIViewController, CloudSightQueryDelegate {
    
    var query: CloudSightQuery? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CloudSightConnection.sharedInstance().consumerKey = "micgxNLMmChbXHLl0CLULA"
        CloudSightConnection.sharedInstance().consumerSecret = "O6swU0FK8ZkdiQcLhqDEPA"
        searchWithImage(UIImage(named: "logo")!)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func searchWithImage(image: UIImage){
        let deviceIdentifier = ""  // This can be any unique identifier per device, and is optional - we like to use UUIDs
        let location = CLLocation()  // you can use the CLLocationManager to determine the user's location
        
        // We recommend sending a JPG image no larger than 1024x1024 and with a 0.7-0.8 compression quality,
        // you can reduce this on a Cellular network to 800x800 at quality = 0.4
        let imageData = UIImageJPEGRepresentation(image, 0.7)
        
        // Create the actual query object
        self.query = CloudSightQuery (image: imageData!, atLocation:CGPointZero, withDelegate:self, atPlacemark:location,
            withDeviceId:deviceIdentifier)
        
        // Start the query process
        self.query!.start()
    }
    
    //pragma mark CloudSightQueryDelegate
    
    func cloudSightQueryDidFinishIdentifying(query: CloudSightQuery){
        if !query.skipReason.isEmpty {
            NSLog("Skipped: %@", query.skipReason)
        } else {
            NSLog("Identified: %@", query.title)
        }
    }
    
    func cloudSightQueryDidFail(query: CloudSightQuery, withError error: NSError){
        NSLog("Error: %@", error)
    }
    
    func cloudSightQueryDidUpdateTag(query: CloudSightQuery){
        
    }
    
    func cloudSightQueryDidFinishUploading(query: CloudSightQuery){
        
    }
}

