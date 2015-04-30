
Pod::Spec.new do |s|
  s.name             = "SymbiOSis"
  s.version          = "0.3.3"
  s.summary          = "An MVVM-inspired framework for building apps with less code, less bugs, and in less time."
  s.homepage         = "https://github.com/daniel-hall/SymbiOSis"
  s.license          = 'MIT'
  s.author           = { "Dan Hall" => "dan@danhall.io" }
  s.source           = { :git => "https://github.com/daniel-hall/SymbiOSis.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/_danielhall'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'SymbiOSis/SymbiOSis.h', 'SymbiOSis/Core/*', 'SymbiOSis/Bindings/*', 'SymbiOSis/Responders/*', 'SymbiOSis/DataSources/*', 'SymbiOSis/Private/*'
  s.public_header_files = 'SymbiOSis/SymbiOSis.h', 'SymbiOSis/Core/*.h', 'SymbiOSis/Bindings/*.h', 'SymbiOSis/Responders/*.h', 'SymbiOSis/DataSources/*.h'
  s.frameworks = 'UIKit'
end
