class BusinessIndexLookupCache
  def initialize
    @cache = {}
  end
  
  def resolve_code(id_column, id, business_index_name)
    @cache[business_index_name] ||= {}
    unless value = @cache[business_index_name][id]
      class_name = id_column.to_s.sub(/_id$/, '').classify
      cls = class_name.constantize
      @cache[business_index_name][id] = value = cls.find(id).send(business_index_name)
    end
    value
  end
end
