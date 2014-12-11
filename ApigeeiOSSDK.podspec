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
  s.source_files        = 'source/Classes/*.{h,m}'
  s.public_header_files = 'source/Classes/**/*.h'
  s.exclude_files       = 'source/Classes/UIEventTracking/*.{h,m}'
  s.framework           = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'

# Pod Dependencies
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'PLCrashReporter', '~> 1.2-rc5'

# MonitoringServices Spec
  s.subspec 'MonitoringServices' do |monitoring|
    monitoring.requires_arc = true
    monitoring.source_files = 'source/Classes/Services/*.{h,m}'
    monitoring.framework = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  end

# Models Spec
  s.subspec 'Models' do |models|
    models.requires_arc = true
    models.source_files = 'source/Classes/Models/*.{h,m}'
    models.framework = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  end

# Categories Spec
  s.subspec 'Categories' do |categories|
    categories.requires_arc = true
    categories.source_files = 'source/Classes/Categories/*.{h,m}'
    categories.framework = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  end

# Support Spec
  s.subspec 'Support' do |support|
    support.requires_arc = true
    support.source_files = 'source/Classes/Support/*.{h,m}'
    support.framework = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  end

# AppServices Spec
  s.subspec 'AppServices' do |appservices|
    appservices.requires_arc = true
    appservices.source_files = 'source/Classes/AppServices/*.{h,m}'
    appservices.framework = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
  end
end
