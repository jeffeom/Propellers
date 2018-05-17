platform :ios, '9.0'

inhibit_all_warnings!
use_frameworks!

def shared_pods
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Storage'
  pod 'FirebaseUI/Storage'
  pod 'Firebase/Database'
  pod 'Firebase/Auth'
  pod 'SDWebImage'
  pod 'NYTPhotoViewer'
  pod 'IQKeyboardManagerSwift'
  pod 'TagListView'
  pod 'Popover', '1.0.4'
  pod 'KRPullLoader'
  pod 'Stripe'
  pod 'NVActivityIndicatorView'
  pod 'Alamofire'
end

target 'Propellers' do
  shared_pods
end

target 'PropellersTests' do
  shared_pods
end

target 'PropellersUITests' do
  shared_pods
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'NMessenger'
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '3.2'
      end
    end
  end
end
