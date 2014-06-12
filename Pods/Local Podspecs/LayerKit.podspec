Pod::Spec.new do |s|
  s.name     = 'LayerKit'
  s.version  = '0.50.0'
  s.license  = 'Commercial'
  s.summary  = 'LayerKit is the iOS client interface for the Layer communications cloud.'
  s.homepage = 'https://github.com/layerhq/LayerKit'
  s.authors  = { 'Blake Watters' => 'blake@layer.com', 'Klemen Verdnik' => 'klemen@layer.com' }
  s.source   = { :git => 'https://github.com/layerhq/LayerKit.git', :tag => "v#{s.version}" }  
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  
  s.source_files = 'Code/**/*.{h,m}'
  s.public_header_files = 'Code/*.h'
  s.private_header_files = 'Code/Private/**/*.h'
  s.prefix_header_file = 'Code/Private/LayerKit-Prefix.pch'
  
  s.libraries = 'sqlite3', 'z'
  s.ios.frameworks = 'CFNetwork', 'Security', 'MobileCoreServices', 'SystemConfiguration'
  
  s.prefix_header_contents = <<-PCH
#import <DDLog.h>
#include "LYRLog.h"
PCH

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  
  # Dependencies
  s.dependency 'CocoaSPDY', '~> 1.0.1'
  s.dependency 'CocoaLumberjack', '~> 1.8.1'
  s.dependency 'FMDB', '~> 2.2'
  s.dependency 'FMDBMigrationManager', '~> 1.2.0'
  s.dependency 'layer-thrift', '~> 0.52.0'
  s.dependency 'TransitionKit', '~> 2.1.0'
  s.dependency 'layer-client-messaging-schema', '~> 201406110649840.3'
end
