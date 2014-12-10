Pod::Spec.new do |spec|
  spec.name             = 'OpenUDID'
  spec.version          = '1.0.0'
  spec.summary          = 'Open source initiative for a universal and persistent UDID solution for iOS.'
  spec.author           = { 'Robert Walsh' => 'rwalsh@gmail.com' }
  spec.source           = { :git => 'https://github.com/RobertWalsh/OpenUDID', :branch => 'master'}
  spec.requires_arc     = false
  spec.source_files     = '*.{h,m}'
  spec.platform         = :ios, '5.0'
  spec.license          = { :type => 'Zlib' }
end
