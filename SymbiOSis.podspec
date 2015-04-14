
Pod::Spec.new do |s|
  s.name             = "SymbiOSis"
  s.version          = "0.1.0"
  s.summary          = "An MVVM-inspired framework for building apps with less code, less bugs, and in less time."
  s.homepage         = "https://github.com/daniel-hall/SymbiOSis"
  s.license          = 'MIT'
  s.author           = { "Dan Hall" => "dan@danhall.io" }
  s.source           = { :git => "https://github.com/daniel-hall/SymbiOSis.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/_danielhall>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
