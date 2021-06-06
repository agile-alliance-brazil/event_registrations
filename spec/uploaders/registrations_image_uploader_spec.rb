# frozen_string_literal: true

RSpec.describe RegistrationsImageUploader, type: :image_uploader do
  include CarrierWave::Test::Matchers

  before { described_class.enable_processing = true }

  after { described_class.enable_processing = false }

  describe '#thumb' do
    let(:uploader) { described_class.new(Event.new) }

    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.thumb).to have_dimensions(50, 28) }
  end

  describe '#allow_whitelist' do
    subject(:registrations_image_uploader) { described_class.new }

    it { expect(registrations_image_uploader.allow_whitelist).to eq %w[jpg jpeg gif png] }
  end

  describe '#store_dir' do
    let(:uploader) { described_class.new(Event.new(id: 1)) }

    before { uploader.store!(File.open('spec/fixtures/default_image.png')) }

    it { expect(uploader.store_dir).to eq 'uploads/event/1' }
  end
end
