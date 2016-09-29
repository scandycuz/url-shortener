class ModifyVisitCol < ActiveRecord::Migration
  def change
    remove_column :visits, :shortened_url_id
    add_column :visits, :shortened_url_id, :integer
  end
end
