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
  s.source              = {:git => 'https://github.com/apigee/apigee-ios-sdk.git', :branch => 'cocoapods'}
  s.framework           = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  s.requires_arc        = true
  s.source_files        = 'source/Classes/*.{h,m}'
  s.public_header_files = 'source/Classes/**/*.h'

# Pod Dependencies
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'PLCrashReporter', '~> 1.2-rc5'

# MonitoringServices SubSpec
  s.subspec 'MonitoringServices' do |monitoring|
    monitoring.requires_arc = true
    monitoring.source_files = 'source/Classes/Services/*.{h,m}'
  end

# Models SubSpec
  s.subspec 'Models' do |models|
    models.requires_arc = true
    models.source_files = 'source/Classes/Models/*.{h,m}'
  end

# Categories SubSpec
  s.subspec 'Categories' do |categories|
    categories.requires_arc = true
    categories.source_files = 'source/Classes/Categories/*.{h,m}'
  end

# Support SubSpec
  s.subspec 'Support' do |support|
    support.requires_arc = false
    support.source_files = 'source/Classes/Support/*.{h,m}'
  end

# AppServices SubSpec
  s.subspec 'AppServices' do |appservices|
    appservices.requires_arc = true
    appservices.source_files = 'source/Classes/AppServices/*.{h,m}'
  end

# UIEventTracking SubSpec
  s.subspec 'UIEventTracking' do |uieventtracking|
    uieventtracking.requires_arc = true
    uieventtracking.source_files = 'source/Classes/UIEventTracking/*.{h,m}'
  end
end
