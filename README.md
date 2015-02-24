# Atlas Messenger iOS

This repository contains the source code of Atlas Messenger, an example application built by [Layer](https://layer.com/) to showcase the capabilities of [Atlas](https://github.com/layerhq/Atlas-iOS), a library of robust communications user interface components integrated with the Layer platform.

## Getting Started

Atlas Messenger requires a Layer App ID in order to run. You can obtain an App ID by registering for a Layer account at [https://layer.com/signup](). Alternately, a pre-built version is available for testing by visiting [https://getatlas.layer.com/]().

### Building Atlas Messenger

To build Atlas Messenger, you need a few a few standard iOS Development Tools:

1. [Xcode](https://developer.apple.com/xcode/) - Apple's suite of iOS and OS X development tools. Available on the [App Store](http://itunes.apple.com/us/app/xcode/id497799835).
2. [CocoaPods](http://cocoapods.org/) - The dependency manager for Cocoa projects. CocoaPods is used to automate the build and configuration of Atlas Messenger. Available by executing `$ sudo gem install cocoapods` in your terminal.

**NOTE:** At this time there is a known incompatibility with CocoaPods v0.36.0.beta.2. Please stick to v0.35.0 or v0.36.0.beta.1 instead.

#### Cloning & Preparing the Project

Once you have installed the pre-requisites, you can proceed with cloning and configuring the project by executing the following commands in your terminal:

```sh
$ git clone https://github.com/layerhq/Atlas-Messenger-iOS.git
$ cd Atlas-Messenger-iOS
$ git submodule update --init
$ pod install
```

These commands will clone Atlas Messenger from Github, configure the Atlas submodule in the `Libraries` sub-directory, and then install all library dependencies via CocoaPods. Once these steps have completed without error, you can open the workspace by executing:

```sh
$ open "Atlas Messenger.xcworkspace"
```

#### Setting the App ID

Before running Atlas Messenger from source code you must configure the Layer App ID. To do so, switch to the Project Navigator by selecting the **View** menu > **Navigators** > **Show Project Navigator** (or type `⌘1`) and expand the items **Atlas Messenger** and **Code**. Tap on `ATLMAppDelegate.m` to open the application delegate code and locate the following code near the top of the file:

```objc
// TODO: Configure a Layer appID from https://developer.layer.com/dashboard
static NSString *const ATLMLayerAppID = nil;
```

Replace the `nil` with the appID you previously obtained from the Info section of the [Layer Developer Dashboard](https://developer.layer.com/dashboard). Be sure to enclose it in standard Objective-C string quotes (`@""`). Once configured your code should now look something like:

```objc
static NSString *const ATLMLayerAppID = @"035c3b96-ecb5-4642-b6b1-ff49ea2dd5db";
```

You can now proceed with building and running Atlas Messenger. Select **Run** from the **Product** menu (or type `⌘R`). After the build completes, Atlas Messenger will launch launch in your iOS Simulator.

## Getting Oriented

Atlas Messenger was designed to strike a balance between being simple enough to quickly peruse the project, but full-featured enough to fully demonstrate the power of Atlas and Layer. As you begin working with the example code, keep the following things in mind:

* [Layer](https://layer.com/) is a hosted communications platform. All communications services leveraged by Atlas Messenger utilize the backend services hosted by Layer.
* [LayerKit](https://github.com/layerhq/releases-ios) is the native iOS SDK for accessing the Layer communications platform. LayerKit handles the networking, persistence, security and synchronization necessary to implement robust native messaging. LayerKit also presents a programming model for accessing the Conversations and Messages that are transmitted through Layer.
* [Atlas](https://atlas.layer.com/) is a library of user interface components developed by Layer that provide fully integrated user interface experiences on top of LayerKit. Atlas has a direct dependency on LayerKit and is not usable standalone.

When working with the Atlas Messenger codebase you will encounter code coming from LayerKit (prefixed by `LYR`), Atlas (prefixed by `ATL`), and Atlas Messenger itself (prefixed by `ATLM`).

### Navigating the Project

The project is organized as detailed in the table below:

| Path                    			| Type                  | Contains                                                                   |
| -------------------------------|-----------------------|----------------------------------------------------------------------------|
| `Code`                  			| Directory             | Source code organized by type                                              |
| `Gemfile`               			| Ruby code             | Ruby Gem dependency declarations for Bundler                               |
| `Gemfile.lock`          			| ASCII text            | Exact Gem dependency manifest (generated by Bundler)                       |
| `LICENSE`               			| ASCII text            | Licensing details for the project                                          |
| `Libraries`             			| Directory             | Submodules and external project dependencies                               |
| `Podfile`               			| Ruby code             | CocoaPods library dependencies for the project                             |
| `Podfile.lock`          			| ASCII text            | Exact Pod dependency manifest (generated by CocoaPods)                     |
| `Pods`                  			| Directory             | CocoaPods generated artifacts. Ignored by Git.                             |
| `README.md`             			| Markdown text         | This comprehensive README file                                             |
| `Rakefile`              			| Ruby source           | Rake automation tasks                                                      |
| `Resources`             			| Directory             | Assets such images                                                         |
| `Atlas Messenger.xcodeproj` 		| Xcode Project         | The Xcode project for Atlas Messenger. Use the workspace instead.          |
| `Atlas Messenger.xcworkspace`  	| Xcode Workspace       | The Xcode workspace for Atlas Messenger. Used for day to day development.  |
| `Tests`                 			| Directory             | Test code for the application.                                             |
| `.ruby-version`         			| rbenv configuration   | Specifies the version of Ruby that rbenv will bind to                      |
| `xcodebuild.log`        			| Log file              | Log out xcodebuild output generated by test Rake tasks. Under .gitignore   |

Because Atlas Messenger is designed to showcase the capabilities of Atlas, most of the interesting code lives in `Code/Controllers` and `Code/Views`.


## License

Atlas Messenger is licensed under the terms of the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0.html). Please see the [LICENSE](LICENSE) file for full details.

## Contact

Atlas Messenger was developed in San Francisco by the Layer team. If you have any technical questions or concerns about this project feel free to reach out to [Layer Support](mailto:support@layer.com).

## Credits

* [Kevin Coleman](https://github.com/kcoleman731)
* [Klemen Verdnik](https://github.com/chipxsd)
* [Blake Watters](https://github.com/blakewatters)
