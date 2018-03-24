# frozen_string_literal: true

# ApplicationJob is an extra layer of indirection to ActiveJob::Base which
# allows us to customize its behavior per application without monkey patching
class ApplicationJob < ActiveJob::Base
end
