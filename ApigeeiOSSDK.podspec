Pod::Spec.new do |spec|
  spec.name             = 'ApigeeiOSSDK'
  spec.version          = '2.0.16'
  spec.summary          = 'The iOS SDK for everything Apigee.'
  spec.homepage         = 'https://github.com/apigee/apigee-ios-sdk'
  spec.license          = 'Apache'
  spec.social_media_url = 'https://twitter.com/Apigee'
  spec.author           = { 'Robert Walsh' => 'rjwalsh1985@gmail.com' }
  spec.source           = { :git => 'https://github.com/apigee/apigee-ios-sdk.git', :branch => 'master', :tag => 'v' + spec.version.to_s }

  spec.platform     = :ios, '5.0'
  spec.requires_arc = true

  spec.public_header_files  = 'zip/apigee-ios-sdk-' + spec.version.to_s + '/lib/ApigeeiOSSDK.framework/Versions/A/Headers/*.h'
  spec.vendored_frameworks  = 'zip/apigee-ios-sdk-' + spec.version.to_s + '/lib/ApigeeiOSSDK.framework'
  spec.preserve_paths       = 'zip/apigee-ios-sdk-' + spec.version.to_s + '/lib/ApigeeiOSSDK.framework'

  spec.prepare_command      = './build_release_zip.sh ' + spec.version.to_s

  spec.frameworks = 'CoreLocation','CoreTelephony','Security','SystemConfiguration','UIKit'
end
