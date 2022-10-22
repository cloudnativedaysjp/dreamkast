class DummyDataImporter
  def initialize(abbr)
    @abbr = abbr
  end

  def import_dummy_talks
    Talk.seed(csv('talks').map(&:to_hash))
  end

  def import_dummy_speakers
    Speaker.seed(csv('speakers').map(&:to_hash))
  end

  def import_dummy_talks_speakers
    csv('talks_speakers').each do |row|
      TalksSpeaker.seed(:talk_id, :speaker_id) do |t|
        h = row.to_hash
        t.talk_id = h["talk_id"]
        t.speaker_id = h["speaker_id"]
      end
    end
  end

  def import_dummy_proposals
    Proposal.seed(csv('proposals').map{|line|
      {
        id: line["id"],
        talk_id: line["talk_id"],
        conference_id: line["conference_id"],
        status: ['registered', 'accepted', 'rejected'][line["status"].to_i]
      }
    })
  end

  def import_dummy_proposal_items
    ProposalItem.seed(csv('proposal_items').map{|line|
      {
        id: line["id"],
        conference_id: line["conference_id"],
        talk_id: line["talk_id"],
        label: line["label"],
        params: line["params"]
      }
    })
  end

  private

  def csv(model)
    CSV.read(File.join(Rails.root, "db/csv/#{@abbr}/#{model}.csv"), headers: true)
  end
end

def import_dummy_data(abbr, models)
  models.each do |model|
    puts "importing #{model}"
    DummyDataImporter.new(abbr).send("import_dummy_#{model}")
  end
end
