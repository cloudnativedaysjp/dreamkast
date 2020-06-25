json.extract! profile, :id, :sub, :email, :last_name, :first_name, :industry_id, :occupation, :company_name, :company_email, :company_address, :company_tel, :department, :position, :created_at, :updated_at
json.url profile_url(profile, format: :json)
