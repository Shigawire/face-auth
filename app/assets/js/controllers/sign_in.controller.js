(function() {
  this.FaceAuthApp.controller('SignInController', [
    '$scope', 'WebcamService', 'FaceSnapshotService', '$localStorage', '$mdDialog', '$interval', function($scope, WebcamService, FaceSnapshotService, $localStorage, $mdDialog, $interval) {
      var vm;
      vm = this;
      vm;
      vm.webcam = WebcamService.webcam;
      $scope.$watch('vm.webcam.isTurnOn', function(newVal, oldVal) {
        return console.log(newVal);
      });
      vm.closeSignInDialog = function() {
        $mdDialog.hide(vm.identifiedUser);
        return vm.webcam.turnOff();
      };
      vm.cancelSignInDialog = function() {
        $mdDialog.hide(void 0);
        return vm.webcam.turnOff();
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
