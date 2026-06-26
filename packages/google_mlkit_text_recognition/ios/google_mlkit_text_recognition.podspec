require 'yaml'

pubspec = YAML.load_file(File.join('..', 'pubspec.yaml'))
library_version = pubspec['version'].gsub('+', '-')

Pod::Spec.new do |s|
  s.name             = pubspec['name']
  s.version          = library_version
  s.summary          = pubspec['description']
  s.description      = pubspec['description']
  s.homepage         = pubspec['homepage']
  s.license          = { :file => '../LICENSE' }
  s.authors          = 'flutter-ml.dev'
  s.source           = { :path => '.' }
  s.source_files     = 'google_mlkit_text_recognition/Sources/google_mlkit_text_recognition/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'google_mlkit_commons'

  # ML Kit frameworks are resolved via SwiftPM (Package.swift)
  # using https://github.com/arrrrny/google-mlkit-swiftpm

  # Resource bundle cannot be included via SPM (see README of google-mlkit-swiftpm)
  # So we use CocoaPods just for the resource bundle
  s.resource_bundles = {
    'MLKitTextRecognitionResources' => ['MLKitTextRecognitionResources.bundle/**/*']
  }

  s.platform = :ios, '15.5'
  s.ios.deployment_target = '15.5'
  s.static_framework = true
  s.swift_version = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'OTHER_LDFLAGS' => '-ObjC -all_load'
  }
end
