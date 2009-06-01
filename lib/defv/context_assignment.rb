module Defv
  module ContextAssignment
    module ClassMethods
      def attr_protected_with_context(*attributes)
        options = attributes.extract_options!
        context = options[:context] || :default
        write_inheritable_hash(:attr_protected, {context => attributes.map(&:to_s)})
      end

      def protected_attributes_with_context(context = :default)
        (read_inheritable_attribute(:attr_protected) || {})[context]
      end

      def attr_accessible_with_context(*attributes)
        options = attributes.extract_options!
        context = options[:context] || :default
        write_inheritable_hash(:attr_accessible, {context => attributes.map(&:to_s)})
      end

      def accessible_attributes_with_context(context = :default)
        (read_inheritable_attribute(:attr_accessible) || {})[context]
      end

      def create_with_context(attributes, *args)
        # This isn't optimal but don't know how to fix this without re-implementing the whole create method
        create_without_context(attributes) do |object|
          object.define_assignment_context(args)
          object.send('attributes=', attributes)
          yield if block_given?
        end
      end

      def assignment_contexts
        (read_inheritable_attribute(:attr_accessible) || {}).keys + (read_inheritable_attribute(:attr_protected) || {}).keys
      end
    end
    
    def define_assignment_context(args)
      options = args.extract_options!
      if options.has_key? :context
        raise "No such context: #{options[:context]}" unless self.class.assignment_contexts.include?(options[:context])
        @assignment_context = options[:context]
      end
    end
    
    def attributes_with_context=(attributes, *args)
      define_assignment_context(args)      
      send(:attributes_without_context=, attributes, *args)
    end
    
    def initialize_with_context(attributes = nil, *args)
      define_assignment_context(args)      
      initialize_without_context(attributes, *args)
    end
    
    def update_attributes_with_context(attributes, *args)
      define_assignment_context(args)
      update_attributes_without_context(attributes, *args)
    end

    def update_attributes_with_context!(attributes, *args)
      define_assignment_context(args)
      update_attributes_without_context!(attributes, *args)
    end
    
    def remove_attributes_protected_from_mass_assignment_with_context(attributes, options = {})
      context = options[:context] || @assignment_context || :default
      
      safe_attributes =
        if self.class.accessible_attributes(context).nil? && self.class.protected_attributes(context).nil?
          attributes.reject { |key, value| attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
        elsif self.class.protected_attributes(context).nil?
          attributes.reject { |key, value| !self.class.accessible_attributes(context).include?(key.gsub(/\(.+/, "")) || attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
        elsif self.class.accessible_attributes(context).nil?
          attributes.reject { |key, value| self.class.protected_attributes(context).include?(key.gsub(/\(.+/,"")) || attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
        else
          raise "Declare either attr_protected or attr_accessible for #{self.class}, but not both."
        end

      removed_attributes = attributes.keys - safe_attributes.keys

      if removed_attributes.any?
        log_protected_attribute_removal(removed_attributes)
      end

      safe_attributes
    end

    def self.included(base)
      base.extend ClassMethods
   
      base.alias_method_chain :attributes=, :context
      base.alias_method_chain :initialize, :context
      base.alias_method_chain :update_attributes, :context
      base.alias_method_chain :update_attributes!, :context
      base.alias_method_chain :remove_attributes_protected_from_mass_assignment, :context
    
      base.class_eval do
        class << self
          alias_method_chain :attr_protected, :context
          alias_method_chain :protected_attributes, :context
          alias_method_chain :attr_accessible, :context
          alias_method_chain :accessible_attributes, :context
          alias_method_chain :create, :context
        end
      end
    end
  end
end