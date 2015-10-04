# encoding: utf-8

namespace :update_events_localization_2015 do
  desc 'Generates seeds'
  task :seeds => :environment do
    Event.find_by(id: 12).try { update(location_and_date: 'http://www.agilebrazil.com/2015/localizacao.html') }
    Event.find_by(id: 13).try { update(location_and_date: 'http://www.agilebrazil.com/2015/virada-safe.html') }
    Event.find_by(id: 15).try { update(location_and_date: 'http://www.agilebrazil.com/2015/virada-fearless-change.html') }
    Event.find_by(id: 16).try { update(location_and_date: 'http://www.agilebrazil.com/2015/virada-learning30.html') }
    Event.find_by(id: 17).try { update(location_and_date: 'http://www.agilebrazil.com/2015/virada-direto-ao-ponto.html') }
    puts '√'
  end

  desc 'Generates all'
  task :all => [:seeds]
end
