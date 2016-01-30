class UploaderController < ApplicationController
  def index
  end

  require 'net/http'

  def mailru_avatar
    if params[:photo].nil?
      render json: {error: 'no_photo'}
      return
    end

    fake = AvatarUploadStub.new
    fake.photo = params[:photo]
    stamp = "#{(Time.now.to_f * 1000).round.to_s}_"

    extension = File.extname(fake.photo_file_name).downcase
    fake.photo.instance_write(:file_name, "#{stamp}#{extension}")
    fake.photo.flush_writes
    render json: {server:'', hash:'', photo:fake.photo} 
  end

  def avatar
    if params[:photo].nil?
      render json: {error: 'no_photo'}
      return
    end

    if params[:server].nil?
      render json: {error: 'no_server'}
      return
    end

    boundary = "AzazaDeAdBeAf"

    uri = URI.parse(params[:server])
    if not uri.host.downcase.end_with?(".vk.com")
      render json: {error: 'bad_server'}
      return
    end
    file = params[:photo]

    post_body = []
    post_body << "--#{boundary}\r\n"
    post_body << "Content-Disposition: form-data; name=\"photo\"; filename=\"image.png\"\r\n"
    post_body << "Content-Type: application/octet-stream\r\n"
    post_body << "\r\n"
    post_body << file.read
    post_body << "\r\n--#{boundary}--\r\n"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'
    request = Net::HTTP::Post.new(uri.request_uri)
    request.body = post_body.join
    request["Content-Type"] = "multipart/form-data, boundary=#{boundary}"

    res = http.request(request)
    render json: res.body
  end
end
