# frozen_string_literal: true

puts Event.all.map do |e|
  [e.name, 'id,name,registration date,registration fee,city,state,organization,email,status,events', e.attendances.map do |a|
    [a.id, a.full_name, a.registration_date, a.registration_value, a.city, a.state, a.organization, a.email, a.status, [a.event, a.user.attendances.map(&:event)].flatten.uniq.map(&:name).join('/')].map { |entry| CSV.generate_line(entry) }
  end]
end
