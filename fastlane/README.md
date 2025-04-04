fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Push a new beta build to TestFlight

### ios release

```sh
[bundle exec] fastlane ios release
```

Push a new release build to the App Store

### ios flutter_screenshots

```sh
[bundle exec] fastlane ios flutter_screenshots
```

Generate screenshots using Flutter integration tests

----


## Android

### android beta

```sh
[bundle exec] fastlane android beta
```

Push a new beta build to Google Play

### android flutter_screenshots

```sh
[bundle exec] fastlane android flutter_screenshots
```

Generate screenshots using Flutter integration tests

### android release

```sh
[bundle exec] fastlane android release
```

Push a new release build to Google Play

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
