# frozen_string_literal: true
begin
  require_relative '.env.rb'
rescue LoadError
end

require 'sequel/core'

# Delete APP_DATABASE_URL from the environment, so it isn't accidently
# passed to subprocesses.  APP_DATABASE_URL may contain passwords.
case ENV['RACK_ENV']
when 'development'
  DB = Sequel.connect(ENV.delete('APP_DATABASE_URL') || ENV.delete('DATABASE_URL'))
when 'test'
  DB = Sequel.connect(ENV.delete('APP_DATABASE_URL_TEST') || ENV.delete('DATABASE_URL_TEST'))
when 'production'
  DB = Sequel.connect(ENV.delete('APP_DATABASE_URL_PROD') || ENV.delete('DATABASE_URL_PROD'))
else
  raise "unknown RACK_ENV: #{ENV['RACK_ENV']}"
end

DB.run('PRAGMA journal_mode = WAL;')


# Load Sequel Database/Global extensions here
# DB.extension :date_arithmetic
DB.extension :pg_auto_parameterize if DB.adapter_scheme == :postgres && Sequel::Postgres::USES_PG
