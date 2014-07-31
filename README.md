layer-sample-ios
================

This is the repository for the internal iOS sample messaging app

Releasing
=========

Releasing the sample is a matter of performing `rake init` to prepare the environment and `rake release` to build, package and upload to HockeyApp. 

The release task must take place from within a completely clean GIT directory. The Info.plist for the LayerSample app is modified to make the `CFBundleVersion` the current timestamp and add a dictionary on the key `LYRBuildInformation` that includes the following key/values:

| Key                       | Value                                                          |
|---------------------------|----------------------------------------------------------------|
| `LYRBuildLayerKitVersion` | The version number of LayerKit included in the app.            |
| `LYRBuildShortSha`        | The short sha of the commit used to build the version.         |
| `LYRBuildBuilderName`     | The builder's name, taken from `git config --get user.name`    |
| `LYRBuildBuilderEmail`    | The builder's email, taken from `git config --get user.email`  |
