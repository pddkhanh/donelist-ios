# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'DoneList' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for DoneList

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxDataSources'
  pod 'SnapKit'

  pod 'Fabric'
  pod 'Crashlytics'
  pod 'CocoaLumberjack/Swift'

  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'

  pod 'KKCommon', :path => './LocalPods/KKCommon'

  target 'DoneListTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'Nimble'
    pod 'RxTest'
    pod 'RxBlocking'
  end

  target 'DoneListUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
