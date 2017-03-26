(function() {
  this.FaceAuthApp.controller('SignInController', [
    '$scope', 'WebcamService', 'FaceSnapshotService', '$localStorage', '$mdDialog', function($scope, WebcamService, FaceSnapshotService, $localStorage, $mdDialog) {
      var vm;
      vm = this;
      vm.webcam = WebcamService.webcam;
      vm.closeSignInDialog = function() {
        return $mdDialog.hide(vm.identifiedUser);
      };
      vm.cancelSignInDialog = function() {
        return $mdDialog.hide(void 0);
      };
      vm.doAuthSnapshot = function() {
        vm.snapshot = {
          data: vm.webcam.makeSnapshot(),
          identified: false,
          inProgress: true
        };
        return FaceSnapshotService.identifyUser(vm.snapshot.data).then(function(userData) {
          if (!userData.success) {
            vm.failureReason = userData.errorMessage;
            vm.snapshot.identified = false;
            return;
          }
          vm.identifiedUser = ($localStorage.users.filter(function(user) {
            return user.personId === userData.data.person.personId;
          }))[0];
          vm.snapshot.identified = true;
          return vm.snapshot.withLandmarks = FaceSnapshotService.addLandmarks(vm.snapshot.data, userData.data.face);
        })["finally"](function() {
          return vm.snapshot.inProgress = false;
        });
      };
      return vm;
    }
  ]);

}).call(this);
