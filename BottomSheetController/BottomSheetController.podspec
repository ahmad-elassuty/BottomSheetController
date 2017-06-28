Pod::Spec.new do |s|
  s.name                  = 'BottomSheetController'
  s.version               = '0.0.1'
  s.summary               = 'Bottom sheet like iOS 10 Maps app.'
  s.homepage              = 'https://github.com/AhmedElassuty/IOS-BottomSheet'
  s.license               = { type: 'MIT', file: 'LICENSE' }
  s.author                = { 'Ahmed Elassuty' => 'ahmad.elassuty@gmail.com' }
  s.platform              = :ios
  s.ios.deployment_target = '9.0'
  s.source                = { git: '', tag: s.version }
  s.source_files          = 'Source/*.swift'
  s.requires_arc          = true
end
