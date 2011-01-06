module ArBlankToNil
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def convert_blank_to_nil(*attrs)
      attrs.each do |attr|
        if instance_methods.include?("#{attr}=")
          alias_method "#{attr}_without_ar_blank_to_nil=", "#{attr}="
        end
        define_method("#{attr}=") do |new_value|
          new_value = nil if new_value.blank?
          if respond_to?("#{attr}_without_ar_blank_to_nil=")
            send("#{attr}_without_ar_blank_to_nil=", new_value)
          else
            write_attribute(attr, new_value)
          end
        end
      end
    end
  end
end

ActiveRecord::Base.class_eval do
  include ArBlankToNil
end
