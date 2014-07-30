require 'rubygems'
require 'bundler'
require 'date'
require 'plist'
Bundler.setup
require 'xctasks/test_task'

# Enable realtime output under Jenkins
if ENV['JENKINS_HOME']
  STDOUT.sync = true
  STDERR.sync = true
end

XCTasks::TestTask.new do |t|
  t.workspace = 'LayerSample.xcworkspace'
  t.schemes_dir = 'Tests/Schemes'
  t.runner = :xcpretty
  t.output_log = 'xcodebuild.log'
  t.settings["LAYER_TEST_HOST"] = (ENV['LAYER_TEST_HOST'] || 'localhost')
  t.subtasks = { app: 'LayerSampleTests' }
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

task :release do
  # 0) Check for bad directory state.
  dirty_git = `git diff --shortstat 2> /dev/null | tail -n1` != ""
  
  if dirty_git
    abort("Unable to build: The release process must be done with a clean directory. Perhaps you could `git stash`?")
  end
  
  # 1) Generate objects with: builder name/email (via git config), short-sha
  short_sha = `git rev-parse --short HEAD`.strip
  builder_name = `git config --get user.name`.strip
  builder_email = `git config --get user.email`.strip
  
  # 2) Insert generated object into Info.plist.
  
  plist_path = 'Resources/LayerSample-Info.plist'
  
  info_plist = Plist::parse_xml(plist_path)
  info_plist['LYRBuildInformation'] = {
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
  
  # 4) Archive project with shenzhen, but pipe to xcpretty.
  run("ipa build --verbose | xcpretty #{xcpretty_params} && exit ${PIPESTATUS[0]}")
  
  # 5) Upload to HockeyApp.net via shenzhen.
  run("ipa distribute:hockeyapp --token af4ab86a0bee4fdab9b780fe4c26b8f2 --tags dev -m \"Build of #{short_sha} by #{builder_name} (#{builder_email}).\"")
  
  # 6) Reset Info.plist.
  run("git checkout -- Resources/LayerSample-Info.plist")
  
  # 7) Clean up build data.
  run("rm LayerSample.ipa")
  run("rm LayerSample.app.dSYM.zip")
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
