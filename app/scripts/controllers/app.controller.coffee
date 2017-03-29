# this is the parent controller for the Application
# Any code that has an implication for the entire application goes here
@FaceAuthApp.controller 'AppController', [
  '$localStorage'
  ($localStorage) ->
    # initialize the local storage if the storage is not set up yet
    # settings
    $localStorage.settings = {} unless $localStorage.settings
    # user list
    $localStorage.users = [] unless $localStorage.users
]