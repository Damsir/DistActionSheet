Pod::Spec.new do |s|

  s.name         = "DistActionSheet"
  s.version      = "1.0.4"
  s.summary      = "Like WeChat ActionSheet"
  s.author       = { "Damrin" => "75081647@qq.com" }
  s.homepage    = 'https://github.com/Damsir/DistActionSheet'
  s.source      = { :git => 'https://github.com/Damsir/DistActionSheet.git', :tag => s.version }
  s.license = "MIT"
  s.platform = :ios, "8.0"
  s.requires_arc = true
  s.source_files = "DistActionSheet", "DistActionSheet/**/*.{h,m}"
  # s.public_header_files = "DistSlideSegment/*.h"
  s.framework = 'UIKit'
  s.ios.deployment_target = "8.0"

end
