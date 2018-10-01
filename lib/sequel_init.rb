Sequel::Model.plugin :active_model
Sequel::Model.plugin :boolean_readers
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :timestamps
Sequel::Model.plugin :association_pks, delay_pks: false

Sequel.extension :core_extensions
DB.extension :pg_array

class Sequel::Postgres::PGArray
  def pg_array(blah)
    self
  end
end
