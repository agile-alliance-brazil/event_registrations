# encoding: UTF-8
module ValidatesExistenceMacros
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def should_validate_existence_of(*associations)
      allow_nil = associations.extract_options![:allow_nil]

      if allow_nil
        associations.each do |association|
          it "allows #{association} to be nil" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            object.valid?
            expect(object.errors[reflection.foreign_key.to_sym]).not_to include(I18n.t('activerecord.errors.messages.existence'))
          end
        end
      else
        associations.each do |association|
          it "requires #{association} exists" do
            reflection = subject.class.reflect_on_association(association)
            object = subject
            object.send("#{association}=", nil)
            expect(object).not_to be_valid
            expect(object.errors[reflection.foreign_key.to_sym]).to include(I18n.t('activerecord.errors.messages.existence'))
          end
        end
      end
    end
  end
end
