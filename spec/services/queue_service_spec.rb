describe QueueService, type: :service do
  describe '.serve_the_queue' do
    context 'with no vacancy' do
      let(:event) { FactoryBot.create :event, attendance_limit: 1 }
      let!(:pending) { FactoryBot.create :attendance, event: event }
      let!(:waiting) { FactoryBot.create :attendance, event: event, status: :waiting }

      before { QueueService.serve_the_queue(event) }
      it { expect(waiting.reload.status).to eq 'waiting' }
    end

    context 'with one vacancy' do
      let(:event) { FactoryBot.create :event, attendance_limit: 2 }
      let!(:pending) { FactoryBot.create :attendance, event: event }
      let!(:waiting) { FactoryBot.create :attendance, event: event, status: :waiting }

      before { QueueService.serve_the_queue(event) }
      it { expect(waiting.reload.status).to eq 'pending' }
    end

    context 'with more attendances in the queue than vacancies' do
      let(:event) { FactoryBot.create :event, attendance_limit: 3 }
      let!(:pending) { FactoryBot.create :attendance, event: event }
      let!(:first_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
      let!(:second_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: Time.zone.today }
      let!(:third_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 2.days.ago }

      it 'dequeues all the attendances and sends the notification' do
        email = stub(deliver_now: true)
        EmailNotifications.expects(:registration_dequeued).twice.returns(email)
        QueueService.serve_the_queue(event)
        expect(third_waiting.reload.status).to eq 'pending'
        expect(second_waiting.reload.status).to eq 'pending'
        expect(first_waiting.reload.status).to eq 'waiting'
      end
    end

    context 'with more vacancies than attendances in the queue' do
      let(:event) { FactoryBot.create :event, attendance_limit: 10 }
      let!(:pending) { FactoryBot.create :attendance, event: event }
      let!(:first_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
      let!(:second_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: Time.zone.today }
      let!(:third_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 2.days.ago }

      it 'dequeues all the attendances and sends the notification' do
        email = stub(deliver_now: true)
        EmailNotifications.expects(:registration_dequeued).times(3).returns(email)
        QueueService.serve_the_queue(event)
        expect(third_waiting.reload.status).to eq 'pending'
        expect(second_waiting.reload.status).to eq 'pending'
        expect(first_waiting.reload.status).to eq 'pending'
      end
    end
  end
end
