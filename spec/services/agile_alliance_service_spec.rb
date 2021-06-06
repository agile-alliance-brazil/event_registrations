# frozen_string_literal: true

RSpec.describe AgileAllianceService do
  before { WebMock.enable! }

  after { WebMock.disable! }

  let(:token) { Figaro.env.agile_alliance_api_token }
  let(:headers) { { 'Authorization' => token } }
  let(:host) { "#{Figaro.env.agile_alliance_api_host}/check_member/bla" }

  describe '.check_member' do
    context 'valid data returned' do
      context 'when the user is a member' do
        before { WebMock.stub_request(:get, host).with(headers: headers).to_return(body: { member: true }.to_json, headers: {}) }

        it { expect(described_class.check_member('bla')).to be true }
      end

      context 'when the user is not a member' do
        before { WebMock.stub_request(:get, host).with(headers: headers).to_return(body: { member: false }.to_json, headers: {}) }

        it { expect(described_class.check_member('bla')).to be false }
      end
    end

    context 'invalid data returned' do
      context 'HTML informing not found' do
        before { WebMock.stub_request(:get, host).with(headers: headers).to_return(body: '<h1>Not Found</h1>', headers: {}, status: 200) }

        it { expect(described_class.check_member('bla')).to be false }
      end

      context 'returning URI::InvalidURIError' do
        before { WebMock.stub_request(:get, host).with(headers: headers).to_raise(URI::InvalidURIError) }

        it { expect(described_class.check_member('bla')).to be false }
      end
    end
  end
end
