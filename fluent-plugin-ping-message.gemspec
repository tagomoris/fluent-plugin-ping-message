# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-ping-message"
  gem.version       = "1.0.0"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.description   = %q{for heartbeat monitoring of Fluentd processes}
  gem.summary       = %q{Fluentd plugin to send/check ping messages}
  gem.homepage      = "https://github.com/tagomoris/fluent-plugin-ping-message"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "fluentd", ">= 0.14.0"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "test-unit", "~> 3.0"
end
