require 'rubygems'
begin
  require 'bundler'
  require 'bundler/setup'
  require 'date' 
  begin
    Bundler.setup
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

desc "Initialize the project for development and testing"
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

desc "Initialize the project for build and test with Travis-CI"
task :travis do
  puts green("Ensuring Layer Specs repository")
  run("[ -d ~/.cocoapods/repos/layer ] || rbenv exec bundle exec pod repo add layer git@github.com:layerhq/cocoapods-specs.git")
end

if defined?(XCTasks)
  XCTasks::TestTask.new(test: :sim) do |t|
    t.workspace = 'LayerSample.xcworkspace'
    t.schemes_dir = 'Tests/Schemes'
    t.runner = :xcpretty
    t.output_log = 'xcodebuild.log'
    t.subtask(app: 'LayerSampleTests') do |s|
      s.destination do |d|
        d.platform = :iossimulator
        d.name = 'LayerUIKit-Test-Device'
        d.os = :latest
      end
    end    
  end
end

desc "Creates a Testing Simulator configured for LayerUIKit Testing"
task :sim do
  # Check if LayerUIKit Test Device Exists
  device = `xcrun simctl list | grep LayerUIKit-Test-Device`
  if $?.exitstatus.zero?
    puts ("Found Layer Test Device #{device}")
    device.each_line do |line|
      if device_id = line.match(/\(([^\)]+)/)[1]
        puts green ("Deleting device with ID #{device_id}")
        run ("xcrun simctl delete #{device_id}")
      end
    end
  end
  puts green ("Creating iOS simulator for LayerUIKit Testing")
  run("xcrun simctl create LayerUIKit-Test-Device com.apple.CoreSimulator.SimDeviceType.iPhone-6 com.apple.CoreSimulator.SimRuntime.iOS-8-1")
end

desc "Builds and pushes a new release to Hockey App"
task :release do

  require 'byebug'
  require 'plist'
  require "highline/import"
  
  # 1) Set the new version of the sample App.
  plist = info_plist
  sample_version = ask "Set Sample Version... \nCurrent Sample Version: #{sample_app_version} \nCurrent LayerKit Version: #{layerkit_version}"
  puts green ("New Layer Sample App Version: #{sample_version}")
  plist['CFBundleShortVersionString'] = sample_version
  
  # 2) Generate objects with: builder name/email (via git config), short-sha
  short_sha = `git rev-parse --short HEAD`.strip
  builder_name = `git config --get user.name`.strip
  builder_email = `git config --get user.email`.strip

  # 2) Insert generated object into Info.plist.
  plist['LYRBuildInformation'] = {
    'LYRBuildLayerKitVersion' => layerkit_version,
    'LYRBuildShortSha' => short_sha,
    'LYRBuildBuilderName' => builder_name,
    'LYRBuildBuilderEmail' => builder_email
  }
  
  # Write the plist.
  plist_path = 'Resources/LayerSample-Info.plist'
  trap("SIGINT") { run("git checkout -- Resources/LayerSample-Info.plist", quiet: true) }
  File.open(plist_path, 'w') { |file| file.write(plist.to_plist) }
  run ("git add Resources/LayerSample-Info.plist")
  run ("git commit -m 'Changed LayerKit version string to #{sample_version}'")

  archive_path = 'LayerSample.xcarchive'

  xcpretty_params = (ENV['LAYER_XCPRETTY_PARAMS'] || '')

  # 3.5) Move the shared scheme into the workspace directory.
  FileUtils::Verbose.mkdir_p "LayerSample.xcworkspace/xcshareddata/xcschemes"
  FileUtils::Verbose.cp Dir.glob("Schemes/*.xcscheme"), "LayerSample.xcworkspace/xcshareddata/xcschemes"

  # 4) Archive project with shenzhen, but pipe to xcpretty.
  run("ipa build --workspace LayerSample.xcworkspace --scheme LayerSample --configuration Release --verbose | xcpretty #{xcpretty_params} && exit ${PIPESTATUS[0]}")
  
  output = with_clean_env { `ipa info` }
  unless output =~ /LayerSample In House Distribution/
    puts output
    fail "!! Build does not appear to be built against the 'LayerSample In House Distribution' provisioning profile -- aborting upload."
  end

  # 5) Upload to HockeyApp.net via shenzhen.
  run("ipa distribute:hockeyapp --token 4293de2a6ba5492c9d77b6faaf8d5343 -m \"Build of #{short_sha} by #{builder_name} (#{builder_email}).\"")
  #run("ipa distribute:hockeyapp --token 4293de2a6ba5492c9d77b6faaf8d5343 --tags dev -m \"Build of #{short_sha} by #{builder_name} (#{builder_email}).\"")
  
  run("ipa info LayerSample.ipa")

  # 6) Reset Info.plist.
  run("git checkout -- Resources/LayerSample-Info.plist", quiet: true)

  # 8) Let everyone know that Layer Sample is Available
  require 'slack-notifier'
  notifier = Slack::Notifier.new "layer", "IBYcWAHe4H4CEKLKUUJkzkAf"
  notifier.ping "Good news everyone! Layer iOS Sample App v#{sample_version} is now available on Hockey App", channel: '#dev', username: 'LayerBot', icon_emoji: ":marshawn:"
  notifier.ping "Good news everyone! Layer iOS Sample App v#{sample_version} is now available on Hockey App", channel: '#applications', username: 'LayerBot', icon_emoji: ":marshawn:"
  
  # 9) Remove the build artifacts from repository
  run ("rm -rf LayerSample.app.dSYM.zip")
  run ("rm -rf LayerSample.ipa")
  
end

def info_plist
  require 'plist'
  plist_path = 'Resources/LayerSample-Info.plist'
  info_plist = Plist::parse_xml(plist_path)
end

def sample_app_version
  sample_version = info_plist['CFBundleShortVersionString']
end

def layerkit_version
  require 'yaml'
  lockfile = YAML.load_file('Podfile.lock')
  layer_kit_version = nil
  lockfile['PODS'].detect do |entry|
    if entry.kind_of?(String) && entry =~ /^LayerKit/
      layer_kit_version = entry.match(/LayerKit \(([\d\.\-\w]+)\)/)[1]
    elsif entry.kind_of?(Hash) && entry.keys[0] =~ /^LayerKit/
      layer_kit_version = entry.keys[0].match(/LayerKit \(([\d\.\-\w]+)\)/)[1]
    end
  end
end

# Safe to run when Bundler is not available
def with_clean_env(&block)
  if defined?(Bundler)
    Bundler.with_clean_env(&block)
  else
    yield
  end
end

def run(command, options = {})
  puts "Executing `#{command}`" unless options[:quiet]
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
