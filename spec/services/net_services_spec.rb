# frozen_string_literal: true

RSpec.describe NetServices, type: :service do
  describe '#url_found?' do
    it 'returns false when the URL is not valid' do
      response = instance_double(Response, code: '404')
      request = instance_double(Request, 'use_ssl=' => true, request_head: response)
      allow(Net::HTTP).to(receive(:new)).and_return(request)
      expect(described_class.instance.url_found?('foo')).to be false
    end

    it 'returns false when it raises an error' do
      allow(Net::HTTP).to(receive(:new)).and_raise(Errno::ENOENT)
      expect(described_class.instance.url_found?('foo')).to be false
    end

    it 'returns true when the URL is valid' do
      response = instance_double(Response, code: '200')
      request = instance_double(Request, 'use_ssl=' => true, request_head: response)
      allow(Net::HTTP).to(receive(:new)).and_return(request)
      expect(described_class.instance.url_found?('foo')).to be true
    end
  end
end
