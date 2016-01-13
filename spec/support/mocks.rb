# This helper module makes it easy to make modifications to classes for the duration of an example
# e.g. mock_class(Project) { after_save :do_something }
# At the end of the example,:classes are reverted to their original behaviour
module Mocks
  mattr_accessor :classes
  self.classes = []
  mattr_accessor :example_counter
  self.example_counter = 0

  def mock_class(original_class, &block)
    Mocks.classes << original_class
    original_class.class_eval(&block)
  end

  def unmock_class
    load 'support/models.rb'
  end

  def mock_callback(klass, type, &block)
    count = Mocks.example_counter
    klass.send type, :if => proc { Mocks.example_counter == count}, &block # Only run the callback for this example
  end

  def self.included(example_group)
    example_group.after do
      unmock_class if Mocks.classes.present?
      Mocks.example_counter += 1
    end
  end
end
