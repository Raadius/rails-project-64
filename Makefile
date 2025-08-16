render-build:
	bundle install
	bundle exec rails assets:precompile
	bundle exec rails assets:clean
	bundle exec rails db:migrate
	bundle exec rails db:seed

render-start:
	bundle exec puma -t 5:5 -p $${PORT:-3000} -e $${RAILS_ENV:-development}

start-server:
	bundle exec rails server

# Linting tasks
slim-lint:
	bundle exec slim-lint app/views/

rubocop:
	bundle exec rubocop

rubocop-fix:
	bundle exec rubocop --autocorrect-all

rubocop-safe-fix:
	bundle exec rubocop --autocorrect

lint-all: rubocop slim-lint

fix-all: rubocop-safe-fix

# Test tasks
run-tests:
	bundle exec rake test

# prepare project to run locally
prepare-local:
	bundle install
	bundle exec rails db:migrate
	bundle exec rails db:seed