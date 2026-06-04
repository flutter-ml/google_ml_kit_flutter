# Opt-in Podfile helper that lets Google ML Kit pods build for Apple Silicon
# iOS 26+ simulators. See packages/google_mlkit_commons/README.md (iOS
# section) for rationale and usage. Upstream Google bug:
# https://issuetracker.google.com/issues/178965151

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
