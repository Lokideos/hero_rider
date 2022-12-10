# frozen_string_literal: true

Fabricator(:player) do
  telegram_username { sequence { |n| "telegram_username_#{n}" } }
  trophy_account { sequence { |n| "trophy_account_#{n}@example.com" } }
  admin { false }
  on_watch { true }
end
