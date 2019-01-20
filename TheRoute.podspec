#
# Be sure to run `pod lib lint TheRoute.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'TheRoute'
    s.version          = '0.8.0'
    s.summary          = '一个弱耦合的路由框架，支持OC,Swift。'
    
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = <<-DESC
    通过继承协议来使用路由提供的功能。能够根据规则自动注册短路由，也可以通过配置文件过滤器来配置具体的路由处理规则及短路间关系映射。
    DESC
    
    s.homepage         = 'https://github.com/DacianSky/TheRoute'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'TheMe' => 'sdqvsqiu@gmail.com' }
    s.source           = { :git => 'https://github.com/DacianSky/TheRoute.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '8.0'
    
    s.source_files = 'TheRoute/Classes/**/*'
    
    s.resource_bundles = {
        'TheRoute' => ['TheRoute/Assets/**']
    }
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    # s.dependency 'AFNetworking', '~> 2.3'
end
