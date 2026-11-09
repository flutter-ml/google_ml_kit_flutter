# Coding Rules for `google_ml_kit_flutter`

This repository is a multi-package **Flutter federated/modular plugin monorepo** providing Dart, Android (Kotlin), and iOS (Swift / SwiftPM) bindings for Google's standalone on-device ML Kit SDKs. It is **not** a consumer UI application:

- **`packages/google_mlkit_commons/`**: Shared primitives (`InputImage`, `ModelManager`, geometry/serialization helpers).
- **`packages/google_mlkit_*/`**: 21 standalone, individually published ML Kit feature plugins (Vision, Natural Language, Document Scanner, and GenAI). APIs unsupported by Google on iOS (`document_scanner`, `face_mesh_detection`, `subject_segmentation`, `genai_*`) still include lightweight iOS SwiftPM stub `FlutterPlugin` targets returning `FlutterMethodNotImplemented` so cross-platform Flutter apps build cleanly on iOS.
- **`packages/google_ml_kit/`**: Dart-only umbrella package re-exporting the plugins.
- **`packages/example/`**: Developer showcase and integration-test host app exercising the plugins on Android and iOS.
- **`scripts/`**: Repository-wide maintenance scripts (`analyze.sh`, `update_libs.sh`, `clean.sh`, `publish.sh`).

All AI agents and assistants must strictly follow these rules when writing code, reviewing PRs, refactoring, or responding to prompts.

---

## 1. Git Usage (Strict Ban on Modifying Git State)

- **Strict Ban on Modifying Git State:** AI agents must **NEVER** run `git stash`, `git add`, `git stage`, `git restore`, `git reset`, `git checkout`, `git commit`, or `git push` commands.
- **Zero Git Stashing:** Absolutely do **NOT** use `git stash` (or `git stash pop`, `git stash apply`, `git stash drop`).
- **Respect User's Staging:** If files are staged in the git index (`Changes to be committed`), assume they were staged intentionally by the user. **Never** run `git restore --staged` or attempt to unstage them.
- **User-Only Git Lifecycle:** Leave staging, unstaging, stashing, committing, pushing, and branching exclusively to the user. Agents may **only** run read-only git inspection commands (such as `git status`, `git diff`, `git log`, `git branch`).

---

## 2. Minimal Diffs (No Churn, No Unnecessary Complexity)

- **Do Not Reorder Existing Code:** When editing an existing Dart, Kotlin, Swift, Gradle, or YAML file, never move, reorder, or reformat methods, fields, or blocks unrelated to the change. Keep existing members in their original positions so the diff shows only the real changes.
- **Review Your Diff:** Before finishing, check `git diff` (read-only) and confirm there is no incidental churn (moved blocks, unrelated whitespace edits, or style-only renames).
- **Keep Plugin Dependencies Minimal:** Published plugins (`packages/google_mlkit_*` and `packages/google_ml_kit`) must remain lightweight for host apps. Do **NOT** add third-party runtime packages, code generation (`build_runner`, `freezed`, `json_serializable`), or UI/state-management packages to plugin `pubspec.yaml` dependencies unless explicitly requested.
- **Keep It Simple:** Prefer the smallest, simplest change that is correct and production-ready. Avoid speculative abstractions or extra wrappers unless a concrete requirement demands them.

---

## 3. Linting, Formatting & Static Analysis (Dart, Kotlin, Swift)

CI (`.github/workflows/code-analysis.yml`) and `.githooks/pre-commit` strictly enforce formatting and static analysis across all three languages:

- **Dart:**
  - Adhere to each package's `analysis_options.yaml` (`flutter_lints`).
  - Enforce `const` constructors and immutable `final` fields wherever possible on Dart option/configuration/result models (`prefer_const_constructors`, `prefer_const_literals_to_create_immutables`).
  - Verify with `dart format --output=none --set-exit-if-changed .` and `flutter analyze .` (zero errors or warnings).
- **Kotlin (Android):**
  - Adhere to `ktlint` and `.editorconfig` (`ktlint_standard_package-name = disabled` for underscored plugin package names).
  - Format and verify with `ktlint --format && ktlint`.
- **Swift (iOS & `Package.swift`):**
  - Adhere strictly to `.swiftlint.yml` (`swiftlint lint --strict` — **warnings are treated as errors** in CI and pre-commit).
  - Never leave trailing commas on Swift collection literals (`trailing_comma`) or empty blank lines before closing `]` / `}` (`vertical_whitespace_closing_braces`).
  - Format and verify with `swiftlint lint --fix && swiftlint lint --strict`.
- **Full Local Suite:** Run `./scripts/analyze.sh` to validate Dart, Kotlin, and Swift together before completing cross-cutting changes.

---

## 4. iOS Dependency Management (Swift Package Manager Exclusively)

- **SwiftPM Only (Zero CocoaPods):** All 22 plugins use Swift Package Manager (`packages/<plugin>/ios/<plugin>/Package.swift`). Do **NOT** add, generate, or commit CocoaPods files (`*.podspec`, `Podfile`, `Podfile.lock`, `Pods/`).
- **Mandatory `FlutterFramework` Dependency:** Every plugin's `Package.swift` must declare:
  - Package dependency: `.package(name: "FlutterFramework", path: "../FlutterFramework")`
  - Target dependency: `.product(name: "FlutterFramework", package: "FlutterFramework")`
- **Hosted (`pub.dev`) Layout Compatibility:** Never reference sibling monorepo packages via relative filesystem paths in `Package.swift` (e.g., `../../../../../google_mlkit_commons`), because published plugins are unpacked into separate versioned directories in `.pub-cache`. Keep each plugin's Swift target self-contained so it builds identically from both path dependencies and `pub.dev`.

---

## 5. Platform Channel Contracts & Native Resource Management

- **Cross-Platform Contract Parity:** MethodChannel names, method identifiers, serialized map keys, and error reporting must stay consistent across Dart (`lib/src/`), Android Kotlin (`android/src/main/kotlin/`), and iOS Swift (`ios/<plugin>/Sources/<plugin>/`).
- **Instance Lifecycle & `close()` Cleanup:** Detectors, recognizers, translators, and segmenters keyed by instance `id` in native plugin maps must always be properly released/removed when the `#close` method channel call is invoked to prevent native memory leaks.
- **Public Dart API Stability:** Treat exported classes, constructors, enums, and method signatures in `packages/google_mlkit_*/lib/` as public semver APIs—avoid breaking changes unless explicitly requested by the user.

---

## 6. No Console Noise in Published Plugins (Ban on `print()`)

- **Zero Raw Console Prints in Plugins:** Do **NOT** use `print()` or `debugPrint()` in Dart, `println()` in Kotlin, or `print()` / `NSLog()` in Swift inside published plugin packages (`packages/google_mlkit_*` and `packages/google_ml_kit`).
- **Structured Error Propagation:** Plugins must never spam host app logs or leak user text/image payloads to stdout/logcat. Always propagate errors back to Dart callers via `PlatformException` (`result.error(...)` on Android, `FlutterError(...)` on iOS).

---

## 7. Testing Policy (Do Not Add Tests Unless Explicitly Requested)

- **Zero Unprompted Tests:** Do **NOT** create, generate, or add new test files, scratch tests, unit tests, or integration tests unless explicitly instructed by the user. Never write temporary test files in the repo as an investigation technique.
- **Maintain Existing Tests:** Only update existing tests (`packages/*/test/` or `packages/example/integration_test/`) when a requested code change directly requires updating test expectations to stay green, or when explicitly asked.

---

## 8. Versioning, Changelogs & Release Discipline

- **Do Not Bump Versions Unprompted:** Do **NOT** modify `version:` in `pubspec.yaml`, cross-package version constraints, or `CHANGELOG.md` files during normal bugfix, feature, or chore tasks unless the user explicitly asks to prepare a release. Version bumps and changelog updates are batched in dedicated release commits/PRs.

