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
class SponsorDataImporter

  def import
    import_sponsors
    import_sponsor_types
    import_sponsors_sponsor_types
    import_sponsor_attachment_logo_images
  end
  def import_sponsors
    Sponsor.seed(csv("sponsors").map { |line|
      {
        id: line['id'],
        name: line['name'],
        abbr: line['abbr'],
        conference_id: line['conference_id'],
        url: line['url']
      }
    })
  end

  def import_sponsor_types
    SponsorType.seed(csv( "sponsor_types").map { |line|
      {
        id: line['id'],
        conference_id: line['conference_id'],
        name: line['name'],
        order: line['order'],
      }
    })
  end

  def import_sponsors_sponsor_types
    csv("sponsors_sponsor_types").map do |line|
      [line['id'], line['sponsor_type'], line['abbr'], line['conference_id'], ]
    end.each do |sponsors_sponsor_type|
      id = sponsors_sponsor_type[0]
      sponsor_type = SponsorType.find_by(name: sponsors_sponsor_type[1], conference_id: sponsors_sponsor_type[3])
      sponsor = Sponsor.find_by(abbr: sponsors_sponsor_type[2], conference_id: sponsors_sponsor_type[3])
      puts "Error: unable to find #{sponsors_sponsor_type[2]}" unless sponsor
      SponsorsSponsorType.seed({id: id, sponsor_type_id: sponsor_type.id, sponsor_id: sponsor.id})
      if sponsors_sponsor_type[1] == 'Booth'
        Booth.seed(:conference_id, :sponsor_id) do |s|
          s.conference_id = sponsors_sponsor_type[3]
          s.sponsor_id = sponsor.id
        end
      end
    end

    Conference.all.each do |conf|
      if conf.sponsors.any? { |sponsor| sponsor.sponsor_types.empty? }
        no_sponsor_types = conf.sponsors.select { |sponsor| sponsor.sponsor_types.empty? }
        raise "Error: Some sponsor hae no sponsor_type in #{conf.abbr}: #{no_sponsor_types.map(&:abbr).join(', ')}"
      end
    end
  end

  def import_sponsor_attachment_logo_images
    csv( "sponsor_attachment_logo_images").map do |line|
      [line['id'], line['abbr'], line['url'], line['conference_id'], ]
    end.each do |logo|
      sponsor = Sponsor.find_by(abbr: logo[1], conference_id: logo[3])
      puts "Error: unable to find #{logo[1]}" unless sponsor
      SponsorAttachment.seed(
        { id: logo[0],
          sponsor_id: sponsor.id,
          type: 'SponsorAttachmentLogoImage',
          url: logo[2]
        }
      )
    end

    Conference.all.each do |conf|
      unless conf.sponsors.all? { |sponsor| sponsor.sponsor_attachment_logo_image.present? }
        no_sponsor_types = conf.sponsors.select { |sponsor| !sponsor.sponsor_attachment_logo_image }
        raise "Error: Some sponsor hae no sponsor_logo_image in #{conf.abbr}: #{no_sponsor_types.map(&:abbr).join(', ')}"
      end
    end
  end
  def csv(name)
    CSV.read(File.join(Rails.root, "db/csv/sponsors/#{name}.csv"), headers: true)
  end
end
