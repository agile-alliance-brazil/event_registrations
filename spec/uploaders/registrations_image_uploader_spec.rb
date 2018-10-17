# frozen_string_literal: true

RSpec.describe RegistrationsImageUploader, type: :image_uploader do
  include CarrierWave::Test::Matchers

  before { RegistrationsImageUploader.enable_processing = true }
  after { RegistrationsImageUploader.enable_processing = false }

  describe '#thumb' do
    let(:uploader) { RegistrationsImageUploader.new(Event.new) }
    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.thumb).to have_dimensions(50, 28) }
  end

  describe '#extension_whitelist' do
    it { expect(subject.extension_whitelist).to eq %w[jpg jpeg gif png] }
  end

  describe '#store_dir' do
    it { expect(subject.store_dir).to eq 'uploads' }
  end
end
