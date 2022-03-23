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
  s.authors          = 'Multiple Authors'
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'google_ml_kit_commons'
  # mlkit vision
  s.dependency 'GoogleMLKit/ImageLabeling', '~> 2.2.0'
  s.dependency 'GoogleMLKit/ImageLabelingCustom', '~> 2.2.0'
  s.dependency 'GoogleMLKit/LinkFirebase', '~> 2.2.0'
  s.dependency 'GoogleMLKit/TextRecognition', '~> 2.2.0'
  s.dependency 'GoogleMLKit/DigitalInkRecognition', '~> 2.2.0'
  # mlkit nlp
  s.dependency 'GoogleMLKit/LanguageID', '~> 2.2.0'
  s.platform                = :ios, '10.0'
  s.ios.deployment_target   = '10.0'
  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
