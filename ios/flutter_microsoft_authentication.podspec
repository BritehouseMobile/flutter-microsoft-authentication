#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_microsoft_authentication'
  s.version          = '0.0.3'
  s.summary          = 'Flutter Wrapper for Microsoft Authentication Library'
  s.description      = <<-DESC
Flutter Wrapper for Microsoft Authentication Library.
https://github.com/AzureAD/microsoft-authentication-library-for-objc
                       DESC
  s.homepage         = 'https://www.britehouse.co.za'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Britehouse Mobility' => 'gerrit.vanhuyssteen@britehouse.co.za' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MSAL', '~> 1.0.3'
  s.ios.deployment_target = '11.0'
end

