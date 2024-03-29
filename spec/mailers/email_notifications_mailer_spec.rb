# frozen_string_literal: true

RSpec.describe EmailNotificationsMailer, type: :mailer do
  let(:event) { Fabricate :event, link: 'www.foo.com' }

  before { ActionMailer::Base.deliveries = [] }

  after { ActionMailer::Base.deliveries.clear }

  describe '#registration_pending' do
    let(:attendance) { Fabricate(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee and cc the events organizer' do
        mail = described_class.registration_pending(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_waiting' do
    let(:attendance) { Fabricate(:attendance, event: event, status: :waiting) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.registration_waiting(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_confirmed' do
    let(:attendance) { Fabricate(:attendance, event: event, registration_date: Time.zone.local(2013, 5, 1, 12, 0, 0)) }

    context 'when the event starts before the end date' do
      it 'sends the confirmation email' do
        mail = described_class.registration_confirmed(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.subject).to eq(I18n.t('email.registration_confirmed.subject', event_name: attendance.event_name, attendance_id: attendance.id, event_nickname: attendance.event.event_nickname).to_s)
      end
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.registration_confirmed(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#registration_paid' do
    let(:attendance) { Fabricate(:attendance, event: event, registration_date: Time.zone.local(2013, 5, 1, 12, 0, 0)) }

    context 'when the event starts before the end date' do
      it 'sends the confirmation email' do
        mail = described_class.registration_paid(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.subject).to eq(I18n.t('email.registration_paid.subject', event_name: attendance.event_name, attendance_id: attendance.id, event_nickname: attendance.event.event_nickname).to_s)
      end
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer], main_email_contact: 'xpto@sbbrubles.com' }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.registration_paid(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq ['xpto@sbbrubles.com']
      end
    end
  end

  describe '#cancelling_registration' do
    let(:event) { Fabricate :event }
    let(:attendance) { Fabricate :attendance, event: event }

    it 'sends to pending attendee' do
      mail = described_class.cancelling_registration(attendance).deliver
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])

      expect(mail.subject).to eq(I18n.t('email.cancelling_registration.subject', event_name: attendance.event_name, attendance_id: attendance.id).to_s)
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.cancelling_registration(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#cancelling_registration_warning' do
    let(:event) { Fabricate :event }
    let(:attendance) { Fabricate :attendance, event: event }

    it 'is sent to delayed pending attendance' do
      mail = described_class.cancelling_registration_warning(attendance).deliver
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq([attendance.email])
      expect(mail.subject).to eq(I18n.t('email.cancelling_registration_warning.subject', event_name: attendance.event_name, attendance_id: attendance.id).to_s)
    end

    context 'with organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee cc the events organizer' do
        mail = described_class.cancelling_registration_warning(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#registration_dequeued' do
    let(:attendance) { Fabricate(:attendance, event: event) }

    context 'having organizers in the event' do
      let(:organizer) { Fabricate(:user, role: :organizer) }
      let(:other_organizer) { Fabricate :user, role: :organizer }
      let!(:event) { Fabricate :event, organizers: [organizer, other_organizer] }

      it 'sends to attendee and cc the events organizer' do
        mail = described_class.registration_dequeued(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
      end
    end
  end

  describe '#welcome_attendance' do
    let(:event) { Fabricate(:event, start_date: 1.day.from_now) }
    let(:attendance) { Fabricate(:attendance, event: event) }

    it 'sends to attendee and cc the events organizer' do
      mail = described_class.welcome_attendance(attendance).deliver
      expect(ActionMailer::Base.deliveries.size).to eq 1
      expect(mail.to).to eq [attendance.email]
      expect(mail.cc).to eq [event.main_email_contact]
    end
  end

  describe '#welcome_attendance_remote_event' do
    context 'future event' do
      it 'sends to attendee and cc the events organizer' do
        event = Fabricate(:event, start_date: 1.day.from_now)
        attendance = Fabricate(:attendance, event: event)

        mail = described_class.welcome_attendance_remote_event(attendance).deliver
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(mail.to).to eq [attendance.email]
        expect(mail.cc).to eq [event.main_email_contact]
        expect(mail.subject).to eq I18n.t('attendances.welcome_attendance_remote_event.subject', event_name: attendance.event_name, attendance_id: attendance.id, event_nickname: attendance.event.event_nickname, event_day_of_week: I18n.l(event.start_date, format: '%A').downcase).to_s
      end
    end

    context 'event is occurring and it is before 18' do
      it 'sends to attendee and cc the events organizer' do
        travel_to Time.zone.local(2021, 10, 5, 15, 0, 0) do
          event = Fabricate(:event, start_date: 1.day.ago, end_date: 1.day.from_now)
          attendance = Fabricate(:attendance, event: event)

          allow(Time.zone).to(receive(:now)).and_return(Time.zone.local(2021, 10, 5, 15, 0, 0))
          mail = described_class.welcome_attendance_remote_event(attendance).deliver
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(mail.to).to eq [attendance.email]
          expect(mail.cc).to eq [event.main_email_contact]
          expect(mail.subject).to eq I18n.t('attendances.welcome_attendance_remote_event.subject', event_name: attendance.event_name, attendance_id: attendance.id, event_nickname: attendance.event.event_nickname, event_day_of_week: I18n.t('date.close_dates.today').downcase).to_s
        end
      end
    end

    context 'event is occurring and it is after 18' do
      it 'sends to attendee and cc the events organizer' do
        travel_to Time.zone.local(2021, 10, 5, 19, 0, 0) do
          event = Fabricate(:event, start_date: 1.day.ago)
          attendance = Fabricate(:attendance, event: event)

          allow(Time.zone).to(receive(:now)).and_return(Time.zone.local(2021, 10, 5, 19, 0, 0))
          mail = described_class.welcome_attendance_remote_event(attendance).deliver
          expect(ActionMailer::Base.deliveries.size).to eq 1
          expect(mail.to).to eq [attendance.email]
          expect(mail.cc).to eq [event.main_email_contact]
          expect(mail.subject).to eq I18n.t('attendances.welcome_attendance_remote_event.subject', event_name: attendance.event_name, attendance_id: attendance.id, event_nickname: attendance.event.event_nickname, event_day_of_week: I18n.t('date.close_dates.tomorrow').downcase).to_s
        end
      end
    end
  end
end
