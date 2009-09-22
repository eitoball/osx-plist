require 'rubygems'
require 'hoe'

Hoe.spec 'osx-plist' do
  developer("Kevin Ballard", "kevin@sb.org")
  self.version = "1.0.3"
  self.summary = "Property List manipulation for OS X"
  self.spec_extras = {:extensions => "ext/plist/extconf.rb"}
end

# override Hoe's default :test task
Rake::Task["test"].clear
desc "Run the unit tests"
task :test do
  ruby "test/test_plist.rb"
end
