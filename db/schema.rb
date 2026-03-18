# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_17_191454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manga_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["manga_id"], name: "index_bookmarks_on_manga_id"
    t.index ["user_id", "manga_id"], name: "index_bookmarks_on_user_id_and_manga_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "chapters", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manga_id", null: false
    t.text "notes"
    t.decimal "number", precision: 6, scale: 1, null: false
    t.datetime "published_at"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["manga_id", "number"], name: "index_chapters_on_manga_id_and_number", unique: true
    t.index ["manga_id"], name: "index_chapters_on_manga_id"
    t.index ["published_at"], name: "index_chapters_on_published_at"
  end

  create_table "manga_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manga_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["manga_id", "tag_id"], name: "index_manga_tags_on_manga_id_and_tag_id", unique: true
    t.index ["manga_id"], name: "index_manga_tags_on_manga_id"
    t.index ["tag_id"], name: "index_manga_tags_on_tag_id"
  end

  create_table "mangas", force: :cascade do |t|
    t.string "author", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "genre", default: 0, null: false
    t.decimal "rating", default: "0.0", null: false
    t.integer "status", default: 0, null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["genre"], name: "index_mangas_on_genre"
    t.index ["status"], name: "index_mangas_on_status"
    t.index ["title"], name: "index_mangas_on_title"
    t.index ["views_count"], name: "index_mangas_on_views_count"
  end

  create_table "pages", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["chapter_id", "number"], name: "index_pages_on_chapter_id_and_number", unique: true
    t.index ["chapter_id"], name: "index_pages_on_chapter_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manga_id", null: false
    t.integer "score", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["manga_id"], name: "index_ratings_on_manga_id"
    t.index ["user_id", "manga_id"], name: "index_ratings_on_user_id_and_manga_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
  end

  create_table "reading_progresses", force: :cascade do |t|
    t.bigint "chapter_id", null: false
    t.datetime "created_at", null: false
    t.bigint "manga_id", null: false
    t.integer "page_number", default: 1, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["chapter_id"], name: "index_reading_progresses_on_chapter_id"
    t.index ["manga_id"], name: "index_reading_progresses_on_manga_id"
    t.index ["user_id", "manga_id"], name: "index_reading_progresses_on_user_id_and_manga_id", unique: true
    t.index ["user_id"], name: "index_reading_progresses_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "mangas"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "chapters", "mangas"
  add_foreign_key "manga_tags", "mangas"
  add_foreign_key "manga_tags", "tags"
  add_foreign_key "pages", "chapters"
  add_foreign_key "ratings", "mangas"
  add_foreign_key "ratings", "users"
  add_foreign_key "reading_progresses", "chapters"
  add_foreign_key "reading_progresses", "mangas"
  add_foreign_key "reading_progresses", "users"
end
