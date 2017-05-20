class BurnupPresenter
  attr_accessor :ideal, :actual

  def initialize(ideal, actual)
    self.ideal = ideal
    self.actual = actual
  end
end
