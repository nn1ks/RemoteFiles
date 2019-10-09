#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'ssh'
  s.version          = '0.0.4'
  s.summary          = 'SSH and SFTP client for Flutter.'
  s.description      = <<-DESC
SSH and SFTP client for Flutter. Wraps iOS library NMSSH and Android library Jsch.
                       DESC
  s.homepage         = 'https://github.com/shaqian/flutter_ssh'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Qian Sha' => 'https://github.com/shaqian' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'NMSSH'
  
  s.ios.deployment_target = '8.0'
end

