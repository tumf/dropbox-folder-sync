#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $:.unshift(File.expand_path(File.join(File.dirname(__FILE__),'..')))
require 'thor'
require 'dropbox-folder-sync/app'
class DropboxFolderSync::CLI < Thor

  desc 'login [NAME]', "Login and Link with Dropbox account."
  def login name="default"
    DropboxFolderSync::App.login(name)
  end

  desc 'logout [NAME]', "Logout and unink from Dropbox account."
  def logout name="default"
    DropboxFolderSync::App.logout(name)
  end

  desc 'sync [NAME:]/PATH/TO/DROPBOX /PATH/TO/REMOTE', "Sync local directory with Dropbox"
  method_option :interval, :type => :numeric, :aliases => "-i", :desc => "Sync interval (sec)", :default => 1
  method_option :cursor, :type => :string, :aliases => "-c", :desc => "Cursor to start sync", :default => nil
  def sync remote,local
    DropboxFolderSync::App.sync(remote,local,options)
  end

  desc 'json [NAME]', "Output scedentials in json fomat."
  def json name = "default"
    DropboxFolderSync::App.json name
  end

end

if $0 == __FILE__

end

