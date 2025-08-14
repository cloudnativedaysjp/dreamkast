class FixLegacyStiTypeRecords < ActiveRecord::Migration[8.0]
  def up
    # Find session attributes
    keynote_attr = execute("SELECT id FROM session_attributes WHERE name = 'keynote'").first
    intermission_attr = execute("SELECT id FROM session_attributes WHERE name = 'intermission'").first

    unless keynote_attr
      raise "Keynote session attribute not found. Please ensure session attributes have been created."
    end
    
    unless intermission_attr
      raise "Intermission session attribute not found. Please ensure session attributes have been created."
    end

    keynote_attr_id = keynote_attr.is_a?(Array) ? keynote_attr[0] : keynote_attr['id']
    intermission_attr_id = intermission_attr.is_a?(Array) ? intermission_attr[0] : intermission_attr['id']

    # Fix KeynoteSession records
    keynote_talk_ids = execute("SELECT id FROM talks WHERE type = 'KeynoteSession'")
    keynote_talk_ids.each do |row|
      talk_id = row.is_a?(Array) ? row[0] : row['id']
      
      # Update type to Session
      execute("UPDATE talks SET type = 'Session' WHERE id = #{talk_id}")
      
      # Ensure keynote attribute exists (avoid duplicates)
      existing = execute("SELECT COUNT(*) as count FROM talk_session_attributes WHERE talk_id = #{talk_id} AND session_attribute_id = #{keynote_attr_id}")
      count = existing.first.is_a?(Array) ? existing.first[0] : existing.first['count']
      
      if count.to_i == 0
        execute("INSERT INTO talk_session_attributes (talk_id, session_attribute_id, created_at, updated_at) VALUES (#{talk_id}, #{keynote_attr_id}, NOW(), NOW())")
      end
    end

    # Fix Intermission records  
    intermission_talk_ids = execute("SELECT id FROM talks WHERE type = 'Intermission'")
    intermission_talk_ids.each do |row|
      talk_id = row.is_a?(Array) ? row[0] : row['id']
      
      # Update type to Session
      execute("UPDATE talks SET type = 'Session' WHERE id = #{talk_id}")
      
      # Ensure intermission attribute exists (avoid duplicates)
      existing = execute("SELECT COUNT(*) as count FROM talk_session_attributes WHERE talk_id = #{talk_id} AND session_attribute_id = #{intermission_attr_id}")
      count = existing.first.is_a?(Array) ? existing.first[0] : existing.first['count']
      
      if count.to_i == 0
        execute("INSERT INTO talk_session_attributes (talk_id, session_attribute_id, created_at, updated_at) VALUES (#{talk_id}, #{intermission_attr_id}, NOW(), NOW())")
      end
    end

    puts "Fixed #{keynote_talk_ids.count} KeynoteSession records"
    puts "Fixed #{intermission_talk_ids.count} Intermission records"
  end

  def down
    # This migration is not reversible as we're fixing data integrity
    # The original STI classes no longer exist
    raise ActiveRecord::IrreversibleMigration
  end
end
