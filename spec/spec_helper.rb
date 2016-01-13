# Configure Rails Environment
require 'pry'
require 'active_record'
require 'hindsight'

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveRecord::Base.establish_connection(:adapter => "postgresql", :database => "hindsight_test")

ActiveRecord::Schema.define(:version => 0) do
  create_table :companies, :force => true do |t|
    t.string :name
  end

  create_table :projects, :force => true do |t|
    t.string :name
  end

  create_table :documents, :force => true do |t|
    t.references :project, :index => true
    t.string :title
    t.text :body
  end

  create_table :authors, :force => true do |t|
  end

  create_table :comments, :force => true do |t|
    t.references :document, :index => true
  end

  create_table :document_authors, :force => true do |t|
    t.references :document, :index => true
    t.references :author, :index => true
    t.text :metadata
  end

  create_table :project_companies, :force => true do |t|
    t.references :project, :index => true
    t.references :company, :index => true
    t.text :metadata
  end

  Hindsight::Schema.version_table!(:companies, :projects, :documents)
end

RSpec.configure do |config|
  # Manually implement transactional examples because we're not using rspec_rails
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  config.include Mocks
end

# Make it easy to say expect(object).to not_have_any( be_sunday )
# The opposite of saying expect(object).to all( be_sunday )
RSpec::Matchers.define_negated_matcher :have_none, :include
