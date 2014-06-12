Pod::Spec.new do |s|  
  s.name         = 'layer-thrift'
  s.version      = '0.52.0'
  s.summary      =  'The Layer Thrift interfaces'
  s.homepage     =  'http://layer.com'
  s.author       =  { 'Blake Watters' => 'blake@layer.com' }
  s.source       =  { git: 'git@github.com:layerhq/lyr-thrift-common.git', tag: s.version }
  s.license      =  'Commercial'
  
  s.source_files = 'src/out/gen-cocoa/*.{h,m}'
  
  s.dependency 'thrift', '~> 0.9.1'
  
  # Platform setup
  s.requires_arc          = true
  s.ios.deployment_target = '7.0'
  s.ios.frameworks = %w{CFNetwork}
  
  s.prepare_command = "mkdir -p src/out && thrift -o ./src/out -r --gen cocoa ./src/ctrl.thrift && thrift -o ./src/out -r --gen cocoa ./src/messaging.thrift"
end

