RSpec.describe AgileAllianceService do
  before { WebMock.enable! }
  after { WebMock.disable! }

  describe '.check_member' do
    context 'when the user is a member' do
      before { WebMock.stub_request(:get, "#{APP_CONFIG[:agile_alliance][:api_host]}/check_member/bla").with(headers: { 'Authorization' => APP_CONFIG[:agile_alliance][:api_token] }).to_return(status: 200, body: { member: true }.to_json, headers: {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_truthy }
    end

    context 'when the user is not a member' do
      before { WebMock.stub_request(:get, "#{APP_CONFIG[:agile_alliance][:api_host]}/check_member/bla").with(headers: { 'Authorization' => APP_CONFIG[:agile_alliance][:api_token] }).to_return(status: 200, body: { member: false }.to_json, headers: {}) }
      it { expect(AgileAllianceService.check_member('bla')).to be_falsey }
    end
  end
end
