@FaceAuthApp.controller 'DashboardController', [
  '$scope'
  '$mdDialog'
  'Person'
  ($scope, $mdDialog, Person) ->
    vm = @
    vm.isLocked = true

    vm.showSignUpDialog = (ev) ->
      $mdDialog.show(
        controller: 'SignUpController'
        controllerAs: 'vm'
        templateUrl: 'templates/views/sign_up.html'
        parent: angular.element(document.body)
        targetEvent: ev
        clickOutsideToClose: false)
      return

    vm.showSignInDialog = (ev) ->
      $mdDialog.show(
        controller: 'SignInController'
        controllerAs: 'vm'
        templateUrl: 'templates/views/sign_in.html'
        parent: angular.element(document.body)
        targetEvent: ev
        clickOutsideToClose: false)
      return
    
    return vm
]