Pod::Spec.new do |spec|
  spec.name             = 'KKCommon'
  spec.version          = '1.0.0'
  spec.license          = 'MIT'
  spec.homepage         = 'https://github.com/pddkhanh/KKCommon'
  spec.authors          = { 'Khanh Pham' => 'khanh.phamdd@gmail.com' }
  spec.summary          = 'Common classes and extensions'
  spec.source           = { :path => './' }
  spec.source_files		= 'Source/**/*.{h,m,swift}'
  spec.requires_arc     = true

  spec.platform   	    = :ios, "9.0"
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }

  spec.dependency 'RxSwift', '~> 4.1'
  spec.dependency 'RxCocoa', '~> 4.1'
  spec.dependency 'CocoaLumberjack/Swift', '~> 3.4'

end
