# encoding: UTF-8
require 'spec_helper'

describe Gender do
  it "should provide translated options for select" do
    I18n.with_locale(:en) do
      Gender.options_for_select.should include(['Male', 'M'])
      Gender.options_for_select.should include(['Female', 'F'])
      Gender.options_for_select.size.should == 2
    end
  end
  
  it "should provide valid values" do
    Gender.valid_values.should == %w(M F)
  end
  
  it "should provide title for given value" do
    I18n.with_locale(:en) do
      Gender.title_for('M').should == 'Male'
      Gender.title_for('F').should == 'Female'
    end
  end
end
