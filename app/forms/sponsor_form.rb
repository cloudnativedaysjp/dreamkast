class SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attr_accessor :description,
                :speaker_emails,
                :booth_published,
                :sponsor_attachment_key_images,
                :attachment_text,
                :attachment_vimeo,
                :attachment_zoom,
                :attachment_miro,
                :sponsor_attachment_pdfs

  delegate :persisted?, to: :sponsor

  concerning :SponsorAttachmentKeyImagesBuilder do
    attr_accessor :sponsor_attachment_key_images

    def sponsor_attachment_key_images
      @sponsor_attachment_key_images ||= []
    end

    def sponsor_attachment_key_images_attributes=(attributes)
      @sponsor_attachment_key_images ||= []
      attributes.each do |i, params|
        if params.key?(:id)
          if params[:_destroy] == "1"
            image = @sponsor.sponsor_attachment_key_images.find(params[:id])
            image.destroy
          else
            params.delete(:_destroy)
            image = @sponsor.sponsor_attachment_key_images.find(params[:id])
            image.update(params)
          end
        else
          params.delete(:_destroy)
          image = SponsorAttachmentKeyImage.new(params.merge(sponsor_id: sponsor.id))
          image.save!
          @sponsor_attachment_key_images.push(image)
        end
      end
    rescue => e
      puts e
      false
    end
  end

  concerning :SponsorAttachmentPDFsBuilder do
    attr_accessor :sponsor_attachment_pdfs

    def sponsor_attachment_pdfs
      @sponsor_attachment_pdfs ||= [SponsorAttachmentPdf.new, SponsorAttachmentPdf.new, SponsorAttachmentPdf.new]
    end

    def sponsor_attachment_pdfs_attributes=(attributes)
      @sponsor_attachment_pdfs ||= []
      attributes.each do |_i, params|
        if params.key?(:id)
          if params[:_destroy] == "1"
            image = @sponsor.sponsor_attachment_pdfs.find(params[:id])
            image.destroy
          else
            params.delete(:_destroy)
            image = @sponsor.sponsor_attachment_pdfs.find(params[:id])
            image.update(params)
          end
        else
          params.delete(:_destroy)
          pdf = SponsorAttachmentPdf.new(params.merge(sponsor_id: sponsor.id))
          pdf.save!
          @sponsor_attachment_pdfs.push(pdf)
        end
      end
    rescue => e
      puts e
      false
    end
  end

  def initialize(attributes = nil, sponsor: Sponsor.new)
    @sponsor = sponsor
    attributes ||= default_attributes
    super(attributes)
  end

  def sponsor
    @sponsor
  end
  def save
    return if invalid?

    ActiveRecord::Base.transaction do
      sponsor.update!(description: description, speaker_emails: speaker_emails)

      if sponsor.booth.present?
        sponsor.booth.update!(published: booth_published)
      end

      if sponsor.sponsor_attachment_text.present?
        sponsor.sponsor_attachment_text.update!(text: attachment_text)
      else
        text = SponsorAttachmentText.new(text: attachment_text, sponsor_id: sponsor.id)
        text.save!
      end

      if sponsor.sponsor_attachment_vimeo.present?
        sponsor.sponsor_attachment_vimeo.update!(url: attachment_vimeo)
      else
        vimeo = SponsorAttachmentVimeo.new(url: attachment_vimeo, sponsor_id: sponsor.id)
        vimeo.save!
      end

      if sponsor.sponsor_attachment_zoom.present?
        sponsor.sponsor_attachment_zoom.update!(url: attachment_zoom)
      else
        url = SponsorAttachmentZoom.new(url: attachment_zoom, sponsor_id: sponsor.id)
        url.save!
      end

      if sponsor.sponsor_attachment_miro.present?
        sponsor.sponsor_attachment_miro.update!(url: attachment_miro)
      else
        url = SponsorAttachmentMiro.new(url: attachment_miro, sponsor_id: sponsor.id)
        url.save!
      end
    end
  rescue => e
    puts e
    false
  end

  def to_model
    sponsor
  end

  def load
    @sponsor_attachment_key_images = @sponsor.sponsor_attachment_key_images
    @sponsor_attachment_pdfs = @sponsor.sponsor_attachment_pdfs
  end

  private

  attr_reader :sponsor

  def default_attributes
    {
      description: sponsor.description,
      speaker_emails: sponsor.speaker_emails,
      booth_published: sponsor.booth.present? && sponsor.booth.published.present? ? sponsor.booth.published : nil,
      attachment_text: sponsor.sponsor_attachment_text.present? ? sponsor.sponsor_attachment_text.text : '',
      attachment_vimeo: sponsor.sponsor_attachment_vimeo.present? ? sponsor.sponsor_attachment_vimeo.url : '',
      attachment_zoom: sponsor.sponsor_attachment_zoom.present? ? sponsor.sponsor_attachment_zoom.url : '',
      attachment_miro: sponsor.sponsor_attachment_miro.present? ? sponsor.sponsor_attachment_miro.url : '',
      sponsor_attachment_key_images: sponsor_attachment_key_images,
      sponsor_attachment_pdfs: sponsor_attachment_pdfs
    }
  end
end