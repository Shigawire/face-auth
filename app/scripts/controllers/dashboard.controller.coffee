@FaceAuthApp.controller 'DashboardController', [
  '$scope'
  '$mdDialog'
  'Person'
  '$localStorage'
  ($scope, $mdDialog, Person, $localStorage) ->
    vm = @
    vm.isLocked = true
    vm.settings = $localStorage.settings 
    
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
        clickOutsideToClose: false).then (result) ->
          vm.currentUser = result
      return
    
    return vm
]