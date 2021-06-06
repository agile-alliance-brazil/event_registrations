# frozen_string_literal: true

module AgileAllianceService
  def self.check_member(email)
    url = "#{Figaro.env.agile_alliance_api_host}/check_member/#{email}"
    response = HTTParty.get(url, headers: { 'AUTHORIZATION' => Figaro.env.agile_alliance_api_token })
    response.present? && JSON.parse(response.body)['member']
  rescue JSON::ParserError, URI::InvalidURIError
    false
  end
end
