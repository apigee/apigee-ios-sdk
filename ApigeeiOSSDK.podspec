Pod::Spec.new do |s|
  s.name                = 'ApigeeiOSSDK'
  s.version             = '2.0.13'
  s.license             = 'Apache License'
  s.homepage            = 'http://apigee.com'
  s.authors             = {'Robert Walsh' => 'rwalsh@apigee.com'}
  s.summary             = 'The iOS SDK for everything Apigee.'
  s.xcconfig            = { 'OTHER_LDFLAGS' => '-ObjC' }

# Source Info
  s.platform            = :ios
  s.requires_arc        = true
  s.source              = {:git => 'https://github.com/RobertWalsh/apigee-ios-sdk.git', :branch => 'cocoapods'}
  s.source_files        = 'source/Classes/**/*.{h,m}'
  s.public_header_files = 'source/Classes/**/*.h'
  s.exclude_files       = 'source/Classes/Support/ApigeeReachability.m','source/Classes/UIEventTracking/*.{h,m}'
  s.framework           = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'

# Pod Dependencies
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'PLCrashReporter', '~> 1.2-rc5'

# Non-Arc File Spec
  s.subspec 'no-arc' do |subspec1|
    subspec1.requires_arc = false
    subspec1.source_files = 'source/Classes/Support/ApigeeReachability.m'
  end
end
