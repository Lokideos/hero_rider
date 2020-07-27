# frozen_string_literal: true

module ApplicationLoader
  extend self

  def load_app!
    init_config
    init_db
    require_app
    init_app
  end

  def root
    File.expand_path('..', __dir__)
  end

  private

  def init_config
    require_file 'config/initializers/config'
  end

  def init_db
    require_file 'config/initializers/db'
  end

  def init_app
    require_dir 'config/initializers'
  end

  def require_app
    require_file 'config/application'
    require_file 'app/services/basic_service'
    require_dir 'app'
  end

  def require_file(path)
    require File.join(root, path)
  end

  def require_dir(path)
    path = File.join(root, path)
    Dir["#{path}/**/*.rb"].sort.each { |file| require file }
  end
end
