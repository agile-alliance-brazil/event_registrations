require 'spec_helper'

describe Guard::KonachaRails do
  rails_env_file = File.expand_path('../../dummy/config/environment', __FILE__)
  subject { Guard::KonachaRails.new(rails_environment_file: rails_env_file) }

  before do
    # Silence UI.info output.
    allow(::Guard::UI).to receive(:info).and_return(true)
  end

  describe '#initialize' do
    it 'instantiates Runner with given options' do
      expect(Guard::KonachaRails::Runner).to receive(:new).with(rails_environment_file: nil,
        spec_dir: 'spec/assets')

      Guard::KonachaRails.new(rails_environment_file: nil, spec_dir: 'spec/assets')
    end
  end

  describe '#start' do
    it 'starts the runner' do
      expect(subject.runner).to receive(:start)

      subject.start
    end
  end

  describe '#run_all' do
    it 'calls #run' do
      expect(subject.runner).to receive(:run).with(no_args)

      subject.run_all
    end
  end

  describe '#run_on_changes' do
    it 'calls #run with file name' do
      expect(subject.runner).to receive(:run).with(['file_name.js'])

      subject.run_on_changes(['file_name.js'])
    end

    it 'calls #run with paths' do
      expect(subject.runner).to receive(:run).with(['spec/controllers', 'spec/requests'])

      subject.run_on_changes(['spec/controllers', 'spec/requests'])
    end
  end
end
