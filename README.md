CloudSight API library for swift.  Extracted from CamFind-iOS.

### Installation

CloudSight is vailable through [CocoaPods](http://cocoapods.org). To Install it, simply add the following line to your pod file.

```ruby
pod 'CloudSight', git: 'https://github.com/springware/cloudsight-swift.git'
```

  
## Usage

### Configure the instance

The CloudSight library uses the OAuth1 authentication method to the API.  Make sure your key and secret are set.

```swift
CloudSightConnection.sharedInstance().consumerKey = "your-key"
CloudSightConnection.sharedInstance().consumerSecret = "your-secret"
```

### Using the query object

The easiest way to use the API is to use a Query object to handle the request/response workflow work for you.

```swift
class ViewController: UIViewController, CloudSightQueryDelegate {
var query: CloudSightQuery? = nil
....
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
```

## Examples

There's a working swift example that you can run by opening `Example-swift/CloudSightExample.xcworkspace` in XCode.

## License

CloudSight is released under the MIT license.
