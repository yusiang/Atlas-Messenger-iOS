dropbox_path = ENV['LAYER_DROPBOX_PATH'] || '~/Dropbox/'

pod 'SVProgressHUD', :head
# pod 'LayerKit'
#pod 'LayerKit', git: 'git@github.com:layerhq/LayerKit.git'
pod 'LayerKit', path: dropbox_path + "/Layer/Builds/iOS/LayerKit-0.7.12"
pod 'HockeySDK', '~> 3.5.6'

target 'LayerSampleTests' do
  pod 'KIF', '~> 3.0'
  pod 'KIFViewControllerActions', '~> 1.0'
  pod 'Expecta', '~> 0.3.0'
  pod 'LYRCountDownLatch', git: 'git@github.com:layerhq/LYRCountDownLatch.git'
end
