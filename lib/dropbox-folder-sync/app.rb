#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $:.unshift(File.expand_path(File.join(File.dirname(__FILE__),'..')))
require 'dropbox_sdk'
require 'launchy'
require 'keystorage'

class DropboxFolderSync::App
  APP_KEY =  ENV['DROPBOX_FOLDER_SYNC_APP_KEY']
  APP_SECRET = ENV['DROPBOX_FOLDER_SYNC_APP_SECRET']

  def initialize
    unless (APP_KEY and APP_SECRET)
      raise "set env vars 'DROPBOX_FOLDER_SYNC_APP_KEY' and 'DROPBOX_FOLDER_SYNC_APP_SECRET'"
    end
    @session = DropboxSession.new(APP_KEY, APP_SECRET)
  end

  def login name
    key = Keystorage.get("DROPBOX_APP_"+APP_KEY+"_USER_KEY",name)
    secret = Keystorage.get("DROPBOX_APP_"+APP_KEY+"_USER_SECRET",name)
    if key and secret
      @session.set_access_token(key,secret)
      @session.get_access_token rescue {}
      return true if @session.authorized?
    end

    @session.get_request_token
    authorize_url = @session.get_authorize_url
    puts "Login: [#{name}] ---> #{authorize_url}"
    Launchy.open authorize_url
    while 1
      @session.get_access_token rescue {}
      break if @session.authorized?
      sleep 1
    end
    Keystorage.set("DROPBOX_APP_"+APP_KEY+"_USER_KEY",name,@session.access_token.key.to_s)
    Keystorage.set("DROPBOX_APP_"+APP_KEY+"_USER_SECRET",name,@session.access_token.secret.to_s)
    true
  end

  def logout name
    Keystorage.delete("DROPBOX_APP_"+APP_KEY+"_USER_KEY",name)
    Keystorage.delete("DROPBOX_APP_"+APP_KEY+"_USER_SECRET",name)
    true
  end

  def log(message)
    puts message
  end

  def local_file_meta(path)
    { :path => path,
      :modified => File.mtime(path),
      :id_dir => File.directory?(path)}
  end

  def remote_path local
    @remote_root+local[@local_root.length..-1]
  end

  def local_path remote
    @local_root+remote[@remote_root.length..-1]
  end

  def remote_delta cur
    delta = @client.delta(cur)
    cur = delta["cursor"]

    if delta["reset"] == "true"
      @local_files = {}
      Dir::glob(@local_root + "/**/*").each { |path|
        @local_files[path] = local_file_meta(path)
      }
    end

    delta["entries"].each { |path,meta|
      local = local_path(path)
      if path == @remote_root or /^#{@remote_root}\// =~ path
        unless meta
          if File.exists?(local)
            log "remove #{local}"
            FileUtils.remove_entry(local)
            @local_files.reject! { |k,v| k == local }
            if File.directory?(local)
              @local_files.reject! { |k,v| /^#{local}\/.*/ =~ k }
            end
          end
          next
        end

        if meta["is_dir"] #dir
          log "----> #{local}"
          FileUtils.mkdir_p local unless File.exists?(local)
        else #file
          out = @client.get_file(path)
          open(local, 'w'){|f| f.puts out }
          log "----> #{local}"
        end
        @local_files[local] = local_file_meta(local)
      end
    } # delta
    cur
  end

  def check_local_modified
    # check local modified
    Dir::glob(@local_root + "/**/*").each { |path|
      remote = remote_path(path)
      # new file
      unless @local_files.include?(path)
        @local_files[path] = local_file_meta(path)
        log "<---- #{path}"
        if File.file?(path)
          @client.put_file(remote, open(path))
        elsif File.directory?(path)
          @client.file_create_folder(remote)
        end
        next
      end

      # modified
      if File.file?(path) and File.mtime(path) > @local_files[path][:modified]
        @local_files[path] = local_file_meta(path)
        @client.put_file(remote, open(path))
      end
    }
  end

  def check_local_removed
    # check removed
    @local_files.each { |path,v|
      unless File.exists?(path)
        log "remote delete #{path}"
        @local_files.reject! { |k,v| k == path }
        @client.file_delete(remote_path(path))
      end
    }
  end

  def sync(remote,local,options)
    name,@remote_root = parse_remote(remote)
    @local_root = path_normalize(File.expand_path(local))
    login(name) unless @session.authorized?
    @client = DropboxClient.new(@session, :dropbox)
    log "#{@remote_root} <---> #{@local_root}"
    @local_files = {}
    cur = nil
    while true
      cur = remote_delta(cur)
      check_local_modified
      check_local_removed
      sleep options[:interval]
    end
  end

  def path_normalize path
    path = "/" + path if path[0,1] != "/"
    path = path[0,path.length - 1] if path[-1,1] == "/"
    path
  end

  def parse_remote remote
    name = "default"
    if /^([^\/]+):(.*)/ =~ remote
      name = $1
      remote = $2
    end
    [name,path_normalize(remote)]
  end

  class << self
    def sync remote,local,options
      new.sync(remote,local,options)
    end
    def login name
      new.login(name)
    end
    def logout name
      new.logout(name)
    end
  end

end

if $0 == __FILE__

end

