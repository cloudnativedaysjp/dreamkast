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

ActiveRecord::Schema[7.0].define(version: 2025_03_01_055049) do
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

  create_table "chat_messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "profile_id"
    t.bigint "speaker_id"
    t.text "body"
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

  create_table "check_in_conferences", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "profile_id", null: false
    t.datetime "check_in_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "scanner_profile_id"
    t.index ["conference_id"], name: "index_check_in_conferences_on_conference_id"
    t.index ["profile_id"], name: "index_check_in_conferences_on_profile_id"
  end

  create_table "check_in_talks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.bigint "profile_id", null: false
    t.datetime "check_in_timestamp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "scanner_profile_id"
    t.index ["profile_id"], name: "index_check_in_talks_on_profile_id"
    t.index ["talk_id"], name: "index_check_in_talks_on_talk_id"
  end

  create_table "check_ins", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.text "theme"
    t.text "about"
    t.text "privacy_policy"
    t.text "coc"
    t.string "copyright"
    t.text "privacy_policy_for_speaker"
    t.integer "speaker_entry", default: 0
    t.integer "attendee_entry", default: 0
    t.integer "show_timetable", default: 0
    t.boolean "cfp_result_visible", default: false
    t.boolean "show_sponsors", default: false
    t.string "brief"
    t.string "committee_name", default: "CloudNative Days Committee", null: false
    t.string "conference_status", default: "registered"
    t.boolean "rehearsal_mode", default: false, null: false
    t.integer "capacity"
    t.text "contact_url"
    t.text "sponsor_guideline_url"
    t.index ["abbr", "conference_status"], name: "index_conferences_on_abbr_and_conference_status"
    t.index ["abbr"], name: "index_conferences_on_abbr"
  end

  create_table "form_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "conference_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "media_live_channels", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "media_live_input_id", null: false
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_live_input_id"], name: "index_media_live_channels_on_media_live_input_id"
    t.index ["streaming_id"], name: "index_media_live_channels_on_streaming_id"
  end

  create_table "media_live_input_security_groups", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "input_security_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["streaming_id"], name: "index_media_live_input_security_groups_on_streaming_id"
  end

  create_table "media_live_inputs", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "media_live_input_security_group_id", null: false
    t.string "input_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_live_input_security_group_id"], name: "index_media_live_inputs_on_media_live_input_security_group_id"
    t.index ["streaming_id"], name: "index_media_live_inputs_on_streaming_id"
  end

  create_table "media_package_channels", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "channel_id", default: ""
    t.string "streaming_id"
    t.index ["channel_id"], name: "index_media_package_channels_on_channel_id"
    t.index ["streaming_id"], name: "index_media_package_channels_on_streaming_id"
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
    t.bigint "media_package_channel_id", null: false
    t.string "endpoint_id"
    t.string "streaming_id"
    t.index ["media_package_channel_id"], name: "index_media_package_origin_endpoints_on_media_package_channel_id"
    t.index ["streaming_id"], name: "index_media_package_origin_endpoints_on_streaming_id"
  end

  create_table "media_package_parameters", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.bigint "media_package_channel_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["media_package_channel_id"], name: "index_media_package_parameters_on_media_package_channel_id"
    t.index ["streaming_id"], name: "index_media_package_parameters_on_streaming_id"
  end

  create_table "media_package_v2_channel_groups", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "name"
    t.index ["name"], name: "index_media_package_v2_channel_groups_on_name", unique: true
    t.index ["streaming_id"], name: "index_media_package_v2_channel_groups_on_streaming_id"
  end

  create_table "media_package_v2_channels", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "media_package_v2_channel_group_id"
    t.string "name"
    t.index ["media_package_v2_channel_group_id"], name: "index_channels_on_channel_group_id"
    t.index ["name"], name: "index_media_package_v2_channels_on_name", unique: true
    t.index ["streaming_id"], name: "index_media_package_v2_channels_on_streaming_id"
  end

  create_table "media_package_v2_origin_endpoints", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "streaming_id", null: false
    t.string "media_package_v2_channel_id"
    t.string "name"
    t.index ["media_package_v2_channel_id"], name: "index_origin_endpoints_on_channel_id"
    t.index ["name"], name: "index_media_package_v2_origin_endpoints_on_name", unique: true
    t.index ["streaming_id"], name: "index_media_package_v2_origin_endpoints_on_streaming_id"
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
    t.integer "occupation_id", default: 34
    t.string "participation"
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
    t.index ["conference_id", "item_number"], name: "index_proposal_item_configs_on_conference_id_and_item_number"
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

  create_table "public_profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "profile_id", null: false
    t.string "nickname", default: ""
    t.string "twitter_id", default: ""
    t.string "github_id", default: ""
    t.text "avatar_data"
    t.boolean "is_public", default: false
    t.index ["profile_id"], name: "index_public_profiles_on_profile_id"
  end

  create_table "registered_talks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "profile_id"
    t.integer "talk_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "number_of_seats", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_rooms_on_conference_id"
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

  create_table "speaker_invitation_accepts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "speaker_invitation_id", null: false
    t.bigint "conference_id", null: false
    t.bigint "speaker_id", null: false
    t.bigint "talk_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id", "speaker_id", "talk_id"], name: "index_speaker_invitation_accepts_on_conference_speaker_talk", unique: true
    t.index ["conference_id"], name: "index_speaker_invitation_accepts_on_conference_id"
    t.index ["speaker_id"], name: "index_speaker_invitation_accepts_on_speaker_id"
    t.index ["speaker_invitation_id"], name: "index_speaker_invitation_accepts_on_speaker_invitation_id"
    t.index ["talk_id"], name: "index_speaker_invitation_accepts_on_talk_id"
  end

  create_table "speaker_invitations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.bigint "conference_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_speaker_invitations_on_conference_id"
    t.index ["talk_id"], name: "index_speaker_invitations_on_talk_id"
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
    t.bigint "sponsor_id"
    t.index ["conference_id", "email"], name: "index_speakers_on_conference_id_and_email", length: { email: 255 }
    t.index ["sponsor_id"], name: "index_speakers_on_sponsor_id"
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

  create_table "sponsor_contact_invite_accepts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "sponsor_contact_invite_id", null: false
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.bigint "sponsor_contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_sponsor_contact_invite_accepts_on_conference_id"
    t.index ["sponsor_contact_id"], name: "index_sponsor_contact_invite_accepts_on_sponsor_contact_id"
    t.index ["sponsor_contact_invite_id"], name: "index_sponsor_contact_invite_accepts_on_invitation_id"
    t.index ["sponsor_id"], name: "index_sponsor_contact_invite_accepts_on_sponsor_id"
  end

  create_table "sponsor_contact_invites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.index ["conference_id"], name: "index_sponsor_contact_invites_on_conference_id"
    t.index ["sponsor_id"], name: "index_sponsor_contact_invites_on_sponsor_id"
  end

  create_table "sponsor_contacts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "sub"
    t.string "email"
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_sponsor_contacts_on_conference_id"
    t.index ["sponsor_id"], name: "index_sponsor_contacts_on_sponsor_id"
  end

  create_table "sponsor_speaker_invite_accepts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "sponsor_speaker_invite_id", null: false
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.bigint "sponsor_contact_id", null: false
    t.bigint "talk_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id", "sponsor_id", "talk_id"], name: "idx_spk_inv_accepts_on_conf_spsr_talk", unique: true
    t.index ["conference_id"], name: "index_sponsor_speaker_invite_accepts_on_conference_id"
    t.index ["sponsor_contact_id"], name: "index_sponsor_speaker_invite_accepts_on_sponsor_contact_id"
    t.index ["sponsor_id"], name: "index_sponsor_speaker_invite_accepts_on_sponsor_id"
    t.index ["sponsor_speaker_invite_id"], name: "idx_spk_inv_accepts_on_invite"
    t.index ["talk_id"], name: "index_sponsor_speaker_invite_accepts_on_talk_id"
  end

  create_table "sponsor_speaker_invites", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id", null: false
    t.string "email", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_sponsor_speaker_invites_on_conference_id"
    t.index ["sponsor_id"], name: "index_sponsor_speaker_invites_on_sponsor_id"
    t.index ["talk_id"], name: "index_sponsor_speaker_invites_on_talk_id"
  end

  create_table "sponsor_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.string "name"
    t.integer "order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visible", default: true
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
    t.index ["conference_id"], name: "index_sponsors_on_conference_id"
  end

  create_table "sponsors_sponsor_types", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "sponsor_id"
    t.integer "sponsor_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stamp_rally_check_ins", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "stamp_rally_check_point_id", limit: 26, null: false
    t.bigint "profile_id", null: false
    t.datetime "check_in_timestamp", null: false
    t.index ["profile_id"], name: "index_stamp_rally_check_ins_on_profile_id"
    t.index ["stamp_rally_check_point_id"], name: "index_stamp_rally_check_ins_on_stamp_rally_check_point_id"
  end

  create_table "stamp_rally_check_points", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "sponsor_id"
    t.string "type", null: false
    t.string "name", null: false
    t.string "description", null: false
    t.integer "position"
    t.index ["conference_id"], name: "index_stamp_rally_check_points_on_conference_id"
    t.index ["sponsor_id"], name: "index_stamp_rally_check_points_on_sponsor_id"
  end

  create_table "stamp_rally_configures", id: { type: :string, limit: 26 }, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.decimal "finish_threshold", precision: 10, null: false
    t.index ["conference_id"], name: "index_stamp_rally_configures_on_conference_id"
  end

  create_table "stats_of_registrants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id"
    t.integer "number_of_registrants"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "offline_attendees", precision: 10
    t.decimal "online_attendees", precision: 10
    t.index ["conference_id"], name: "index_stats_of_registrants_on_conference_id"
  end

  create_table "streamings", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.bigint "track_id", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "error_cause"
    t.index ["conference_id", "track_id"], name: "index_streamings_on_conference_id_and_track_id", unique: true
    t.index ["conference_id"], name: "index_streamings_on_conference_id"
    t.index ["track_id"], name: "index_streamings_on_track_id"
  end

  create_table "talk_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
    t.index ["conference_id"], name: "index_talk_categories_on_conference_id"
  end

  create_table "talk_difficulties", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "conference_id"
    t.index ["conference_id"], name: "index_talk_difficulties_on_conference_id"
  end

  create_table "talk_times", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "conference_id", null: false
    t.integer "time_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conference_id"], name: "index_talk_times_on_conference_id"
  end

  create_table "talk_types", id: :string, charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "talks", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "type", null: false
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
    t.index ["track_id"], name: "index_talks_on_track_id"
    t.index ["type"], name: "fk_rails_9c6f538eea"
  end

  create_table "talks_speakers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "talk_id"
    t.integer "speaker_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaker_id"], name: "index_talks_speakers_on_speaker_id"
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
    t.index ["conference_id"], name: "index_tracks_on_conference_id"
  end

  create_table "video_registrations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "talk_id", null: false
    t.string "url"
    t.integer "status", default: 0, null: false
    t.json "statistics", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
  add_foreign_key "chat_messages", "conferences"
  add_foreign_key "chat_messages", "profiles"
  add_foreign_key "chat_messages", "speakers"
  add_foreign_key "check_in_conferences", "conferences"
  add_foreign_key "check_in_conferences", "profiles"
  add_foreign_key "check_in_talks", "profiles"
  add_foreign_key "check_in_talks", "talks"
  add_foreign_key "links", "conferences"
  add_foreign_key "media_live_channels", "media_live_inputs"
  add_foreign_key "media_live_channels", "streamings"
  add_foreign_key "media_live_input_security_groups", "streamings"
  add_foreign_key "media_live_inputs", "media_live_input_security_groups"
  add_foreign_key "media_live_inputs", "streamings"
  add_foreign_key "media_package_channels", "streamings"
  add_foreign_key "media_package_harvest_jobs", "conferences"
  add_foreign_key "media_package_harvest_jobs", "media_package_channels"
  add_foreign_key "media_package_harvest_jobs", "talks"
  add_foreign_key "media_package_origin_endpoints", "media_package_channels"
  add_foreign_key "media_package_origin_endpoints", "streamings"
  add_foreign_key "media_package_parameters", "media_package_channels"
  add_foreign_key "media_package_parameters", "streamings"
  add_foreign_key "media_package_v2_channel_groups", "streamings"
  add_foreign_key "media_package_v2_channels", "streamings"
  add_foreign_key "media_package_v2_origin_endpoints", "streamings"
  add_foreign_key "proposal_item_configs", "conferences"
  add_foreign_key "proposal_items", "conferences"
  add_foreign_key "public_profiles", "profiles"
  add_foreign_key "rooms", "conferences"
  add_foreign_key "speaker_announcement_middles", "speaker_announcements"
  add_foreign_key "speaker_announcement_middles", "speakers"
  add_foreign_key "speaker_announcements", "conferences"
  add_foreign_key "speaker_invitation_accepts", "conferences"
  add_foreign_key "speaker_invitation_accepts", "speaker_invitations"
  add_foreign_key "speaker_invitation_accepts", "speakers"
  add_foreign_key "speaker_invitation_accepts", "talks"
  add_foreign_key "speaker_invitations", "conferences"
  add_foreign_key "speaker_invitations", "talks"
  add_foreign_key "speakers", "sponsors"
  add_foreign_key "sponsor_attachments", "sponsors"
  add_foreign_key "sponsor_contact_invite_accepts", "conferences"
  add_foreign_key "sponsor_contact_invite_accepts", "sponsor_contact_invites"
  add_foreign_key "sponsor_contact_invite_accepts", "sponsor_contacts"
  add_foreign_key "sponsor_contact_invite_accepts", "sponsors"
  add_foreign_key "sponsor_contact_invites", "conferences"
  add_foreign_key "sponsor_contact_invites", "sponsors"
  add_foreign_key "sponsor_contacts", "conferences"
  add_foreign_key "sponsor_speaker_invite_accepts", "conferences"
  add_foreign_key "sponsor_speaker_invite_accepts", "sponsor_contacts"
  add_foreign_key "sponsor_speaker_invite_accepts", "sponsor_speaker_invites"
  add_foreign_key "sponsor_speaker_invite_accepts", "sponsors"
  add_foreign_key "sponsor_speaker_invite_accepts", "talks"
  add_foreign_key "sponsor_speaker_invites", "conferences"
  add_foreign_key "sponsor_speaker_invites", "sponsors"
  add_foreign_key "sponsor_speaker_invites", "talks"
  add_foreign_key "sponsor_types", "conferences"
  add_foreign_key "sponsors", "conferences"
  add_foreign_key "stamp_rally_check_ins", "profiles"
  add_foreign_key "stamp_rally_check_ins", "stamp_rally_check_points"
  add_foreign_key "stamp_rally_check_points", "conferences"
  add_foreign_key "stamp_rally_configures", "conferences"
  add_foreign_key "streamings", "conferences"
  add_foreign_key "streamings", "tracks"
  add_foreign_key "talk_times", "conferences"
  add_foreign_key "talks", "talk_types", column: "type"
  add_foreign_key "video_registrations", "talks"
end
