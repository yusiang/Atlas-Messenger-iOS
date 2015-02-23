platform :ios, '7.0'
source 'https://github.com/CocoaPods/Specs.git'
source 'git@github.com:layerhq/cocoapods-specs.git'

target 'Atlas Messenger' do
  pod 'SVProgressHUD', :head
  #pod 'LayerKit', '~> 0.10.0'
  pod 'Atlas', path: 'Libraries/Atlas'
  pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git'
end

target 'Atlas MessengerTests' do
  pod 'KIF', '~> 3.0.8'
  pod 'OCMock', '~> 3.1'
  pod 'KIFViewControllerActions', git: 'https://github.com/blakewatters/KIFViewControllerActions.git'
  pod 'Expecta', '~> 0.3.0'
  pod 'LYRCountDownLatch', git: 'https://github.com/layerhq/LYRCountDownLatch.git'
end
