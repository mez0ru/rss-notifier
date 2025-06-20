# Migrate

migrate = lambda do |env, version|
  sh({'RACK_ENV' => env}, FileUtils::RUBY, "-r", "./db", "-r", "logger", "-e", <<~RUBY)
    Sequel.extension :migration
    DB.loggers << Logger.new($stdout) if DB.loggers.empty?
    Sequel::Migrator.apply(DB, 'migrate', #{version.inspect})
  RUBY
end

desc "Migrate test database to latest version"
task :test_up do
  migrate.call('test', nil)
end

desc "Migrate test database all the way down"
task :test_down do
  migrate.call('test', 0)
end

desc "Migrate test database all the way down and then back up"
task :test_bounce do
  migrate.call('test', 0)
  migrate.call('test', nil)
end

desc "Migrate development database to latest version"
task :dev_up do
  migrate.call('development', nil)
end

desc "Migrate development database to all the way down"
task :dev_down do
  migrate.call('development', 0)
end

desc "Migrate development database all the way down and then back up"
task :dev_bounce do
  migrate.call('development', 0)
  migrate.call('development', nil)
end

desc "Migrate production database to latest version"
task :prod_up do
  migrate.call('production', nil)
end

# Shell

irb = proc do |env|
  trap('INT', "IGNORE")
  dir, base = File.split(FileUtils::RUBY)
  windows = Gem.win_platform?
  if windows
    cmd = base.sub!(/\Aruby.exe/, 'irb.bat')
      [File.join(dir, base)]
  else
    cmd = if base.sub!(/\Aruby/, 'irb')
      [File.join(dir, base)]
    else
      [FileUtils::RUBY, "-S", "irb"]
    end
  end
  cmd.unshift({"RACK_ENV" => env})
  cmd << "-r" << "./models"
  sh(*cmd)
end

desc "Open irb shell in test mode"
task :test_irb do 
  irb.call('test')
end

desc "Open irb shell in development mode"
task :dev_irb do 
  irb.call('development')
end

desc "Open irb shell in production mode"
task :prod_irb do 
  irb.call('production')
end

# Specs

spec = proc do |type|
  desc "Run #{type} specs"
  task :"#{type}_spec" do
    sh "#{FileUtils::RUBY} -w #{'-W:strict_unused_block' if RUBY_VERSION >= '3.4'} spec/#{type}.rb"
  end

  desc "Run #{type} specs with coverage"
  task :"#{type}_spec_cov" do
    sh({"COVERAGE" => type, "RODA_RENDER_COMPILED_METHOD_SUPPORT" => "no"}, FileUtils::RUBY, "spec/#{type}.rb")
  end
end
spec.call('model')
spec.call('web')
spec.call('service')

desc "Run all specs"
task default: [:model_spec, :web_spec]

desc "Run all specs with coverage"
task :spec_cov do
  FileUtils.rm_r('coverage') if File.directory?('coverage')
  Dir.mkdir('coverage')
  Rake::Task['_spec_cov'].invoke
end
task _spec_cov: [:model_spec_cov, :web_spec_cov]

# Other

desc "Annotate Sequel models"
task "annotate" do
  sh({'RACK_ENV' => "test"}, FileUtils::RUBY, "-r", "./models", "-r", "sequel/annotate", "-e", <<~RUBY)
    DB.loggers.clear
    Sequel::Annotate.annotate(Dir['models/**/*.rb'])
  RUBY
end

last_line = __LINE__
# Utils

desc "give the application an appropriate name"
task :setup, [:name] do |t, args|
  unless name = args[:name]
    $stderr.puts "ERROR: Must provide a name argument: example: rake \"setup[AppName]\""
    exit(1)
  end

  require 'securerandom'
  require 'fileutils'
  lower_name = name.gsub(/([a-z\d])([A-Z])/, '\1_\2').downcase
  upper_name = lower_name.upcase
  random_bytes = lambda{[SecureRandom.random_bytes(64).gsub("\x00"){((rand*255).to_i+1).chr}].pack('m').inspect}

  File.write('.env.rb', <<END)
case ENV['RACK_ENV'] ||= 'development'
when 'test'
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack('m')[0]
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_test?user=#{lower_name}"
when 'production'
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack('m')[0]
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_production?user=#{lower_name}"
else
  ENV['#{upper_name}_SESSION_SECRET'] ||= #{random_bytes.call}.unpack('m')[0]
  ENV['#{upper_name}_DATABASE_URL'] ||= "postgres:///#{lower_name}_development?user=#{lower_name}"
end
END

  %w'views/layout.erb routes/prefix1.rb config.ru app.rb db.rb spec/web/spec_helper.rb spec/web/prefix1_spec.rb'.each do |f|
    File.write(f, File.read(f).gsub('App', name).gsub('APP', upper_name))
  end

  File.write(__FILE__, File.read(__FILE__).split("\n")[0...(last_line-2)].join("\n") << "\n")
  File.write('.gitignore', "/.env.rb\n/coverage\n")
  File.delete('public/.gitkeep')
  File.delete('.ci.gemfile')
  FileUtils.remove_dir('stack-spec')
  FileUtils.remove_dir('.github')
end

Rake::Task["default"].clear
desc "Run specs to make sure stack works properly"
task :default do
  sh "#{FileUtils::RUBY} -w #{'-W:strict_unused_block' if RUBY_VERSION >= '3.4'} stack-spec/stack_spec.rb"
end

desc "Run specs to make sure stack works properly, with debugging enabled"
task :stack_spec_debug do
  sh({"DEBUG" => '1'}, FileUtils::RUBY, "-w", "stack-spec/stack_spec.rb")
end
