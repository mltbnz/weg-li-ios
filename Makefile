all: bootstrap

bootstrap: dependencies
.PHONY: bootstrap

dependencies: brew ruby
.PHONY: dependencies

brew:
	brew install ruby
	brew install swiftlint
.PHONY: brew

ruby:
	gem install bundler
	bundle install
.PHONY: ruby