Pod::Spec.new do |s|
  s.name            = 'ApigeeiOSSDK'
  s.version         = '2.0.13'
  s.license         = 'Apache License'
  s.homepage        = 'http://apigee.com'
  s.authors         = {'Robert Walsh' => 'rwalsh@apigee.com'}
  s.summary         = 'summary'
  s.xcconfig        = { 'OTHER_LDFLAGS' => '-ObjC' }

# Source Info
  s.platform        = :ios
  s.requires_arc    = true
  s.source          = {:git => 'https://github.com/apigee/apigee-ios-sdk.git', :branch => 'master', :tag => 'v2.0.13'}
  s.source_files    = 'source/Classes/**/*.{h,m}'
  s.public_header_files = 'source/Classes/**/*.h'
  s.exclude_files   = 'source/Classes/ApigeeReachability.{h,m}'
  s.framework       = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'

  s.subspec 'no-arc' do |subspec1|
    subspec1.requires_arc = false
    subspec1.source_files = 'source/Classes/ApigeeReachability.{h,m}'
  end

# Pod Dependencies
  s.dependency 'OpenUDID'
  s.dependency 'SSKeychain'
  s.dependency 'PLCrashReporter'
end