# encoding: UTF-8

describe AttendanceParams, type: :param_object do
  describe '#new_attributes' do
    it 'returns all parameters for attendance' do
      user = FactoryGirl.create :user
      event = FactoryGirl.create :event
      valid_attendance =
        {
          event_id: event.id,
          user_id: user.id,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          email_confirmation: user.email,
          organization: user.organization,
          phone: user.phone,
          country: user.country,
          state: user.state,
          city: user.city,
          badge_name: user.badge_name,
          cpf: user.cpf,
          gender: user.gender,
          twitter_user: user.twitter_user,
          address: user.address,
          neighbourhood: user.neighbourhood,
          zipcode: user.zipcode
        }
      now = Time.zone.now
      Time.stubs(:now).returns(now)
      params = ActionController::Parameters.new(valid_attendance)
      params_object = AttendanceParams.new(user, event, params)
      expect(params_object.new_attributes).to eq({ 'first_name' => user.first_name,
                                                   'last_name' => user.last_name,
                                                   'email' => user.email,
                                                   'organization' => user.organization,
                                                   'phone' => user.phone,
                                                   'country' => user.country,
                                                   'state' => user.state,
                                                   'city' => user.city,
                                                   'badge_name' => user.badge_name,
                                                   'cpf' => "#{user.cpf}",
                                                   'gender' => user.gender,
                                                   'twitter_user' => user.twitter_user,
                                                   'address' => user.address,
                                                   'neighbourhood' => user.neighbourhood,
                                                   'zipcode' => user.zipcode,
                                                   'registration_group_id' => nil,
                                                   :email_confirmation => user.email,
                                                   :event_id => 12,
                                                   :user_id => 1,
                                                   :registration_date => now })
      expect(params_object.event).to eq event
      expect(params_object.user).to eq user
    end
  end

  pending '#payment_type_params'
  pending '#attributes_hash'
end