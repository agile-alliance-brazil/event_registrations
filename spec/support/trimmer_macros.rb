# frozen_string_literal: true

module TrimmerMacros
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def it_should_trim_attributes(model_class, *attrs)
      context 'trimming' do
        attrs.each do |attr|
          it "should trim #{attr}" do
            model = model_class.new(attr.to_sym => '  needs trimming  ')
            model.valid?
            expect(model.send(attr)).to eq('needs trimming')
          end
        end
      end
    end
  end
end
