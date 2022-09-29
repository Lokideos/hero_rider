# frozen_string_literal: true

require 'i18n/backend/fallbacks'
I18n::Backend::Simple.include I18n::Backend::Fallbacks

I18n.load_path += Dir[ApplicationLoader.root.concat('/config/locales/**/*.yml')]
I18n.available_locales = %i[en ru]
I18n.default_locale = :ru
I18n.fallbacks[:ru] = %i[ru en]
