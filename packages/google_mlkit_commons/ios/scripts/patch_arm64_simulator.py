#!/usr/bin/env python3
"""Relabel the arm64 slice of Google ML Kit static frameworks to match the
build's target platform. Flips each arm64 Mach-O object's
LC_BUILD_VERSION.platform between 2 (iOS) and 7 (iOS Simulator) in place, so the
single arm64 slice Google ships works for whichever target is being built; no
instructions, symbols, sizes or offsets change. Idempotent and reversible. See
packages/google_mlkit_commons/README.md (iOS section).

Run from an Xcode build phase:
  patch_arm64_simulator.py --platform "$PLATFORM_NAME" --pods-root "$SRCROOT"
"""

import argparse
import glob
import mmap
import os
import struct
import sys

FAT_MAGIC      = 0xCAFEBABE
FAT_MAGIC_64   = 0xCAFEBABF
MH_MAGIC_64    = 0xFEEDFACF
LC_BUILD_VERSION = 0x32
PLATFORM_IOS = 2
PLATFORM_IOS_SIMULATOR = 7
CPU_TYPE_ARM64 = 0x0100000c

PLATFORM_BY_SDK = {
    'iphoneos': PLATFORM_IOS,
    'iphonesimulator': PLATFORM_IOS_SIMULATOR,
}


def _relabel_macho(buf, base, target_platform):
    """Flip LC_BUILD_VERSION.platform of the Mach-O object at ``base`` in place.
    Returns True only when a byte was actually changed."""
    if base + 32 > len(buf):
        return False
    if struct.unpack_from('<I', buf, base)[0] != MH_MAGIC_64:
        return False
    cputype, _cpusub, _filetype, ncmds, sizeofcmds, _flags, _reserved = \
        struct.unpack_from('<iIIIIII', buf, base + 4)
    if cputype != CPU_TYPE_ARM64:
        return False
    offset = base + 32
    end = min(base + 32 + sizeofcmds, len(buf))
    for _ in range(ncmds):
        if offset + 8 > end:
            break
        cmd, cmdsize = struct.unpack_from('<II', buf, offset)
        if cmdsize < 8 or offset + cmdsize > end:
            break
        if cmd == LC_BUILD_VERSION:
            if offset + 12 <= end:
                platform = struct.unpack_from('<I', buf, offset + 8)[0]
                if platform in (PLATFORM_IOS, PLATFORM_IOS_SIMULATOR) \
                        and platform != target_platform:
                    struct.pack_into('<I', buf, offset + 8, target_platform)
                    return True
            return False
        offset += cmdsize
    return False


def _relabel_archive_region(buf, start, size, target_platform):
    """Relabel every arm64 Mach-O member of the ``ar`` archive (or the single
    Mach-O object) occupying ``buf[start:start+size]``. Returns the count."""
    region_end = min(start + size, len(buf))
    if buf[start:start + 8] != b'!<arch>\n':
        return 1 if _relabel_macho(buf, start, target_platform) else 0
    pos = start + 8
    n = 0
    while pos + 60 <= region_end:
        try:
            member_size = int(
                bytes(buf[pos + 48:pos + 58]).decode('ascii', 'replace').strip())
        except ValueError:
            break
        name = bytes(buf[pos:pos + 16]).rstrip()
        body = pos + 60
        obj = body
        if name.startswith(b'#1/'):  # BSD long-name extension
            try:
                obj = body + int(name[3:])
            except ValueError:
                obj = body
        if _relabel_macho(buf, obj, target_platform):
            n += 1
        pos = body + member_size + (member_size & 1)  # 2-byte alignment
    return n


def _relabel_buffer(buf, target_platform):
    if len(buf) < 8:
        return 0
    fat_magic = struct.unpack_from('>I', buf, 0)[0]
    if fat_magic in (FAT_MAGIC, FAT_MAGIC_64):
        nfat = struct.unpack_from('>I', buf, 4)[0]
        is64 = fat_magic == FAT_MAGIC_64
        entry = 8
        n = 0
        for _ in range(nfat):
            if is64:
                if entry + 32 > len(buf):
                    break
                cputype, _cpusub, offset, size = struct.unpack_from('>iIQQ', buf, entry)
                entry += 32
            else:
                if entry + 20 > len(buf):
                    break
                cputype, _cpusub, offset, size, _align = \
                    struct.unpack_from('>iIIII', buf, entry)
                entry += 20
            if cputype == CPU_TYPE_ARM64:
                n += _relabel_archive_region(buf, offset, size, target_platform)
        return n
    if struct.unpack_from('<I', buf, 0)[0] == MH_MAGIC_64 \
            or buf[0:8] == b'!<arch>\n':
        return _relabel_archive_region(buf, 0, len(buf), target_platform)
    return 0


def _relabel_file(path, target_platform):
    if os.path.getsize(path) == 0:
        return 0
    with open(path, 'r+b') as f:
        with mmap.mmap(f.fileno(), 0) as buf:
            n = _relabel_buffer(buf, target_platform)
            if n:
                buf.flush()
    return n


def _find_framework_binary(pod_dir):
    fw_dir = os.path.join(pod_dir, 'Frameworks')
    if not os.path.isdir(fw_dir):
        return None
    for name in os.listdir(fw_dir):
        if name.endswith('.framework'):
            base = name[:-len('.framework')]
            binary = os.path.join(fw_dir, name, base)
            if os.path.isfile(binary):
                return binary
    return None


def _iter_framework_binaries(pods_root):
    for pattern in ('MLKit*', 'MLImage*'):
        for pod_dir in sorted(glob.glob(os.path.join(pods_root, pattern))):
            if os.path.isdir(pod_dir):
                binary = _find_framework_binary(pod_dir)
                if binary:
                    yield binary


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--platform', default=os.environ.get('PLATFORM_NAME', ''))
    parser.add_argument('--pods-root', required=True)
    args = parser.parse_args(argv)

    target_platform = PLATFORM_BY_SDK.get(args.platform)
    if target_platform is None:
        print(f'[ml_kit] skipping arm64 relabel: platform {args.platform!r} is '
              'not iphoneos/iphonesimulator', file=sys.stderr)
        return 0

    binaries = list(_iter_framework_binaries(args.pods_root))
    if not binaries:
        print('[ml_kit] ERROR: no ML Kit framework binaries found under '
              f'{args.pods_root!r}; arm64 slice not relabeled', file=sys.stderr)
        return 1

    total = sum(_relabel_file(b, target_platform) for b in binaries)
    if total:
        print(f'[ml_kit] relabeled {total} arm64 object(s) for {args.platform}')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main(sys.argv[1:]))
    except Exception as exc:  # surface a tagged, actionable build-phase error
        print(f'[ml_kit] ERROR: arm64 relabel failed: {exc}', file=sys.stderr)
        sys.exit(1)
