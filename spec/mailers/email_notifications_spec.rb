# frozen_string_literal: true

RSpec.describe EmailNotifications, type: :mailer do
  let(:event) { FactoryBot.create :event, link: 'www.foo.com' }
  before { ActionMailer::Base.deliveries = [] }
  after { ActionMailer::Base.deliveries.clear }

  describe '#registration_pending' do
    let(:attendance) { FactoryBot.create(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.registration_pending(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_waiting' do
    let(:attendance) { FactoryBot.create(:attendance, event: event, status: :waiting) }

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.registration_waiting(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_confirmed' do
    let(:attendance) { FactoryBot.create(:attendance, event: event, registration_date: Time.zone.local(2013, 5, 1, 12, 0, 0)) }

    context 'when the attendance is brazilian' do
      context 'and event start date before end date' do
        it 'sends the confirmation' do
          mail = EmailNotifications.registration_confirmed(attendance).deliver_now
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(mail.to).to eq [attendance.email]
          expect(mail.subject).to eq("Inscrição para #{event.name} confirmada")
        end
      end
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.registration_confirmed(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end

    context 'when the attendance is from other coutry' do
      context 'and event start date before end date' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, registration_date: Time.zone.local(2013, 5, 1, 12, 0, 0), country: 'US') }
        it 'sends the confirmation in english' do
          mail = EmailNotifications.registration_confirmed(attendance).deliver_now
          expect(ActionMailer::Base.deliveries.size).to eq(1)
          expect(mail.to).to eq([attendance.email])
          expect(mail.subject).to eq("Registration request to #{event.name} confirmed")
        end
      end
    end
  end

  describe '#cancelling_registration' do
    let(:event) { FactoryBot.create :event }
    let(:attendance) { FactoryBot.create :attendance, event: event }

    it 'sends to pending attendee' do
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Aviso de cancelamento da inscrição #{attendance.id} para #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Notice about registration #{attendance.id} cancelation to #{event.name}")
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.cancelling_registration(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#cancelling_registration_warning' do
    let(:event) { FactoryBot.create :event }
    let(:attendance) { FactoryBot.create :attendance, event: event }

    it 'should be sent to pending attendee' do
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Lembrete de pagamento da inscrição #{attendance.id} para #{event.name}")
    end

    it 'sends to attendee according to country' do
      attendance.country = 'US'
      mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq("Payment reminder about registration #{attendance.id} to #{event.name}")
    end

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = EmailNotifications.cancelling_registration_warning(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#registration_dequeued' do
    let(:attendance) { FactoryBot.create(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.registration_dequeued(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#welcome_attendance' do
    let(:event) { FactoryBot.create(:event, start_date: 1.day.from_now) }
    let(:out_event) { FactoryBot.create(:event, start_date: 2.days.from_now) }
    let(:attendance) { FactoryBot.create(:attendance, event: event) }
    let(:out_attendance) { FactoryBot.create(:attendance, event: out_event) }

    context 'having organizers in the event' do
      let(:organizer) { FactoryBot.create :organizer }
      let(:other_organizer) { FactoryBot.create :organizer }
      let!(:event) { FactoryBot.create :event, start_date: 1.day.from_now, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = EmailNotifications.welcome_attendance(attendance).deliver_now
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end
end
