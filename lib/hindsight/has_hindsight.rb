module Hindsight
  module ActMethod
    def has_hindsight(options = {})
      extend Hindsight::ClassMethods
      include Hindsight::InstanceMethods

      has_many :versions, :class_name => name, :primary_key => :versioned_record_id, :foreign_key => :versioned_record_id do
        def previous
          where('version < ?', proxy_association.owner.version).reorder('version DESC').first
        end
        def next
          where('version > ?', proxy_association.owner.version).reorder('version ASC').first
        end
      end

      after_create :init_versioned_record_id
    end
  end

  module ClassMethods
    def acts_like_hindsight?
      true
    end
  end

  module InstanceMethods
    def acts_like_hindsight?
      true
    end

    def new_version(&block)
      create_new_version(&block)
    end

    def create_or_update_with_versioning
      next_version = create_new_version
      self.id = next_version.id
      reload
      clear_association_cache
      return true
    end

    def self.included(base)
      base.alias_method_chain :create_or_update, :versioning
    end

    private

    def create_new_version(&block)
      new_version = dup
      new_version.version += 1
      copy_associations_to(new_version)
      new_version.send(:create_or_update_without_versioning, &block)
      return new_version
    end

    # Copy associations with a foreign_key to this record, onto the new version
    def copy_associations_to(new_version)
      self.class.reflections.each do |association_name, reflection|
        next if association_name == 'versions' # Don't try to copy versions
        case reflection
        when ActiveRecord::Reflection::HasManyReflection, ActiveRecord::Reflection::HasOneReflection
          new_version.send("#{association_name}=", send(association_name))
        end
      end
    end

    def has_hindsight?(other)
      other.acts_like? :hindsight
    end

    def init_versioned_record_id
      update_column(:versioned_record_id, id) unless versioned_record_id.present?
    end
  end
end
