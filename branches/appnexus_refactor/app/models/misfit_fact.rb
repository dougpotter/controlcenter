class MisfitFact < ActiveRecord::Base
  has_no_table

  column :fact_class, :string
  column :fact_attributes, :hash
  column :anomaly, :string

  validates_presence_of :fact_class, :fact_attributes, :anomaly
  validates_format_of :anomaly, :with => /(\A[a-z_]+\:[A-Z1-9\-]+\z|\A[a-z_]+\:[A-Z1-9\-]+\:[a-z_]+\:[A-Z1-9\-]+)\z/
  validate :anomaly_as_string
  validate :fact_as_fact

  def fact_as_fact
    if !fact_class.nil?
      begin
        model_class = ActiveRecord.const_get(fact_class.classify)
        if !model_class.is_fact?
          errors.add_to_base "fact must be of type Fact"
        end
      rescue
        errors.add_to_base "fact must be of type Fact"
      end
    end
  end

  def anomaly_as_string
    if anomaly.class != String
      errors.add_to_base "anomaly must be of type String"
    end
  end
  
  def save
    require 'mongo'
    if valid?
      db = Mongo::Connection.new.db("misfit_facts")
      coll = db.collection(fact_class)
      coll.ensure_index('anomaly')
      doc = { :anomaly => anomaly, :fact => fact_attributes }
      coll.insert(doc)
    else
      false
    end
  end

  def save!
    require 'mongo'
    if valid?
      db = Mongo::Connection.new.db("misfit_facts")
      coll = db.collection(fact_class)
      coll.ensure_index('anomaly')
      doc = { :anomaly => anomaly, :fact => fact_attributes }
      coll.insert(doc)
    else
      raise ActiveRecord::RecordInvalid, self
    end
  end
end
