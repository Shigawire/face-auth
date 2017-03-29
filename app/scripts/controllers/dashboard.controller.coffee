# this controller is for the user's dashboard
@FaceAuthApp.controller 'DashboardController', [
  '$scope'
  '$mdDialog'
  'Person'
  '$localStorage'
  ($scope, $mdDialog, Person, $localStorage) ->
    # map "this" to a vm-variable
    vm = @
    # inject the app settings
    vm.settings = $localStorage.settings 
    
    # allow the sign up window to be called from the HTML view
    vm.showSignUpDialog = (ev) ->
      $mdDialog.show(
        controller: 'SignUpController'
        controllerAs: 'vm'
        templateUrl: 'templates/views/sign_up.html'
        parent: angular.element(document.body)
        targetEvent: ev
        # don't allow the user to close the dialog window by clicking somewhere outside
        clickOutsideToClose: false)
      return

    # allow the sign in window to be called from the HTML view
    vm.showSignInDialog = (ev) ->
      $mdDialog.show(
        controller: 'SignInController'
        controllerAs: 'vm'
        templateUrl: 'templates/views/sign_in.html'
        parent: angular.element(document.body)
        targetEvent: ev
        clickOutsideToClose: false
      ).then (result) ->
        # .then uses the promise provided by $mdDialog and is called once the $mdDialog service "resolves" this promise,
        # i.e. is done.
        # The promise is resolved with a currentUser object
        vm.currentUser = result
      return
    
    return vm
]