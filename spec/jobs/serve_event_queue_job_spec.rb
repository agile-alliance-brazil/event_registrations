# frozen_string_literal: true

describe ServeEventQueueJob, type: :job do
  context 'with active events' do
    let!(:event) { Fabricate :event }
    let!(:other_event) { Fabricate :event }
    let!(:out_event) { Fabricate :event, start_date: 3.days.ago, end_date: 2.days.ago }

    it 'calls the queue server twice' do
      expect(QueueService).to(receive(:serve_the_queue)).twice
      described_class.perform_now
    end
  end
end
