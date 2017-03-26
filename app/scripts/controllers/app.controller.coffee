@FaceAuthApp.controller 'AppController', [
  '$localStorage'
  ($localStorage) ->
    # if the storage is not set up yet
    $localStorage.settings = {} unless $localStorage.settings
    $localStorage.users = [] unless $localStorage.users
]