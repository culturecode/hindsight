class Company < ActiveRecord::Base
  has_many :project_companies
  has_many :projects, :through => :project_companies

  has_hindsight :associations => { :versioned => :projects }
end

class Project < ActiveRecord::Base
  has_many :documents
  has_many :project_companies
  has_many :companies, :through => :project_companies

  has_hindsight :associations => { :versioned => [:documents, :companies] }
end

class Document < ActiveRecord::Base
  belongs_to :project
  has_many :document_authors
  has_many :authors, :through => :document_authors
  has_many :comments

  has_hindsight :associations => { :versioned => [] }
end

class Author < ActiveRecord::Base
  has_many :documents, :through => :document_authors
end

class Comment < ActiveRecord::Base
  belongs_to :document
end

class ProjectCompany < ActiveRecord::Base
  belongs_to :project
  belongs_to :company
end

class DocumentAuthor < ActiveRecord::Base
  belongs_to :document
  belongs_to :author
end
