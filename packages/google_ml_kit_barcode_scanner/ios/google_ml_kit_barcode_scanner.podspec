#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint google_ml_kit_barcode_scanner.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'google_ml_kit_barcode_scanner'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter Plugin for ML Kit - Barcode Scanner'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'GoogleMLKit/BarcodeScanning', '~> 2.2.0'
  s.dependency 'google_ml_kit_commons'
  s.platform = :ios, '10.0'
  s.ios.deployment_target = '10.0'
  s.static_framework = true
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
