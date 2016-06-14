#
# Be sure to run `pod lib lint ImitateCommonLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "ImitateCommonLib"
  s.version          = "0.7.0"
  s.summary          = "A short description of ImitateCommonLib."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
		Let me add a long description for this pod lib,while i did not know to write.
		So, this is only a test for my self.
		Again,This is a meaningful description!!!!
                       DESC

  s.homepage         = "https://github.com/floiges/ImitateCommonLib"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "floiges" => "floiges@163.com" }
  s.source           = { :git => "https://github.com/floiges/ImitateCommonLib.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  
  s.resource_bundles = {
     'ImitateCommonLib' => ['Pod/**/*.{png,jpg,xib}']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.1.0'
  s.dependency 'FMDB', '~> 2.6.2'
  s.dependency 'BlocksKit', '~> 2.2.5'
end
