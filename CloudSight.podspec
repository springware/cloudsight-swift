Pod::Spec.new do |s|
s.name         = "CloudSight"
s.version      = "1.0"
s.summary      = "CloudSight image recognition API interface in Swift"
s.description  = <<-DESC
CloudSight is a simple web API for image recognition.  This library is
an implementation in Swift for developing applications that leverage
the CloudSight image recognition API, and is derived from the CamFind iOS app.
DESC

#s.homepage     = "http://cloudsightapi.com"
s.homepage     = "https://github.com/springware/cloudsight-swift.git"
s.license      = { :type => "MIT" }
s.authors      = { "Oasis" => "brad@cloudsightapi.com" }
s.social_media_url = "http://twitter.com/CloudSightAPI"
s.source = { :git => "https://github.com/springware/cloudsight-swift.git", :tag => s.version.to_s }
s.framework = "UIKit"

s.ios.deployment_target = '8.0'

s.requires_arc = true
s.source_files = 'CloudSight/*.swift'

s.preserve_paths = 'CocoaPods/**/*'
s.pod_target_xcconfig = {
'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '${PODS_ROOT}/CloudSight/CocoaPods/macosx',
'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(PODS_ROOT)/CloudSight/CocoaPods/iphoneos',
'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(PODS_ROOT)/CloudSight/CocoaPods/iphonesimulator',
'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(PODS_ROOT)/CloudSight/CocoaPods/appletvos',
'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(PODS_ROOT)/CloudSight/CocoaPods/appletvsimulator',
'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(PODS_ROOT)/CloudSight/CocoaPods/watchos',
'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(PODS_ROOT)/CloudSight/CocoaPods/watchsimulator'
}


end
