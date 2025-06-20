# frozen_string_literal: true

Sequel.migration do
  change do
    # Example:
    # create_table(:users) do
    #   primary_key :id
    #   String :first_name, null: false
    #   String :last_name, null: true
    # end

    create_table(:conditions) do
      primary_key :id
      String :url, null: false, unique: true
      String :regex, null: false
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:feeds) do
      primary_key :id
      String :name, null: false
      String :link, null: false
      Integer :crc32
      DateTime :created_at
      DateTime :updated_at
    end

    create_table(:past_updates) do
      primary_key :id
      String :title, null: false
      String :link, null: false
      String :thumbnail
      DateTime :published, null: false
      foreign_key :feed_id, :feeds, null: false, on_delete: :cascade
      DateTime :created_at
    end

    create_table(:logs) do
      primary_key :id
      String :message, null: false
      String :level
      DateTime :created_at
    end
  end
end
