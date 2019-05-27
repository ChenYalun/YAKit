#
# Be sure to run `pod lib lint YAKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YAKit'
  s.version          = '0.1.0'
  s.summary          = 'YAKit'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    The Basic components.
                       DESC

  s.homepage         = 'https://github.com/ChenYalun/YAKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChenYalun' => 'iChenyalun@gmail.com' }
  s.source           = { :git => 'https://github.com/ChenYalun/YAKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://weibo.com/icqk'

  s.ios.deployment_target = '10.0'

  # s.source_files = 'YAKit/Classes/**/*'

  s.subspec 'Category' do |c|
    c.source_files = 'YAKit/Classes/Category/**/*'
    # c.dependency 'LibPrivate/Classes/Network'
    # c.public_header_files = './**/*.h'
    # c.resource = './**/*.{.bundle,nib,xib}'
  end

  s.subspec 'General' do |g|
    g.source_files = 'YAKit/Classes/General/**/*'
  end

  s.subspec 'Utility' do |u|
    u.source_files = 'YAKit/Classes/Utility/**/*'
    u.dependency 'AFNetworking'
  end

  s.subspec 'ThirdParty' do |tp|
    tp.source_files = 'YAKit/Classes/ThirdParty/**/*'
  end

  # s.resource_bundles = {
  #   'YAKit' => ['YAKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
