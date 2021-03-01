json.id @booth.id
json.sponsorId @booth.sponsor.id
json.sponsorName @booth.sponsor.name
json.published @booth.published
json.description @booth.sponsor.description
json.url @booth.sponsor.url
json.abbr @booth.sponsor.abbr
json.text @booth.sponsor.sponsor_attachment_text.text
json.logoUrl image_url(@booth.sponsor.sponsor_attachment_logo_image.url)
json.vimeoUrl @booth.sponsor.sponsor_attachment_vimeo.url
json.miroUrl @booth.sponsor.sponsor_attachment_miro.url
json.pdfUrls @booth.sponsor.sponsor_attachment_pdfs.map{|pdf| {url: pdf.file_url, title: pdf.title}}
json.keyImageUrls @booth.sponsor.sponsor_attachment_key_images.map{|image| image.file_url}
