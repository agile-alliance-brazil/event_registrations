# frozen_string_literal: true

if Figaro.env.airbrake_project_id.present?
  Airbrake.configure do |config|
    config.ignore_environments = %w[development test]
    config.project_id = Figaro.env.airbrake_project_id
    config.project_key = Figaro.env.airbrake_project_key
    config.environment = Figaro.env.airbrake_environment || 'development'
  end
end
