#
# Be sure to run `pod lib lint AYRecord.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AYRecord'
  s.version          = '1.0.2'
  s.summary          = 'Fast and convenient ORM framework, that is AYRecord.'

  s.homepage         = 'https://github.com/alan-yeh/AYRecord'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alan Yeh' => 'alan@yerl.cn' }
  s.source           = { :git => 'https://github.com/alan-yeh/AYRecord.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'AYRecord/Classes/**/*'
  #s.public_header_files = 'AYRecord/Classes/**/*'
  s.public_header_files = 'AYRecord/Classes/*.h', 'AYRecord/Classes/Container/*.h'
  s.libraries = 'sqlite3'
end
