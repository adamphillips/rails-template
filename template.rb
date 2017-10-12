def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

git :init

# Add default gems
if yes?('Add gems to Gemfile')
  gem 'slim-rails'

  gem_group :development do
    gem 'dotenv-rails'
  end

  gem_group :test do
    gem 'minitest-spec-rails'
    gem 'minitest-reporters'
    gem 'factory_girl_rails'
    gem 'mocha'
    gem 'capybara'
    gem 'launchy'
  end

  # Heroku specific gem setup
  hosted_on_heroku = yes?('Is this app going to be hosted on heroku')

  if hosted_on_heroku
    gem_group :production do
      gem 'rails_12factor'
    end
  end
end

after_bundle do
  git add: '.'
  git commit: %Q{-m 'Installed default gems'}
end

ruby_version = ask('Ruby version')
ruby_gemset = ask('Gemset name')

file '.ruby-version', ruby_version
file '.ruby-gemset', ruby_gemset

append_to_file '.gitignore' do
  [
    '',
    '.ruby-version',
    '.ruby-gemset',
    ''
  ].join("\n")
end

file '.env'

append_to_file '.gitignore', "\n.env\n"

# Configure test environment

template 'files/capybara.rb', 'test/support/capybara.rb'
template 'files/factory_girl.rb', 'test/support/factory_girl.rb'
template 'files/minitest_reporters.rb', 'test/support/minitest_reporters.rb'
template 'files/mocha.rb', 'test/support/mocha.rb'

insert_into_file 'test/test_helper.rb', after: "require 'rails/test_help'\n\n" do
  [
    "require 'minitest/autorun'",
    "require 'support/minitest_reporters'",
    "require 'support/mocha'",
    "",
    ""
  ].join("\n")
end

git add: '.'
git commit: %Q{-m 'Configured test environment'}

# Setup bower

setup_assets = yes?('Setup assets using bower?')

if setup_assets
  run('npm init')

  run('npm install --save-dev bower')

  insert_into_file 'package.json', before: '  "devDependencies"' do
    [
      '  "scripts": {',
      '    "bower": "node_modules/bower/bin/bower"',
      '  },'
    ].join("\n")
  end

  run('npm run bower init')

  append_to_file '.gitignore', "\nnode_modules\n"

  template 'files/bowerrc', '.bowerrc'
  empty_directory 'vendor/assets/components'

  append_to_file 'config/initializers/assets.rb' do
    [
      '',
      '# Add bower components to the asset load path',
      "Rails.application.config.assets.paths << Rails.root.join('vendor', 'assets', 'components')"
    ].join("\n")
  end

  git add: '.'
  git commit: %Q{-m 'Configured bower for front-end dependencies'}

  # Setup bootstrap

  run('npm run bower install bootstrap-sass')

  remove_file 'app/assets/javascripts/application.js'
  remove_file 'app/assets/stylesheets/application.css'

  template 'files/application.js', 'app/assets/javascripts/application.js'
  template 'files/application.scss', 'app/assets/stylesheets/application.scss'
  template 'files/bootstrap.rb', 'config/initializers/bootstrap.rb'

  git add: '.'
  git commit: %Q{-m 'Setup bootstrap'}

  # Reconfigure default assets
end