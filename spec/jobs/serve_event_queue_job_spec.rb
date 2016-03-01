describe ServeEventQueueJob, type: :job do
  context 'with active events' do
    let!(:event) { FactoryGirl.create :event }
    let!(:other_event) { FactoryGirl.create :event }
    let!(:out_event) { FactoryGirl.create :event, start_date: 3.days.ago, end_date: 2.days.ago }

    it 'calls the queue server twice' do
      QueueService.expects(:serve_the_queue).twice
      ServeEventQueueJob.perform_now
    end
  end
end
