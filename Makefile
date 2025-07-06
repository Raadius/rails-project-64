render-build:
	bundle install
	bundle exec rails assets:precompile
	bundle exec rails assets:clean
	bundle exec rails db:migrate

render-start:
	bundle exec puma -t 5:5 -p ${PORT} -e ${RACK_ENV}