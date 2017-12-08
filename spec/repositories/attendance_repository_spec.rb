describe AttendanceRepository, type: :repository do
  let(:event) { FactoryBot.create :event }
  describe '#search_for_list' do
    context 'and no attendances' do
      it { expect(AttendanceRepository.instance.search_for_list(event, 'bla', [])).to eq [] }
    end

    context 'and having attendances' do
      let!(:for_other_event) { FactoryBot.create(:attendance, first_name: 'xpto', last_name: 'bla', organization: 'foo', email: 'sbrubles@xpto.com') }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, first_name: 'xpto', last_name: 'bla', organization: 'foo', email: 'sbrubles@xpto.com') }

      let(:all_statuses) { %w[pending accepted paid confirmed cancelled] }

      context 'with one attendance' do
        context 'and matching fields' do
          context 'entire field' do
            it { expect(AttendanceRepository.instance.search_for_list(event, 'xPTo', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'bLa', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'FoO', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'sbRUblEs', all_statuses)).to match_array [attendance] }
          end

          context 'field part' do
            it { expect(AttendanceRepository.instance.search_for_list(event, 'PT', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'bL', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'oO', all_statuses)).to match_array [attendance] }
            it { expect(AttendanceRepository.instance.search_for_list(event, 'RUblEs', all_statuses)).to match_array [attendance] }
          end
        end
      end

      context 'with three attendances, one not matching' do
        let!(:other_attendance) { FactoryBot.create(:attendance, event: event, first_name: 'bla', last_name: 'xpto', organization: 'sbrubles', email: 'foo@xpto.com') }
        let!(:out_attendance) { FactoryBot.create(:attendance, event: event, first_name: 'Edsger', last_name: 'Dijkstra', organization: 'Turing', email: 'algorithm@node.path') }
        let!(:for_other_event) { FactoryBot.create(:attendance, first_name: 'Edsger', last_name: 'Dijkstra', organization: 'Turing', email: 'algorithm@node.path') }

        context 'entire field' do
          it { expect(AttendanceRepository.instance.search_for_list(event, 'xPTo', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'bLa', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'FoO', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'sbRUblEs', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, attendance.id, all_statuses)).to match_array [attendance] }
        end

        context 'field part' do
          it { expect(AttendanceRepository.instance.search_for_list(event, 'PT', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'bL', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'oO', all_statuses)).to match_array [attendance, other_attendance] }
          it { expect(AttendanceRepository.instance.search_for_list(event, 'RUblEs', all_statuses)).to match_array [attendance, other_attendance] }
        end
      end

      context 'with three attendances, all matching' do
        let!(:event) { FactoryBot.create :event }
        it 'will order by created at descending' do
          now = Time.zone.local(2015, 4, 30, 0, 0, 0)
          Timecop.freeze(now)
          attendance = FactoryBot.create(:attendance, event: event, first_name: 'April event')
          now = Time.zone.local(2014, 4, 30, 0, 0, 0)
          Timecop.freeze(now)
          other_attendance = FactoryBot.create(:attendance, event: event, first_name: '2014 event')
          Timecop.return
          another_attendance = FactoryBot.create(:attendance, event: event, first_name: 'Today event')

          expect(AttendanceRepository.instance.search_for_list(event, 'event', all_statuses)).to eq [another_attendance, attendance, other_attendance]
        end
      end
    end
  end

  describe 'for_cancelation_warning' do
    context 'with valid status and gateway as payment type' do
      it 'returns the attendance' do
        pending_gateway = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        accepted_gateway = FactoryBot.create(:attendance, event: event, status: :accepted, last_status_change_date: 7.days.ago)
        FactoryBot.create(:attendance, status: :accepted, registration_date: 7.days.ago)
        Invoice.from_attendance(pending_gateway, 'gateway')
        Invoice.from_attendance(accepted_gateway, 'gateway')
        expect(AttendanceRepository.instance.for_cancelation_warning(event)).to match_array [pending_gateway, accepted_gateway]
      end
    end

    context 'with two pending and gateway as payment type' do
      it 'returns the both attendances' do
        pending_gateway = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(pending_gateway, 'gateway')

        other_pending_gateway = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(other_pending_gateway, 'gateway')

        expect(AttendanceRepository.instance.for_cancelation_warning(event)).to eq [pending_gateway, other_pending_gateway]
      end
    end

    context 'with one pending and gateway as payment type and other bank deposit' do
      it 'returns the attendance pending gateway' do
        pending_gateway = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(pending_gateway, 'gateway')

        pending_deposit = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(pending_deposit, 'bank_deposit')

        expect(AttendanceRepository.instance.for_cancelation_warning(event)).to eq [pending_gateway]
      end
    end

    context 'with one pending and gateway as payment type and other statement of agreement' do
      it 'returns the attendance pending gateway' do
        pending_gateway = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(pending_gateway, 'gateway')

        pending_statement = FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        Invoice.from_attendance(pending_statement, 'statement_agreement')

        expect(AttendanceRepository.instance.for_cancelation_warning(event)).to eq [pending_gateway]
      end
    end

    context 'with a pending status and belonging to a group' do
      let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago) }
      let!(:invoice) { Invoice.from_attendance(pending, 'gateway') }
      let!(:group) { FactoryBot.create :registration_group, automatic_approval: false }
      let!(:pending_in_a_group) { FactoryBot.create(:attendance, registration_group: group, event: event, last_status_change_date: 7.days.ago) }
      let!(:other_invoice) { Invoice.from_attendance(pending_in_a_group, 'gateway') }
      let!(:accepted_in_a_group) { FactoryBot.create(:attendance, status: :accepted, registration_group: group, event: event, last_status_change_date: 7.days.ago) }
      let!(:other_invoice) { Invoice.from_attendance(accepted_in_a_group, 'gateway') }

      it { expect(AttendanceRepository.instance.for_cancelation_warning(event)).to match_array [pending, accepted_in_a_group] }
    end
  end

  describe '#for_cancelation' do
    let(:invoice) { FactoryBot.create(:invoice, payment_type: 'gateway') }
    let!(:to_cancel) { FactoryBot.create(:attendance, event: event, advised_at: 8.days.ago, due_date: 1.day.ago, advised: true, invoices: [invoice]) }
    let(:out_invoice) { FactoryBot.create(:invoice, payment_type: 'gateway') }
    let!(:out) { FactoryBot.create(:attendance, event: event, advised_at: 5.days.ago, advised: true, invoices: [out_invoice]) }
    let(:other_out_invoice) { FactoryBot.create(:invoice, payment_type: 'gateway') }
    let!(:other_out) { FactoryBot.create(:attendance, event: event, advised_at: nil, advised: false, created_at: 15.days.ago, invoices: [other_out_invoice]) }
    it { expect(AttendanceRepository.instance.for_cancelation(event)).to eq [to_cancel] }
  end

  describe '#attendances_for' do
    let(:user) { FactoryBot.create :user }
    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user) }
    let!(:out) { FactoryBot.create(:attendance, user: user) }
    it { expect(AttendanceRepository.instance.attendances_for(event, user)).to eq [attendance] }
  end

  describe '#for_event' do
    let(:user) { FactoryBot.create :user }
    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user) }
    let!(:out) { FactoryBot.create(:attendance, user: user) }
    it { expect(AttendanceRepository.instance.for_event(event)).to eq [attendance] }
  end

  describe '#event_queue' do
    let!(:first_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
    let!(:second_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: Time.zone.today }
    let!(:third_waiting) { FactoryBot.create :attendance, event: event, status: :waiting, created_at: 2.days.ago }

    it { expect(AttendanceRepository.instance.event_queue(event)).to eq [third_waiting, second_waiting, first_waiting] }
  end

  describe '_older_than' do
    let(:user) { FactoryBot.create :user }
    let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user, last_status_change_date: 2.days.ago) }
    let!(:other_attendance) { FactoryBot.create(:attendance, event: event, user: user, last_status_change_date: 4.days.ago) }
    it { expect(AttendanceRepository.instance.send(:older_than)).to match_array [attendance, other_attendance] }
    it { expect(AttendanceRepository.instance.send(:older_than, 3.days.ago)).to eq [other_attendance] }
  end
end
