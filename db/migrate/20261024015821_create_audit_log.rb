class CreateAuditLog < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.bigint :user_id
      t.string :action, null: false
      t.string :record_type
      t.bigint :record_id
      t.jsonb :change_set, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}
      t.inet :ip_address
      t.string :user_agent
      t.datetime :created_at, null: false
    end

    add_index :audit_logs, :created_at
    add_index :audit_logs, [ :user_id, :created_at ]
    add_index :audit_logs, [ :action, :created_at ]
    add_index :audit_logs, [ :record_type, :record_id ]
  end
end
