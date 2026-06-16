#!/usr/bin/env python3
import hashlib
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROJECT_PBX = ROOT / 'packages' / 'example' / 'ios' / 'Runner.xcodeproj' / 'project.pbxproj'
PACKAGE_DIR = ROOT / 'packages'

# Find all local SPM packages under packages/*/ios/*/Package.swift
packages = []
for p in PACKAGE_DIR.glob('*'):
    ios_dir = p / 'ios'
    if ios_dir.exists():
        for pkg in ios_dir.glob('*'):
            pkg_file = pkg / 'Package.swift'
            if pkg_file.exists():
                # relative path from example/ios
                rel = os.path.relpath(pkg, ROOT / 'packages' / 'example' / 'ios')
                packages.append((pkg, rel.replace('\\', '/')))

if not packages:
    print('No local package.swift files found to add.')
    exit(0)

print(f'Found {len(packages)} packages to add.')

# Helper to make 24-hex id from string
def id_for(s):
    h = hashlib.sha1(s.encode('utf-8')).hexdigest().upper()
    return h[:24]


# Parse product name from Package.swift (very naive: find .library(name: "...") or name: "..." in product)
def parse_product_name(pkg_path: Path):
    content = (pkg_path / 'Package.swift').read_text()
    m = re.search(r"\.library\(\s*name:\s*\"([^\"]+)\"", content)
    if m:
        return m.group(1)
    m2 = re.search(r"name:\s*\"([^\"]+)\"", content)
    if m2:
        return m2.group(1)
    # fallback to directory name
    return pkg_path.name


proj_text = PROJECT_PBX.read_text()
backup_path = PROJECT_PBX.with_suffix('.pbxproj.backup')
PROJECT_PBX.with_suffix('.pbxproj.backup').write_text(proj_text)
print('Backup written to', backup_path)


# Build entries
local_entries = []
product_entries = []
package_ref_comments = []
product_dep_ids = []
for pkg_path, rel in packages:
    pkg_id = id_for('LOCALPKG:' + rel)
    product_id = id_for('PKGPROD:' + rel)
    product_name = parse_product_name(pkg_path)
    local_entries.append((pkg_id, rel, Path(rel).name))
    product_entries.append((product_id, product_name))
    package_ref_comments.append((pkg_id, Path(rel).name))
    product_dep_ids.append(product_id)


# Insert local package references and product entries into objects
insert_point = proj_text.rfind('\n\t};\n\trootObject')
if insert_point == -1:
    insert_point = proj_text.rfind('\n\t\t};\n\t\trootObject')
if insert_point == -1:
    print('Could not find insertion point in project.pbxproj; aborting.')
    exit(1)

insertion = '\n\n\t\t/* Begin XCLocalSwiftPackageReference section (added by script) */\n'
for pkg_id, rel, name in local_entries:
    insertion += (
        f"\t\t{pkg_id} /* XCLocalSwiftPackageReference \"{name}\" */ = {{\n"
        f"\t\t\tisa = XCLocalSwiftPackageReference;\n"
        f"\t\t\trelativePath = \"{rel}\";\n"
        f"\t\t}};\n"
    )
insertion += '\t\t/* End XCLocalSwiftPackageReference section */\n\n'

insertion += '\t\t/* Begin XCSwiftPackageProductDependency section (added by script) */\n'
for product_id, product_name in product_entries:
    insertion += (
        f"\t\t{product_id} /* {product_name} */ = {{\n"
        f"\t\t\tisa = XCSwiftPackageProductDependency;\n"
        f"\t\t\tproductName = \"{product_name}\";\n"
        f"\t\t}};\n"
    )
insertion += '\t\t/* End XCSwiftPackageProductDependency section */\n'

new_proj_text = proj_text[:insert_point] + insertion + proj_text[insert_point:]


# Update packageReferences array in PBXProject section
m = re.search(r'(packageReferences = \()([\s\S]*?)(\)\s*;)', new_proj_text)
if not m:
    print('Could not find packageReferences array; aborting.')
    exit(1)

before = new_proj_text[:m.start(2)]
existing = m.group(2)
after = new_proj_text[m.end(2):]
additions = ''
for pkg_id, name in package_ref_comments:
    additions += f"\n\t\t\t{pkg_id} /* XCLocalSwiftPackageReference \"{name}\" */,"
new_existing = existing + additions + '\n\t\t'
new_proj_text = before + new_existing + after


# Update Runner target.packageProductDependencies array
m2 = re.search(r'(97C146ED1CF9000F007C117D \*/ = \{[\s\S]*?packageProductDependencies = \()([\s\S]*?)(\)\s*;)', new_proj_text)
if not m2:
    m2 = re.search(r'(packageProductDependencies = \()([\s\S]*?)(\)\s*;)', new_proj_text)
    if not m2:
        print('Could not find packageProductDependencies array; aborting.')
        exit(1)

before2 = new_proj_text[:m2.start(2)]
existing2 = m2.group(2)
after2 = new_proj_text[m2.end(2):]
additions2 = ''
for pid in product_dep_ids:
    additions2 += f"\n\t\t\t{pid} /* {pid} */,\n"
new_existing2 = existing2 + additions2 + '\t\t'
new_proj_text = before2 + new_existing2 + after2


# Write modified project file (after backup already created)
PROJECT_PBX.write_text(new_proj_text)
print('project.pbxproj updated. Now resolving package dependencies with xcodebuild...')


# Run xcodebuild to resolve package dependencies
os.chdir(ROOT / 'packages' / 'example' / 'ios')
ret = os.system('xcodebuild -resolvePackageDependencies -project Runner.xcodeproj')
if ret != 0:
    print('xcodebuild failed to resolve packages; please inspect project.pbxproj backup and project file.')
else:
    print('xcodebuild resolved packages successfully (or at least returned 0).')

print('Done.')


