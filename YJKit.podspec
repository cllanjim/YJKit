
Pod::Spec.new do |s|

  s.name             = "YJKit"
  s.version          = "0.3.11"
  s.license          = 'MIT'
  s.summary          = "A useful extension for iOS library."
  s.homepage         = "https://github.com/huang-kun/YJKit"
  s.author           = { "huang-kun" => "jack-huang-developer@foxmail.com" }
  s.source           = { :git => "https://github.com/huang-kun/YJKit.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'YJKit/**/*'
  s.public_header_files = 'YJKit/**/*.h'

end
