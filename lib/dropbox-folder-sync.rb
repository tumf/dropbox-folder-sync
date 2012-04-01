require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'bundler/setup'
module DropboxFolderSync
  autoload :VERSION, "dropbox-folder-sync/version"
  autoload :CLI, "dropbox-folder-sync/cli"
end
