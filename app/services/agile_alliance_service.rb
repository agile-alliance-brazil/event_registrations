module AgileAllianceService
  def self.check_member(email)
    url = "#{APP_CONFIG[:agile_alliance][:api_host]}/check_member/#{email}"
    response = HTTParty.get(url, headers: { 'AUTHORIZATION' => APP_CONFIG[:agile_alliance][:api_token] })
    response.present? && JSON.parse(response.parsed_response)['member']
  end
end
