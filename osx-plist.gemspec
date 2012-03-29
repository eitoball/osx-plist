# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{osx-plist}
  s.version = "1.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kevin Ballard"]
  s.date = %q{2009-09-21}
  s.description = %q{osx-plist is a Ruby library for manipulating Property Lists natively using the built-in support in OS X.}
  s.email = ["kevin@sb.org"]
  s.extensions = ["ext/plist/extconf.rb"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "ext/plist/extconf.rb", "ext/plist/plist.c", "lib/osx/plist.rb", "test/fixtures/xml_plist", "test/suite.rb", "test/test_plist.rb"]
  s.homepage = %q{http://github.com/kballard/osx-plist}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib", "ext"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Property List manipulation for OS X}
  s.test_files = ["test/test_plist.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
