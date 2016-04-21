require 'sinatra'
require 'json'
require_relative 'config/environments'
require_relative 'models/init'

class FileSharingAPI < Sinatra::Base

  before do
    host_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    @request_url = URI.join(host_url, request.path.to_s)
  end

  configure :production, :development do
    enable :logging
  end

  get '/?' do
    "File Sharer Webservice is up and running at api/v1"
  end

  get '/api/v1/?' do
    # TODO print all api urls as a json
    "Version 1.0 our our api"
  end

  get '/api/v1/users/?' do
    # TODO return all users' files
    content_type 'application/json'

    JSON.pretty_generate(data: User.all)
  end

  get '/api/v1/users/:username' do
    content_type 'application/json'

    username = params[:username]
    user = User.where(username: username)
               .first

    files = user ? User[user.id].simple_files : []

    if user
      JSON.pretty_generate(data: user, relationships: files)
    else
      halt 404, "USER NOT FOUND: #{username}"
    end
  end

  post '/api/v1/users/?' do
    begin
      new_data = JSON.parse(request.body.read)
      saved_user = User.create(new_data)
    rescue => e
      logger.info "FAILED to create new user: #{e.inspect}"
      halt 400
    end

    new_location = URI.join(@request_url.to_s + '/', saved_user.username.to_s).to_s

    status 201
    headers('Location' => new_location)
  end

  get '/api/v1/users/:username/files/?' do
    # returns a json of all files for a user
    content_type 'application/json'

    username = params[:username]
    user = User.where(username: username)
               .first

    JSON.pretty_generate(data: user.simple_files)
  end

  get '/api/v1/users/:username/files/:id.json/?' do
    # Returns a json of all information about a file
    content_type 'application/json'

    username = params[:username]
    user_id = User.where(username: username)
                  .first
                  .id

    begin
      doc_url = URI.join(@request_url.to_s + '/', 'document')
      simple_file = SimpleFile
                      .where(user_id: user_id, id: params[:id])
                      .first
      halt(404, 'File not found') unless simple_file
      JSON.pretty_generate(data: {
                             file: simple_file,
                             links: { document: doc_url }
                           })
    rescue => e
      status 400
      logger.info "FAILED to process GET file request: #{e.inspect}"
      e.inspect
    end
  end

  get '/api/v1/users/:username/files/:id/document' do
    # Returns a text/plain document with a configuration document
    content_type 'text/plain'

    username = params[:username]
    user_id = User.where(username: username)
                  .first
                  .id
    begin
      # Return raw data
      SimpleFile
        .where(user_id: user_id, id: params[:id])
        .first
        .document
    rescue => e
      status 404
      e.inspect
    end
  end

  post '/api/v1/users/:username/files/?' do
    # Creates a new file for a user
    # TODO Should upload here
    username = params[:username]
    begin
      new_data = JSON.parse(request.body.read)
      user = User.where(username: username)
                 .first
      saved_file = user.add_simple_file(:filename=>new_data['filename'], :description=>new_data['description'], :file_extension=>new_data['file_extension'], :remark=>new_data['remark'])
      saved_file.document = new_data['document']
      saved_file.save
    rescue => e
      logger.info "FAILED to create new file: #{e.inspect}"
      halt 400
    end

    status 201
    new_location = URI.join(@request_url.to_s + '/', saved_file.id.to_s).to_s
    headers('Location' => new_location)
  end

end
