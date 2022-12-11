# frozen_string_literal: true

Fabricator(:trophy_hunter) do
  name { sequence { |n| "hunter_name_#{n}" } }
  email { sequence { |n| "hunter_email_#{n}@example.com" } }
  password { sequence { |n| "hunter_password_#{n}" } }
  app_context { sequence { |n| "hunter_app_context_#{n}" } }
  client_id { sequence { |n| "hunter_client_id_#{n}" } }
  client_secret { sequence { |n| "hunter_client_secret_#{n}" } }
  duid { sequence { |n| "hunter_duid_#{n}" } }
  state { sequence { |n| "hunter_state_#{n}" } }
  scope { sequence { |n| "hunter_scope_#{n}" } }
end
