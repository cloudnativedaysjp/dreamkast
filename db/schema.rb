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

ActiveRecord::Schema[7.0].define(version: 2022_11_12_064311) do
  create_table "access_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "sub"
    t.string "page"
    t.string "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "profile_id"
  end

  create_table "admin_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "sub"
    t.string "email"
    t.string "name"
    t.string "twitter_id"
    t.string "github_id"
    t.text "avatar_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "show_on_team_page"
    t.index ["conference_id"], name: "index_admin_profiles_on_conference_id"
  end

  create_table "agreements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "form_item_id"
    t.integer "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "announcements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.datetime "publish_time", precision: nil
    t.text "body"
    t.boolean "publish"
    t.index ["conference_id"], name: "index_announcements_on_conference_id"
  end

  create_table "booths", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_booths_on_conference_id"
    t.index ["sponsor_id"], name: "index_booths_on_sponsor_id"
  end

  create_table "cancel_orders", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "order_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_cancel_orders_on_order_id"
  end

  create_table "chat_messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "profile_id"
    t.bigint "speaker_id"
    t.string "body"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "room_type"
    t.bigint "room_id"
    t.integer "message_type"
    t.index ["conference_id"], name: "index_chat_messages_on_conference_id"
    t.index ["lft"], name: "index_chat_messages_on_lft"
    t.index ["parent_id"], name: "index_chat_messages_on_parent_id"
    t.index ["profile_id"], name: "index_chat_messages_on_profile_id"
    t.index ["rgt"], name: "index_chat_messages_on_rgt"
    t.index ["speaker_id"], name: "index_chat_messages_on_speaker_id"
  end

  create_table "check_ins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "order_id"
    t.string "ticket_id"
    t.index ["profile_id"], name: "index_check_ins_on_profile_id"
  end

  create_table "conference_days", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.bigint "conference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "internal", default: false, null: false
    t.index ["conference_id"], name: "index_conference_days_on_conference_id"
  end

  create_table "conferences", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "abbr"
    t.integer "status", default: 0, null: false
    t.text "theme"
    t.text "about"
    t.text "privacy_policy"
    t.text "coc"
    t.string "copyright"
    t.text "privacy_policy_for_speaker"
    t.integer "speaker_entry"
    t.integer "attendee_entry"
    t.integer "show_timetable"
    t.boolean "cfp_result_visible", default: false
    t.boolean "show_sponsors", default: false
    t.string "brief"
    t.string "committee_name", default: "CloudNative Days Committee", null: false
    t.index ["status"], name: "index_conferences_on_status"
  end

  create_table "form_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "conference_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "industries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
  end

  create_table "links", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "title"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_links_on_conference_id"
  end

  create_table "live_streams", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "track_id", null: false
    t.string "type"
    t.json "params"
    t.index ["conference_id"], name: "index_live_streams_on_conference_id"
    t.index ["track_id"], name: "index_live_streams_on_track_id"
  end

  create_table "media_package_channels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "track_id", null: false
    t.string "channel_id", default: ""
    t.index ["channel_id"], name: "index_media_package_channels_on_channel_id"
    t.index ["conference_id"], name: "index_media_package_channels_on_conference_id"
    t.index ["track_id"], name: "index_media_package_channels_on_track_id"
  end

  create_table "media_package_harvest_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "media_package_channel_id", null: false
    t.bigint "talk_id", null: false
    t.string "job_id"
    t.string "status"
    t.datetime "start_time", precision: nil
    t.datetime "end_time", precision: nil
    t.index ["conference_id"], name: "index_media_package_harvest_jobs_on_conference_id"
    t.index ["media_package_channel_id"], name: "index_media_package_harvest_jobs_on_media_package_channel_id"
    t.index ["talk_id"], name: "index_media_package_harvest_jobs_on_talk_id"
  end

  create_table "media_package_origin_endpoints", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "media_package_channel_id", null: false
    t.string "endpoint_id"
    t.index ["conference_id"], name: "index_media_package_origin_endpoints_on_conference_id"
    t.index ["media_package_channel_id"], name: "index_media_package_origin_endpoints_on_media_package_channel_id"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "content"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_orders_on_profile_id"
  end

  create_table "orders_tickets", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "order_id", null: false
    t.string "ticket_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_orders_tickets_on_order_id"
    t.index ["ticket_id"], name: "index_orders_tickets_on_ticket_id"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "sub"
    t.string "email"
    t.string "last_name"
    t.string "first_name"
    t.integer "industry_id"
    t.string "occupation"
    t.string "company_name"
    t.string "company_email"
    t.string "company_address"
    t.string "company_tel"
    t.string "department"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
    t.string "company_address_prefecture_id"
    t.string "first_name_kana"
    t.string "last_name_kana"
    t.string "company_name_prefix_id"
    t.string "company_name_suffix_id"
    t.string "company_postal_code"
    t.string "company_address_level1"
    t.string "company_address_level2"
    t.string "company_address_line1"
    t.string "company_address_line2"
    t.integer "number_of_employee_id", default: 12
    t.integer "annual_sales_id", default: 11
    t.string "company_fax"
    t.string "calendar_unique_code"
  end

  create_table "proposal_item_configs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "type"
    t.integer "item_number"
    t.string "label"
    t.string "item_name"
    t.json "params"
    t.text "description"
    t.string "key"
    t.string "value"
    t.index ["conference_id"], name: "index_proposal_item_configs_on_conference_id"
  end

  create_table "proposal_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "talk_id", null: false
    t.string "label"
    t.json "params"
    t.index ["conference_id"], name: "index_proposal_items_on_conference_id"
    t.index ["talk_id"], name: "index_proposal_items_on_talk_id"
  end

  create_table "proposals", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "talk_id", null: false
    t.integer "conference_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "registered_talks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "talk_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "track_id"
    t.string "name", null: false
    t.text "description"
    t.integer "number_of_seats", default: 0, null: false
    t.integer "integer", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_rooms_on_conference_id"
    t.index ["track_id"], name: "index_rooms_on_track_id"
  end

  create_table "speaker_announcement_middles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "speaker_id", null: false
    t.bigint "speaker_announcement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaker_announcement_id"], name: "index_speaker_announcement_middles_on_speaker_announcement_id"
    t.index ["speaker_id"], name: "index_speaker_announcement_middles_on_speaker_id"
  end

  create_table "speaker_announcements", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.datetime "publish_time", precision: nil, null: false
    t.text "body", null: false
    t.boolean "publish", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "receiver", default: 0, null: false
    t.index ["conference_id"], name: "index_speaker_announcements_on_conference_id"
  end

  create_table "speakers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.text "profile"
    t.string "company"
    t.string "job_title"
    t.string "twitter_id"
    t.string "github_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "avatar_data"
    t.integer "conference_id"
    t.text "email"
    t.text "sub"
    t.text "additional_documents"
    t.string "name_mother_tongue"
  end

  create_table "sponsor_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "sponsor_id", null: false
    t.string "type"
    t.string "title"
    t.string "url"
    t.text "text"
    t.string "link"
    t.boolean "public"
    t.string "file_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sponsor_id"], name: "index_sponsor_attachments_on_sponsor_id"
  end

  create_table "sponsor_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "sub"
    t.string "email"
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_sponsor_profiles_on_conference_id"
    t.index ["sponsor_id"], name: "index_sponsor_profiles_on_sponsor_id"
  end

  create_table "sponsor_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_sponsor_types_on_conference_id"
  end

  create_table "sponsors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.text "description"
    t.string "url"
    t.bigint "conference_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "speaker_emails"
    t.index ["conference_id"], name: "index_sponsors_on_conference_id"
  end

  create_table "sponsors_sponsor_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "sponsor_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stats_of_registrants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id"
    t.integer "number_of_registrants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_stats_of_registrants_on_conference_id"
  end

  create_table "talk_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
  end

  create_table "talk_difficulties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
  end

  create_table "talk_times", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.integer "time_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_talk_times_on_conference_id"
  end

  create_table "talks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "title"
    t.text "abstract"
    t.string "movie_url"
    t.time "start_time"
    t.time "end_time"
    t.bigint "talk_difficulty_id"
    t.bigint "talk_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
    t.integer "conference_day_id"
    t.integer "track_id"
    t.boolean "video_published", default: false, null: false
    t.string "document_url"
    t.boolean "show_on_timetable"
    t.integer "talk_time_id"
    t.json "expected_participants"
    t.json "execution_phases"
    t.integer "sponsor_id"
    t.integer "start_offset", default: 0, null: false
    t.integer "end_offset", default: 0, null: false
    t.integer "number_of_seats", default: 0, null: false
    t.integer "acquired_seats", default: 0, null: false
    t.index ["conference_id"], name: "index_talks_on_conference_id"
    t.index ["talk_category_id"], name: "index_talks_on_talk_category_id"
    t.index ["talk_difficulty_id"], name: "index_talks_on_talk_difficulty_id"
  end

  create_table "talks_speakers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "talk_id"
    t.integer "speaker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tickets", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.integer "price", null: false
    t.integer "stock", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_tickets_on_conference_id"
  end

  create_table "tracks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "video_id"
    t.integer "conference_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video_platform"
    t.bigint "room_id", default: 0
  end

  create_table "video_registrations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.string "url"
    t.integer "status", default: 0, null: false
    t.json "statistics", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["talk_id"], name: "index_video_registrations_on_talk_id"
  end

  create_table "videos", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "talk_id"
    t.string "site"
    t.string "url"
    t.boolean "on_air"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "video_id"
    t.string "slido_id"
    t.text "video_file_data"
  end

  create_table "viewer_counts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "conference_id"
    t.integer "track_id"
    t.string "stream_type"
    t.integer "talk_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_viewer_counts_on_conference_id"
    t.index ["talk_id"], name: "index_viewer_counts_on_talk_id"
    t.index ["track_id"], name: "index_viewer_counts_on_track_id"
  end

  add_foreign_key "admin_profiles", "conferences"
  add_foreign_key "announcements", "conferences"
  add_foreign_key "booths", "conferences"
  add_foreign_key "booths", "sponsors"
  add_foreign_key "cancel_orders", "orders"
  add_foreign_key "chat_messages", "conferences"
  add_foreign_key "chat_messages", "profiles"
  add_foreign_key "chat_messages", "speakers"
  add_foreign_key "links", "conferences"
  add_foreign_key "live_streams", "conferences"
  add_foreign_key "live_streams", "tracks"
  add_foreign_key "media_package_channels", "conferences"
  add_foreign_key "media_package_channels", "tracks"
  add_foreign_key "media_package_harvest_jobs", "conferences"
  add_foreign_key "media_package_harvest_jobs", "media_package_channels"
  add_foreign_key "media_package_harvest_jobs", "talks"
  add_foreign_key "media_package_origin_endpoints", "conferences"
  add_foreign_key "media_package_origin_endpoints", "media_package_channels"
  add_foreign_key "orders", "profiles"
  add_foreign_key "orders_tickets", "orders"
  add_foreign_key "orders_tickets", "tickets"
  add_foreign_key "proposal_item_configs", "conferences"
  add_foreign_key "proposal_items", "conferences"
  add_foreign_key "rooms", "conferences"
  add_foreign_key "rooms", "tracks"
  add_foreign_key "speaker_announcement_middles", "speaker_announcements"
  add_foreign_key "speaker_announcement_middles", "speakers"
  add_foreign_key "speaker_announcements", "conferences"
  add_foreign_key "sponsor_attachments", "sponsors"
  add_foreign_key "sponsor_profiles", "conferences"
  add_foreign_key "sponsor_types", "conferences"
  add_foreign_key "sponsors", "conferences"
  add_foreign_key "talk_times", "conferences"
  add_foreign_key "tickets", "conferences"
  add_foreign_key "video_registrations", "talks"
end
