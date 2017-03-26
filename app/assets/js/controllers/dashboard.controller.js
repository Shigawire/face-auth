(function() {
  this.FaceAuthApp.controller('DashboardController', [
    '$scope', '$mdDialog', 'Person', '$localStorage', function($scope, $mdDialog, Person, $localStorage) {
      var vm;
      vm = this;
      vm.isLocked = true;
      vm.settings = $localStorage.settings;
      vm.showSignUpDialog = function(ev) {
        $mdDialog.show({
          controller: 'SignUpController',
          controllerAs: 'vm',
          templateUrl: 'templates/views/sign_up.html',
          parent: angular.element(document.body),
          targetEvent: ev,
          clickOutsideToClose: false
        });
      };
      vm.showSignInDialog = function(ev) {
        $mdDialog.show({
          controller: 'SignInController',
          controllerAs: 'vm',
          templateUrl: 'templates/views/sign_in.html',
          parent: angular.element(document.body),
          targetEvent: ev,
          clickOutsideToClose: false
        }).then(function(result) {
          return vm.currentUser = result;
        });
      };
      return vm;
    }
  ]);

}).call(this);
