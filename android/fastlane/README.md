fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android build_flutter

```sh
[bundle exec] fastlane android build_flutter
```

Build Flutter AAB ตาม flavor

### android upload_playstore

```sh
[bundle exec] fastlane android upload_playstore
```

อัปโหลด AAB ไป Google Play ตาม flavor (override track ได้)

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Build และ Upload Google Play (ระบุ flavor) (override track/target/build_number ได้)

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
