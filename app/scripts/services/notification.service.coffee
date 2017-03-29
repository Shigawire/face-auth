@FaceAuthApp.service 'NotificationService', [
  '$mdToast'
  ($mdToast) -> 

  vm = @
  vm.error = (message) ->
    $mdToast.show $mdToast.simple().textContent(rejection.message).position(pinTo).hideDelay(3000)
]