require 'rubygems'
begin
  require 'bundler'
  require 'date'
  begin
    Bundler.setup
    require 'plist'
    require 'xctasks/test_task'
  rescue Bundler::GemNotFound => gemException
    raise LoadError, gemException.to_s
  end
rescue LoadError => exception
  unless ARGV.include?('init')
    puts "Rescued exception: #{exception}"
    puts "WARNING: Failed to load dependencies: Is the project initialized? Run `rake init`"
  end
end

# Enable realtime output under Jenkins
if ENV['JENKINS_HOME']
  STDOUT.sync = true
  STDERR.sync = true
end

if defined?(XCTasks)
  XCTasks::TestTask.new do |t|
    t.workspace = 'LayerSample.xcworkspace'
    t.schemes_dir = 'Tests/Schemes'
    t.runner = :xcpretty
    t.output_log = 'xcodebuild.log'
    t.settings["LAYER_TEST_HOST"] = (ENV['LAYER_TEST_HOST'] || 'localhost')
    t.subtasks = { app: 'LayerSampleTests' }
  end
end

task :init do
  puts green("Update submodules...")
  run("git submodule update --init --recursive")
  puts green("Checking for Homebrew...")
  run("which brew > /dev/null && brew update; true")
  run("which brew > /dev/null || ruby -e \"$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)\"")
  puts green("Bundling Homebrew packages...")
  packages = %w{rbenv ruby-build rbenv-gem-rehash rbenv-binstubs xctool thrift}
  packages.each { |package| run("brew install #{package} || brew upgrade #{package}") }
  puts green("Checking rbenv version...")
  run("rbenv version-name || rbenv install")
  puts green("Checking for Bundler...")
  run("rbenv whence bundle | grep `cat .ruby-version` || rbenv exec gem install bundler")
  puts green("Bundling Ruby Gems...")
  run("rbenv exec bundle install --binstubs .bundle/bin --quiet")
  puts green("Ensuring Layer Specs repository")
  run("[ -d ~/.cocoapods/repos/layer ] || rbenv exec bundle exec pod repo add layer git@github.com:layerhq/cocoapods-specs.git")
  puts green("Ensuring Layer Release Specs repository")
  run("[ -d ~/.cocoapods/repos/layer-releases ] || rbenv exec bundle exec pod repo add layer-releases git@github.com:layerhq/releases-cocoapods.git")
  puts green("Installing CocoaPods...")
  run("rbenv exec bundle exec pod install --verbose")
  puts green("Checking rbenv configuration...")
  system <<-SH
  if [ -f ~/.zshrc ]; then
    grep -q 'rbenv init' ~/.zshrc || echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.zshrc
  else
    grep -q 'rbenv init' ~/.bash_profile || echo 'eval "$(rbenv init - --no-rehash)"' >> ~/.bash_profile
  fi
  SH
  puts "\n" + yellow("If first initialization, load rbenv by executing:")
  puts grey("$ `eval \"$(rbenv init - --no-rehash)\"`")
end

desc "Builds and pushes a new release to Hockey App"
task :release do
  # 0) Check for bad directory state.
  dirty_git = `git diff --name-only | grep -v Podfile | grep -v Rakefile | wc -l |  awk '{print $1}'`.chomp != "0"

  if dirty_git
    abort("Unable to build: The release process must be done with a clean directory. Perhaps you could `git stash`?")
  end

  # Clear Pods out
  # run "rm -rf Pods"
  # run "pod install"

  # 1) Generate objects with: builder name/email (via git config), short-sha
  require 'yaml'
  require 'byebug'
  lockfile = YAML.load_file('Podfile.lock')
  layer_kit_version = nil
  lockfile['PODS'].detect do |entry|
    if entry.kind_of?(String) && entry =~ /^LayerKit/
      layer_kit_version = entry.match(/LayerKit \(([\d\.\-\w]+)\)/)[1]
    elsif entry.kind_of?(Hash) && entry.keys[0] =~ /^LayerKit/
      layer_kit_version = entry.keys[0].match(/LayerKit \(([\d\.\-\w]+)\)/)[1]
    end
  end

  short_sha = `git rev-parse --short HEAD`.strip
  builder_name = `git config --get user.name`.strip
  builder_email = `git config --get user.email`.strip

  # 2) Insert generated object into Info.plist.

  plist_path = 'Resources/LayerSample-Info.plist'

  info_plist = Plist::parse_xml(plist_path)
  info_plist['LYRBuildInformation'] = {
    'LYRBuildLayerKitVersion' => layer_kit_version,
    'LYRBuildShortSha' => short_sha,
    'LYRBuildBuilderName' => builder_name,
    'LYRBuildBuilderEmail' => builder_email
  }

  # 3) Set the bundle version to the current timestamp.
  info_plist['CFBundleVersion'] = Time.now.to_i.to_s

  # Write the plist.
  File.open(plist_path, 'w') { |file| file.write(info_plist.to_plist) }

  archive_path = 'LayerSample.xcarchive'

  xcpretty_params = (ENV['LAYER_XCPRETTY_PARAMS'] || '')

  # 3.5) Move the shared scheme into the workspace directory.
  FileUtils::Verbose.mkdir_p "LayerSample.xcworkspace/xcshareddata/xcschemes"
  FileUtils::Verbose.cp Dir.glob("Schemes/*.xcscheme"), "LayerSample.xcworkspace/xcshareddata/xcschemes"

  # 4) Archive project with shenzhen, but pipe to xcpretty.
  run("ipa build --workspace LayerSample.xcworkspace --scheme LayerSample --configuration Release --verbose | xcpretty #{xcpretty_params} && exit ${PIPESTATUS[0]}")

  # 5) Upload to HockeyApp.net via shenzhen.
  run("ipa distribute:hockeyapp --token 4293de2a6ba5492c9d77b6faaf8d5343 -m \"Build of #{short_sha} by #{builder_name} (#{builder_email}).\"")
  #run("ipa distribute:hockeyapp --token 4293de2a6ba5492c9d77b6faaf8d5343 --tags dev -m \"Build of #{short_sha} by #{builder_name} (#{builder_email}).\"")

  # 6) Reset Info.plist.
  run("git checkout -- Resources/LayerSample-Info.plist")

  # 7) Clean up build data.
  FileUtils::Verbose.rm "LayerSample.ipa"
  FileUtils::Verbose.rm "LayerSample.app.dSYM.zip"
end

# Safe to run when Bundler is not available
def with_clean_env(&block)
  if defined?(Bundler)
    Bundler.with_clean_env(&block)
  else
    yield
  end
end

def run(command)
  puts "Executing `#{command}`"
  unless with_clean_env { system(command) }
    fail("Command exited with non-zero exit status (#{$?}): `#{command}`")
  end
end

def green(string)
 "\033[1;32m* #{string}\033[0m"
end

def yellow(string)
 "\033[1;33m>> #{string}\033[0m"
end

def grey(string)
 "\033[0;37m#{string}\033[0m"
end
