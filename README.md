DropboxFolderSync
=================

Sync Dropbox Folder with Local directory via Dropbox API.

## Installation

Add this line to your application's Gemfile:

    gem 'dropbox-folder-sync'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dropbox-folder-sync
    
## Usage

### Register your own app

> https://www.dropbox.com/developers/apps

and set env vars.

    export DROPBOX_FOLDER_SYNC_APP_KEY='app-key-form-dropbox'
    export DROPBOX_FOLDER_SYNC_APP_SECRET='secret key here'


### Login and link with Dropbox

    Usage:
      $ dropbox-folder login [NAME]
    
*NAME* is identifer of Dropbox account. Please name your own easy to understand.　*default* is used as name if not specified.

### Synchronize

    Usage:
      $ dropbox-folder sync [NAME:]/PATH/TO/REMOTE /PATH/TO/LOCAL
      
    Options:
      -i, [--interval=sec] # sync interval (seconds) , default = 1
      
    
### Logout and unlink from Dropbox

    Usage:
      $ dropbox-folder logout [NAME]


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
