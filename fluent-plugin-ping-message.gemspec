# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-ping-message"
  gem.version       = "0.0.1"
  gem.authors       = ["TAGOMORI Satoshi"]
  gem.email         = ["tagomoris@gmail.com"]
  gem.description   = %q{for heartbeat monitoring of Fluentd processes}
  gem.summary       = %q{Fluentd plugin to send ping message}
  gem.homepage      = "https://github.com/tagomoris/fluent-plugin-ping-message"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "fluentd"
  gem.add_runtime_dependency "fluentd"
  gem.add_development_dependency "fluent-mixin-config-placeholders"
  gem.add_runtime_dependency "fluent-mixin-config-placeholders"
end
