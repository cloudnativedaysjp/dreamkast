require 'rails_helper'

RSpec.describe('動画アップロードの認可と容量制限', type: :request) do
  let!(:conference) { create(:cndt2020, :registered) }
  let!(:user) { create(:user) }
  let!(:speaker) { create(:speaker, conference:, user:, name: '登壇者', profile: '紹介', company: '会社', job_title: '開発者') }
  let(:client) { instance_double(Uppy::S3Multipart::Client) }
  let(:key) { "video_file/#{user.id}/example" }
  let(:upload) { MultipartUpload.create!(user:, key:, upload_id: 'upload-1', byte_size: 6.megabytes, part_size: 5.megabytes, expires_at: 1.day.from_now) }

  before do
    UploadsController::RATE_LIMIT_STORE.clear
    auth = { info: { email: user.email }, extra: { raw_info: { sub: user.sub } } }
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).and_call_original)
    allow_any_instance_of(ActionDispatch::Request::Session).to(receive(:[]).with(:userinfo).and_return(auth))
    allow(Shrine).to(receive(:storages).and_return(video_file: double))
    allow_any_instance_of(MultipartUploadsController).to(receive(:client).and_return(client))
  end

  it 'アップロードの開始情報を利用者に紐付ける' do
    allow(client).to(receive(:create_multipart_upload).and_return(upload_id: 'new-upload'))
    post '/s3/multipart', params: { size: 6.megabytes, partSize: 5.megabytes, type: 'video/mp4' }, as: :json
    expect(response).to(have_http_status(:ok))
    record = MultipartUpload.find_by!(upload_id: 'new-upload')
    expect(record.user).to(eq(user))
    expect(record.key).to(start_with("video_file/#{user.id}/"))
    expect(record.byte_size).to(eq(6.megabytes))
  end

  it '別ユーザーのupload IDとkeyを知っていても署名できない' do
    upload.update!(user: create(:user))
    expect(client).not_to(receive(:prepare_upload_part))
    get '/s3/multipart/upload-1/1', params: { key: }
    expect(response).to(have_http_status(:not_found))
  end

  it '期限切れアップロードを再利用できない' do
    upload.update!(expires_at: 1.minute.ago)
    get '/s3/multipart/upload-1/1', params: { key: }
    expect(response).to(have_http_status(:not_found))
  end

  it '署名するパートに正確なサイズ上限と短い期限を設定する' do
    upload
    expect(client).to(receive(:prepare_upload_part).with(upload_id: 'upload-1', key:, part_number: 2, content_length: 1.megabyte, whitelist_headers: ['content-length'], expires_in: 900).and_return(url: 'https://example.com/part'))
    get '/s3/multipart/upload-1/2', params: { key: }
    expect(response).to(have_http_status(:ok))
  end

  it 'SDKが生成する署名にもContent-Lengthを含める' do
    upload
    storage = Aws::S3::Resource.new(region: 'ap-northeast-1', credentials: Aws::Credentials.new('test', 'test'), stub_responses: true)
    signer = Uppy::S3Multipart::Client.new(bucket: storage.bucket('test-bucket'))
    allow_any_instance_of(MultipartUploadsController).to(receive(:client).and_return(signer))
    get '/s3/multipart/upload-1/2', params: { key: }
    expect(response).to(have_http_status(:ok))
    query = URI.decode_www_form(URI(JSON.parse(response.body).fetch('url')).query).to_h
    expect(query.fetch('X-Amz-SignedHeaders').split(';')).to(include('content-length'))
    expect(query.fetch('X-Amz-Expires')).to(eq('900'))
  end

  it '登壇者でも管理者でもない利用者は開始できない' do
    speaker.destroy!
    expect(client).not_to(receive(:create_multipart_upload))
    post '/s3/multipart', params: { size: 6.megabytes, type: 'video/mp4' }, as: :json
    expect(response).to(have_http_status(:forbidden))
  end

  it '同時に保持できるアップロードの数を制限する' do
    5.times do |index|
      MultipartUpload.create!(user:, key: "video_file/#{index}", upload_id: "active-#{index}", byte_size: 1.megabyte, part_size: 5.megabytes, expires_at: 1.day.from_now)
    end
    expect(client).not_to(receive(:create_multipart_upload))
    post '/s3/multipart', params: { size: 6.megabytes, type: 'video/mp4' }, as: :json
    expect(response).to(have_http_status(:too_many_requests))
  end

  it '存在しないパート番号を拒否する' do
    upload
    get '/s3/multipart/upload-1/3', params: { key: }
    expect(response).to(have_http_status(:bad_request))
  end

  it '上限を超えるファイルの開始を拒否する' do
    expect(client).not_to(receive(:create_multipart_upload))
    post '/s3/multipart', params: { size: 6.gigabytes, type: 'video/mp4' }, as: :json
    expect(response).to(have_http_status(:payload_too_large))
  end

  it '完了時にS3の実サイズが一致しなければ中止する' do
    upload
    allow(client).to(receive(:list_parts).and_return([{ part_number: 1, size: 7.megabytes, etag: 'bad' }]))
    expect(client).to(receive(:abort_multipart_upload).with(upload_id: 'upload-1', key:))
    expect(client).not_to(receive(:complete_multipart_upload))
    post '/s3/multipart/upload-1/complete', params: { key: }, as: :json
    expect(response).to(have_http_status(:unprocessable_entity))
    expect(MultipartUpload.exists?(upload.id)).to(be(false))
  end

  it '正しいパートが揃った場合のみ完了する' do
    upload
    parts = [{ part_number: 1, size: 5.megabytes, etag: 'one' }, { part_number: 2, size: 1.megabyte, etag: 'two' }]
    allow(client).to(receive(:list_parts).and_return(parts))
    expect(client).to(receive(:complete_multipart_upload).with(upload_id: 'upload-1', key:, parts: parts.map { |part| part.slice(:part_number, :etag) }).and_return(location: 'https://example.com/video'))
    post '/s3/multipart/upload-1/complete', params: { key: }, as: :json
    expect(response).to(have_http_status(:ok))
    expect(MultipartUpload.exists?(upload.id)).to(be(false))
  end
end
