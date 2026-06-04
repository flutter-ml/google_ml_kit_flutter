# Opt-in Podfile helper that lets Google ML Kit pods build and run on Apple
# Silicon iOS 26+ simulators *and* physical devices from the same Pods install.
# A per-build script phase relabels the arm64 slice to match the target, so no
# manual revert is ever needed. See packages/google_mlkit_commons/README.md
# (iOS section). Upstream Google bug:
# https://issuetracker.google.com/issues/178965151

require 'fileutils'

MLKIT_STATE_DIR  = 'MLKitAppleSiliconSimulator'.freeze
MLKIT_PATCHER    = 'patch_arm64_simulator.py'.freeze
MLKIT_PHASE_NAME = '[ML Kit] Relabel arm64 slice for current platform'.freeze
MLKIT_EXCLUDED_RE = /^(\s*EXCLUDED_ARCHS\[sdk=iphonesimulator\*\]\s*=\s*)(.*?)\s*$/

def mlkit_apple_silicon_simulator_patch(installer)
  pods_dir = File.expand_path(installer.sandbox.root.to_s)

  framework_dirs = Dir.glob(File.join(pods_dir, '{MLKit*,MLImage*}'))
                      .select { |d| File.directory?(d) }
  return if framework_dirs.empty?

  _mlkit_copy_patcher(pods_dir)
  _mlkit_strip_simulator_arm64_exclusion(pods_dir)
  _mlkit_install_build_phase(installer)
  installer.pods_project.save

  Pod::UI.puts ''
  Pod::UI.puts "[ml_kit] Apple Silicon simulator support enabled for " \
               "#{framework_dirs.size} framework(s) (auto-toggles per build)."
rescue => e
  raise "[ml_kit] failed to enable Apple Silicon simulator support: #{e.message}"
end

def _mlkit_copy_patcher(pods_dir)
  state_dir = File.join(pods_dir, MLKIT_STATE_DIR)
  FileUtils.rm_rf(state_dir)
  FileUtils.mkdir_p(state_dir)
  FileUtils.cp(File.expand_path(MLKIT_PATCHER, __dir__), state_dir)
end

def _mlkit_strip_simulator_arm64_exclusion(pods_dir)
  Dir.glob(File.join(pods_dir, 'Target Support Files', '**', '*.xcconfig'))
     .each do |xcconfig|
    changed = false
    new_text = File.read(xcconfig).each_line.map do |line|
      match = line.match(MLKIT_EXCLUDED_RE)
      next line unless match

      tokens = match[2].split(/\s+/).reject(&:empty?)
      next line unless tokens.include?('arm64')

      changed = true
      kept = tokens.reject { |t| t == 'arm64' }
      kept.empty? ? '' : "#{match[1]}#{kept.join(' ')}\n"
    end.join
    File.write(xcconfig, new_text) if changed
  end
end

def _mlkit_install_build_phase(installer)
  script = <<~SH
    set -euo pipefail
    : "${PLATFORM_NAME:?PLATFORM_NAME is not set}"
    : "${SRCROOT:?SRCROOT is not set}"
    /usr/bin/env python3 "${SRCROOT}/#{MLKIT_STATE_DIR}/#{MLKIT_PATCHER}" \\
      --platform "${PLATFORM_NAME}" \\
      --pods-root "${SRCROOT}"
  SH

  installer.aggregate_targets.each do |aggregate|
    target = installer.pods_project.targets.find { |t| t.name == aggregate.label }
    next unless target

    phase = target.shell_script_build_phases.find { |p| p.name == MLKIT_PHASE_NAME }
    phase ||= target.new_shell_script_build_phase(MLKIT_PHASE_NAME)
    phase.shell_path = '/bin/sh'
    phase.shell_script = script
    phase.always_out_of_date = '1' if phase.respond_to?(:always_out_of_date=)
  end
end
