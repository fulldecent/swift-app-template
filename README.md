# Counter

> [!TIP]
> This template is a starting point you can use for every Swift app. We offer:
>
> - An Xcode app that builds and tests on a GitHub-hosted Mac
> - `swift format`, Prettier and markdownlint in continuous integration
> - Automated version pull requests with [Release Please](.github/workflows/release.yml)
> - TestFlight on every push to `main`, and App Store review when that pull request merges
>
> What is in-scope for this template?
>
> We the people who ship Swift apps, in order to keep signing, screenshots and version numbers from becoming a private folklore, maintain this starting point for all apps.
>
> This swift-app-template must remain broad. It covers an iOS and macOS app with one scheme. It does not cover a Swift package. A package belongs in the [Swift 6 module template](https://github.com/fulldecent/swift6-module-template).
>
> We do not specify that GitHub and GitHub Actions are the only way to host projects. Others may consider our GitHub-specific notes as a starting point for implementing outside of GitHub.
>
> And now below is the template, shown for a specific hypothetical project, enjoy!

[![Build and test](https://github.com/fulldecent/swift-app-template/actions/workflows/build-test.yml/badge.svg)](https://github.com/fulldecent/swift-app-template/actions/workflows/build-test.yml) [![Lint](https://github.com/fulldecent/swift-app-template/actions/workflows/lint.yml/badge.svg)](https://github.com/fulldecent/swift-app-template/actions/workflows/lint.yml)

Tap the screen. The number goes up.

Counter is a small iOS and macOS app. One tap adds one. That is the whole product, so the repository can spend its attention on how the app is built and shipped.

> [!NOTE]
> Replace the project name, description and badge URLs with your own. Show what your project does before asking people to read further.

## Installation

Counter is a sample. It is not on the App Store. Open [Counter.xcodeproj](Counter.xcodeproj) in Xcode 26 or later and run the Counter scheme.

You will need a Mac with Xcode 26 or later. The deployment target is iOS 26.0 and macOS 26.0.

> [!NOTE]
> For an app you publish, replace this section with the App Store links. People installing the app do not need Xcode.

## Development

Thank you for taking an interest in improving Counter.

Work from the project directory. The view is in [Counter/ContentView.swift](Counter/ContentView.swift). The count is in [Counter/CounterModel.swift](Counter/CounterModel.swift).

### Testing

All project updates that we release must conform to our test suite. GitHub Actions runs the checks on pull requests, and again from the release workflow on `main`. You can run them locally before sending proposed changes.

Format the Swift files, then test on the iPhone 17 simulator:

```sh
swift format format --in-place --recursive Counter CounterTests
xcodebuild test \
  -project Counter.xcodeproj \
  -scheme Counter \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=27.0' \
  CODE_SIGNING_ALLOWED=NO
```

`CODE_SIGNING_ALLOWED=NO` is for a machine that does not have a provisioning profile for this bundle id. A local run signed with your own team can omit it. `xcrun swift test` builds a Swift package. This repository is an Xcode app, so the command is `xcodebuild test`.

With an actively maintained version of Node.js installed, correct other formatting issues before sending proposed changes:

```sh
npx prettier@latest --check . --write
npx markdownlint-cli@latest "**/*.md" --fix
```

### Releasing

Use `fix:`, `feat:` or `BREAKING CHANGE:` in your commit messages. This triggers our bot to make a release draft pull request. `ci:` and `chore:` do not. Merging that pull request is what ships a new App Store version. You do not edit [VERSION](VERSION) or the marketing version by hand.

Every push to `main` runs the tests. When the App Store secrets below are set, that push also uploads an iOS build and a macOS build to TestFlight and distributes both to the internal group App Store Connect Users. That group belongs to this app. Add each Apple ID to the group for this app. The build shows up after that person accepts the invitation. The account holder is not added by the upload.

The marketing version comes from [VERSION](VERSION). When that version is already on sale, the upload uses the next patch number and does not commit it. Apple rejects a new build on a closed train (altool 90186). The review submission uses that uploaded version, which the TestFlight job passes through. The build number is one higher than the newest TestFlight build on either platform and is not committed.

Release Please opens its pull request as `github-actions`. GitHub holds the checks on that pull request until a person approves the workflow run. Approving it lets the checks run. Merging it is still a separate step.

Store text lives in [fastlane/metadata](fastlane/metadata) for iOS and [fastlane/metadata-macos](fastlane/metadata-macos) for macOS. The two folders are uploaded separately and may differ. Screenshots are generated for iPhone, iPad and Mac during a release and are not committed. A Mac screenshot is drawn by the app. The runner cannot see another app's window, and `-AppleLanguages` does not change `Locale.current` for that process, so the view reads `-AppleLocale`. What's New is the newest section of [CHANGELOG.md](CHANGELOG.md).

App Privacy, and whether the app uses the Advertising Identifier, are answered in App Store Connect. They are not files in this repository. fastlane 2.240 sends the encryption answer and the third-party content answer. A new app needs the App Store Connect answers filled in before the first review submission. An app that already has them keeps those answers.

[fastlane/Fastfile](fastlane/Fastfile) strips `/opt/homebrew` and `/usr/local` from `PATH` before `xcodebuild -exportArchive`. Xcode's IPA export calls `rsync -E`, and Homebrew's `rsync` rejects that flag ("Copy failed").

Replace `BUNDLE_ID`, `TEAM_ID` and `INSTALLER_CERT_NAME` at the top of the Fastfile, and the same bundle id and team in [fastlane/Appfile](fastlane/Appfile) and the Xcode project, before the first upload. The lanes refuse to run while those values are still the samples.

The same lanes can be run locally after `bundle install` with Ruby from [.ruby-version](.ruby-version) and a gitignored `fastlane/api_key.json` (`key_id`, `issuer_id`, `key_filepath`). The distribution certificate has to be in the keychain.

```sh
bundle exec fastlane ship_testflight
bundle exec fastlane generate_screenshots
bundle exec fastlane upload_screenshots
bundle exec fastlane submit_app_store build_number:123
```

`gh workflow run release.yml --ref main -f screenshots=true` generates the screenshots, uploads them for the TestFlight version, and uploads a new iOS and Mac build. It does not submit for review.

This template repository does not set the App Store secrets, so its own release workflow tests the app and skips the upload. A repository created from the template adds the secrets and the upload runs.

> [!NOTE]
> In your GitHub repository settings, under Actions, General, Workflow permissions, select read and write permissions and check "Allow GitHub Actions to create and approve pull requests". Sign the Apple Developer Program agreement. App Store Connect API calls fail until it is in effect.
>
> A repository created from this template starts with no tags and no releases. Release Please reads the latest tag on the default branch to choose the next version. A repository with no tag gets a first release pull request. The publish job accepts a tag shaped like `v1.2.3`.
>
> Set the starting tag on the current `main` commit when this repository should start at a version you already shipped. `v0.0.0` is the version Release Please counts forward from.
>
> ```sh
> gh api --method POST repos/{owner}/{repo}/git/refs \
>   -f ref="refs/tags/v0.0.0" \
>   -f sha="$(gh api repos/{owner}/{repo}/commits/main --jq .sha)"
> ```

#### Setup

1. GitHub repo > Settings > General > Releases > Enable release immutability.
1. GitHub repo > Settings > Actions > General > Workflow permissions: Read and write permissions. Check "Allow GitHub Actions to create and approve pull requests".
1. Sign the Apple Developer Program agreement.
1. Repository secrets:

   - `APP_STORE_CONNECT_KEY_ID`: App Store Connect API key id
   - `APP_STORE_CONNECT_ISSUER_ID`: issuer id
   - `APP_STORE_CONNECT_KEY`: contents of the AuthKey `.p8` file
   - `APP_STORE_DISTRIBUTION_P12`: base64 of an Apple Distribution PKCS12
   - `APP_STORE_DISTRIBUTION_P12_PASSWORD`: password for that PKCS12
   - `APP_STORE_MAC_INSTALLER_P12`: base64 of a Mac Installer Distribution PKCS12
   - `APP_STORE_MAC_INSTALLER_P12_PASSWORD`: password for that PKCS12

   The workflow creates the provisioning profiles at build time. Profiles are not stored. The API key needs App Manager access. `base64 < distribution.p12` is the value of `APP_STORE_DISTRIBUTION_P12`. The Mac package also needs the installer certificate, common name `3rd Party Mac Developer Installer: Name (TEAMID)`. Put that common name in `INSTALLER_CERT_NAME`.

### Maintenance

The project administrator completes these maintenance tasks each month. If they are 3+ months late, please remind them or send your own issue/pull request.

1. Review the runner in [.github/workflows/build-test.yml](.github/workflows/build-test.yml). The job uses the GitHub-hosted `xcode-27` image. The test destination is an iPhone 17 simulator on iOS 27.0, which that image lists for Xcode 27.0. The image contents are in the [Xcode 27 runner readme](https://github.com/actions/runner-images/blob/main/images/macos/xcode-27-arm64-Readme.md).
1. Review external actions in [.github/workflows](.github/workflows). GitHub-supported actions (under the actions/ organization) may require only cursory review.
1. Check whether the iPhone and iPad simulator names in [fastlane/Fastfile](fastlane/Fastfile) still exist on that image, and whether their pixel sizes are still accepted as App Store screenshots.

## Project scope

We are people who ship a small app to the App Store and want the next one to start from a known path.

Counter counts. The repository's job, beyond that, is the build, the test and the upload.

We specifically will not add a Swift package release, a Linux library or a second app target. watchOS and visionOS can live in an app target later. They are not separate App Store listings unless you create those listings.

## References

1. We use title case only for proper nouns, including the name of our project.
1. This project is built based on [best practices documented in project-template](https://github.com/fulldecent/project-template), release v1.4.1.
1. Continuous integration follows the shape of [rust-template](https://github.com/fulldecent/rust-template), release 1.1.0: a build-and-test workflow, a lint workflow and a release workflow. The test command is `xcodebuild`, because this is an app.
1. The upload rules in [fastlane/Fastfile](fastlane/Fastfile) are the ones confirmed while shipping [8 Ball Answer](https://github.com/fulldecent/8-ball-answer): altool rather than `upload_to_testflight`, the next patch when the live version is closed, one build number shared by iOS and macOS, manual profiles created at build time, a Mac package only when `sdk` is `macosx`, and screenshots drawn by the app because the runner cannot record another app's window.
1. Swift ignore rules come from [GitHub's Swift gitignore](https://github.com/github/gitignore/blob/main/Swift.gitignore) and [Xcode gitignore](https://github.com/github/gitignore/blob/main/Global/Xcode.gitignore).
1. This project is released under the [MIT license](LICENSE.md).

> [!NOTE]
> Carefully consider which license to apply to your project and replace the copyright line in [LICENSE.md](LICENSE.md). Cite the release of this template you used.
