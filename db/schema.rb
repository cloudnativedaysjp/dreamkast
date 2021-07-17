# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_07_04_103023) do

  create_table "access_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "sub"
    t.string "page"
    t.string "ip"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "profile_id"
  end

  create_table "agreements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "form_item_id"
    t.integer "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "announcements", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.datetime "publish_time"
    t.text "body"
    t.boolean "publish"
    t.index ["conference_id"], name: "index_announcements_on_conference_id"
  end

  create_table "booths", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.boolean "published"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conference_id"], name: "index_booths_on_conference_id"
    t.index ["sponsor_id"], name: "index_booths_on_sponsor_id"
  end

  create_table "chat_messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "profile_id"
    t.bigint "speaker_id"
    t.string "body"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

  create_table "conference_days", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.bigint "conference_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "internal", default: false, null: false
    t.index ["conference_id"], name: "index_conference_days_on_conference_id"
  end

  create_table "conferences", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.index ["status"], name: "index_conferences_on_status"
  end

  create_table "form_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "conference_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "industries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "conference_id"
  end

  create_table "links", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "title"
    t.string "url"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conference_id"], name: "index_links_on_conference_id"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "content"
    t.string "text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
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
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "conference_id"
  end

  create_table "proposal_item_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "type"
    t.integer "item_number"
    t.string "label"
    t.string "item_name"
    t.json "params"
    t.index ["conference_id"], name: "index_proposal_item_configs_on_conference_id"
  end

  create_table "proposals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "talk_id", null: false
    t.integer "conference_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "registered_talks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "talk_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "speakers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "profile"
    t.string "company"
    t.string "job_title"
    t.string "twitter_id"
    t.string "github_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "avatar_data"
    t.integer "conference_id"
    t.text "email"
    t.text "sub"
    t.text "additional_documents"
  end

  create_table "sponsor_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "sponsor_id", null: false
    t.string "type"
    t.string "title"
    t.string "url"
    t.text "text"
    t.string "link"
    t.boolean "public"
    t.string "file_data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sponsor_id"], name: "index_sponsor_attachments_on_sponsor_id"
  end

  create_table "sponsor_profiles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "sub"
    t.string "email"
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conference_id"], name: "index_sponsor_profiles_on_conference_id"
    t.index ["sponsor_id"], name: "index_sponsor_profiles_on_sponsor_id"
  end

  create_table "sponsor_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "name"
    t.integer "order"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conference_id"], name: "index_sponsor_types_on_conference_id"
  end

  create_table "sponsors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "abbr"
    t.text "description"
    t.string "url"
    t.bigint "conference_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "speaker_emails"
    t.index ["conference_id"], name: "index_sponsors_on_conference_id"
  end

  create_table "sponsors_sponsor_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "sponsor_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "talk_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "conference_id"
  end

  create_table "talk_difficulties", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "conference_id"
  end

  create_table "talk_times", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.integer "time_minutes"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["conference_id"], name: "index_talk_times_on_conference_id"
  end

  create_table "talks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "abstract"
    t.string "movie_url"
    t.time "start_time"
    t.time "end_time"
    t.bigint "talk_difficulty_id"
    t.bigint "talk_category_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date"
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
    t.index ["talk_category_id"], name: "index_talks_on_talk_category_id"
    t.index ["talk_difficulty_id"], name: "index_talks_on_talk_difficulty_id"
  end

  create_table "talks_speakers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "talk_id"
    t.integer "speaker_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tracks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "video_id"
    t.integer "conference_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "video_platform"
  end

  create_table "video_registrations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.string "url"
    t.integer "status", default: 0, null: false
    t.index ["talk_id"], name: "index_video_registrations_on_talk_id"
  end

  create_table "videos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci", force: :cascade do |t|
    t.integer "talk_id"
    t.string "site"
    t.string "url"
    t.boolean "on_air"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "video_id"
    t.string "slido_id"
    t.text "video_file_data"
  end

  add_foreign_key "announcements", "conferences"
  add_foreign_key "booths", "conferences"
  add_foreign_key "booths", "sponsors"
  add_foreign_key "chat_messages", "conferences"
  add_foreign_key "chat_messages", "profiles"
  add_foreign_key "chat_messages", "speakers"
  add_foreign_key "links", "conferences"
  add_foreign_key "proposal_item_configs", "conferences"
  add_foreign_key "sponsor_attachments", "sponsors"
  add_foreign_key "sponsor_profiles", "conferences"
  add_foreign_key "sponsor_types", "conferences"
  add_foreign_key "sponsors", "conferences"
  add_foreign_key "talk_times", "conferences"
  add_foreign_key "video_registrations", "talks"
end
