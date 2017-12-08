describe ServeEventQueueJob, type: :job do
  context 'with active events' do
    let!(:event) { FactoryBot.create :event }
    let!(:other_event) { FactoryBot.create :event }
    let!(:out_event) { FactoryBot.create :event, start_date: 3.days.ago, end_date: 2.days.ago }

    it 'calls the queue server twice' do
      QueueService.expects(:serve_the_queue).twice
      ServeEventQueueJob.perform_now
    end
  end
end
