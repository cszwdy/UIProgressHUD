Pod::Spec.new do |s|
  s.name     = 'UIProgressHUD'
  s.version  = '0.0.1'
  s.ios.deployment_target = '9.0'
  # s.tvos.deployment_target = '9.0'
  s.license  =  { :type => 'MIT', :file => 'LICENSE.txt' }
  s.summary  = 'An extensible and elegent progress HUD for iOS.'
  s.homepage = 'https://github.com/cszwdy/UIProgressHUD'
  s.authors   = { 'Emiaostein' => 'cszwdy@gmail.com'}
  s.source   = { :git => 'https://cszwdy@github.com/cszwdy/ProgressHUD.git', :tag => s.version.to_s }

  s.description = 'UIProgressHUD is elegent, it provides Apple style HUD in default. UIProgressHUD is also extensible, you can extend your HUD easily. It may be the best HUD for iOS.'

  s.source_files = 'ProgressHUD/**/*.{h,swift}'
  # s.framework    = 'QuartzCore'
  s.resources    = 'ProgressHUD/**/*.{storyboard,xcassets}'
  s.requires_arc = true
end