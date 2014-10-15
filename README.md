# layer-sample-ios

This is the repository for the internal iOS sample messaging app

## Developer Setup
 
### Install XCode

1. Go to AppStore.
2. Download XCode.

### Clone this repo

Clone this repo to your machine and don't forget to init and update the submodules currently included in the project.

```
git clone git@github.com:layerhq/layer-sample-ios.git
# checkout the branch you'll be working on if needed
# git checkout coleman-component-build
git pull && git submodule init && git submodule update && git submodule status
```

### Get dependencies

```
rake init
```

## Releasing

Releasing the sample is a matter of performing `rake init` to prepare the environment and `rake release` to build, package and upload to HockeyApp. 

The release task must take place from within a completely clean GIT directory. The Info.plist for the LayerSample app is modified to make the `CFBundleVersion` the current timestamp and add a dictionary on the key `LYRBuildInformation` that includes the following key/values:

| Key                       | Value                                                          |
|---------------------------|----------------------------------------------------------------|
| `LYRBuildLayerKitVersion` | The version number of LayerKit included in the app.            |
| `LYRBuildShortSha`        | The short sha of the commit used to build the version.         |
| `LYRBuildBuilderName`     | The builder's name, taken from `git config --get user.name`    |
| `LYRBuildBuilderEmail`    | The builder's email, taken from `git config --get user.email`  |
