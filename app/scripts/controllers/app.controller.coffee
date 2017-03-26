@FaceAuthApp.controller 'AppController', [
  '$scope'
  '$rootScope'
  ($scope, $rootScope) ->
    $scope.$on '$viewContentLoaded', ->
      console.log "view content is loaded"
    return
]