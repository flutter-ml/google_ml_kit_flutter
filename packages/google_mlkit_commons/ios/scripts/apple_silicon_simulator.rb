# Helper to make Google ML Kit pods build for Apple Silicon iOS Simulators.
#
# Why this exists
# ---------------
# The frameworks Google publishes under the `GoogleMLKit/*` CocoaPods only ship
# `arm64-iphoneos` and `x86_64-iphonesimulator` slices. Their podspecs set
# `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`, which on Apple Silicon Macs
# running iOS 26+ simulators (where Rosetta is not available by default)
# breaks `flutter run` with:
#
#     Unable to find a destination matching the provided destination specifier
#
# Until Google publishes proper `arm64-iphonesimulator` slices (tracked in
# https://issuetracker.google.com/issues/178965151), this helper applies a
# well-known workaround at `pod install` time:
#
#   1. Re-labels the `arm64` device slice of every ML Kit framework binary
#      as iOS Simulator (only the 4-byte `LC_BUILD_VERSION.platform` field is
#      modified — same approach the `arm64-to-sim` tool uses).
#   2. Strips `EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64` from the
#      generated xcconfig files so the user's app target is allowed to build
#      for `arm64-iphonesimulator`.
#
# This is opt-in. Add a single line inside your existing `post_install` block:
#
#     require File.expand_path(
#       '.symlinks/plugins/google_mlkit_commons/ios/scripts/apple_silicon_simulator',
#       __dir__,
#     )
#     post_install do |installer|
#       # ...your existing post_install code...
#       mlkit_apple_silicon_simulator_patch(installer)
#     end
#
# Notes
# -----
# * Idempotent: running `pod install` multiple times is safe (the patcher
#   skips slices that already report platform=iOS Simulator).
# * Affects only the simulator build. Device builds are untouched.
# * Modifies vendored binaries inside `Pods/` only; nothing in your app or in
#   pub.dev caches is altered.

def mlkit_apple_silicon_simulator_patch(installer)
  pods_dir = File.expand_path(installer.sandbox.root.to_s)
  patcher  = File.expand_path('patch_arm64_simulator.py', __dir__)

  framework_dirs = Dir.glob(File.join(pods_dir, '{MLKit*,MLImage*}'))
                      .select { |d| File.directory?(d) }
  unless framework_dirs.empty?
    Pod::UI.puts ''
    Pod::UI.puts "[ml_kit] Patching #{framework_dirs.size} ML Kit " \
                 'framework(s) for Apple Silicon iOS Simulator...'
    unless system('python3', patcher, *framework_dirs)
      Pod::UI.warn '[ml_kit] arm64 simulator patcher failed; ' \
                   'simulator build may still require Rosetta.'
    end
  end

  excluded = 'EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64'
  Dir.glob(File.join(pods_dir, 'Target Support Files', '**', '*.xcconfig'))
     .each do |xcconfig|
    text = File.read(xcconfig)
    new_text = text.lines.reject { |l| l.strip == excluded }.join
    File.write(xcconfig, new_text) if text != new_text
  end
end
