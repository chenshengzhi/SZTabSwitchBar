
Pod::Spec.new do |s|

  s.name         = "SZTabSwitchBar"

  s.version      = "0.0.7"

  s.summary      = "tab switch bar"

  s.homepage     = "https://github.com/chenshengzhi/SZTabSwitchBar"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.author       = { "陈圣治" => "329012084@qq.com" }

  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/chenshengzhi/SZTabSwitchBar.git", :tag => s.version.to_s }

  s.source_files = "SZTabSwitchBar/*.{h,m}"

  s.requires_arc = true

end
