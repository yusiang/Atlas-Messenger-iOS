Pod::Spec.new do |s|
  s.name     = 'LayerKit'
  s.version  = '0.50.0'
  s.license  = 'Commercial'
  s.summary  = 'LayerKit is the iOS client interface for the Layer communications cloud.'
  s.homepage = 'https://github.com/layerhq/LayerKit'
  s.authors  = { 'Blake Watters' => 'blake@layer.com', 'Klemen Verdnik' => 'klemen@layer.com' }
  s.source   = { :git => 'https://github.com/layerhq/LayerKit.git', :tag => "v#{s.version}" }  
  s.requires_arc = true    
  s.libraries = 'sqlite3', 'z'
  
  s.ios.frameworks = 'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration'
  s.ios.deployment_target = '7.0'  
  
  # Subspecs
  s.default_subspec = 'Public'
  s.subspec 'Public' do |ss|
    ss.source_files = 'Code/**/*.{h,m}'
    ss.public_header_files = 'Code/*.h'
    ss.private_header_files = 'Code/Private/**/*.h'
    ss.prefix_header_file = 'Code/Private/LayerKit-Prefix.pch'
  end
  
  s.subspec 'Testing' do |ss|
    ss.source_files = 'Code/Private/Testing'
    ss.public_header_files = ['Code/Private/Testing/*.h', 'Code/Private/Support/**/*.h', 'Code/Private/Authentication/**/*.h']
    ss.dependency 'LayerKit/Public'
  end  
  
  # Dependencies
  s.dependency 'CocoaSPDY', '~> 1.0.1'
  s.dependency 'CocoaLumberjack', '~> 1.8.1'
  s.dependency 'FMDB', '~> 2.2'
  s.dependency 'FMDBMigrationManager', '~> 1.2.0'
  s.dependency 'layer-thrift', '~> 0.52.0'
  s.dependency 'TransitionKit', '~> 2.1.0'
  s.dependency 'layer-client-messaging-schema', '~> 201406110649840.3'
end
