# Layer Thrift Common

This repository contains the Thrift definitions for Layer services. These definitions are shared across the
Layer backend services and mobile client SDK's.

# Building a Release

If this is your first time building a release then you must have CocoaPods installed (`gem install cocoapods`)
and you must have configured the Layer specs repo: 
`[ -d ~/.cocoapods/repos/layer ] || pod repo add layer git@github.com:layerhq/cocoapods-specs.git`

1. Make your updates to the Thrift files in src.
2. Commit the new revision.
3. Tag the new revision (versions are like 0.50.0, 0.51.2, etc.)
4. Push the release tag to git: `git push origin master --tags`
5. Edit `layer-thrift.podspec` to include the new version.
6. Run lint on the podspec to verify its validity: `pod spec lint layer-thrift.podspec`
7. If lint is successful, push to the specs repo: `pod push layer layer-thrift.podspec`

Let the LayerKit team know that the new release is ready to be digested.
