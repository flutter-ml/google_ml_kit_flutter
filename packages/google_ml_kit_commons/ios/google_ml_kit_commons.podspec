#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_ml_kit_commons.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_ml_kit_commons'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin with commons files to implement google\'s standalone ml kit made for mobile platform.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'https://github.com/fbernaly/google-ml-kit-commons'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'fbernaly' => 'https://github.com/fbernaly' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/MLKitCore', '~> 2.2.0'
  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
