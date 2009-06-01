ActiveRecord::Schema.define do
  create_table "people", :force => true do |t|
    t.column "name",        :string
    t.column "first_name",  :string
    t.column "is_admin",    :boolean
    t.column "api_key",     :string
  end
end