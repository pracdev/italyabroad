class CreateSimpleCaptchaData < ActiveRecord::Migration
  def self.up
    #drop_table :simple_captcha_data
    unless ActiveRecord::Base.connection.table_exists? :simple_captcha_data
      create_table :simple_captcha_data do |t|
        t.string :key, :limit => 40
        t.string :value, :limit => 6
        t.timestamps
      end
    end

    add_index :simple_captcha_data, :key, :name => "idx_key"
  end

  def self.down
    drop_table :simple_captcha_data
  end
end
