#
# Be sure to run `pod spec lint Example.podspec.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#

Pod::Spec.new do |s|
  s.name         = "TSMessages"
  s.version      = "1.0"
  s.summary      = "This framework provides an easy to use class to show little notification views on the top of the screen. (à la Tweetbot)."
  s.homepage     = "http://toursprung.com"

  s.license      = 'MIT'

  s.author       = { "Felix Krause" => "felix@toursprung.com" }

  s.platform     = :ios, '5.1'

  s.source_files = 'Classes/**/*.{h,m}', 'Views/**/*.{h,m}'


  s.resources = "Resources/**/*.{png,json}"

  s.requires_arc = true

  s.dependency 'MLUIColorAdditions'
end
