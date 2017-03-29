(function() {
  this.FaceAuthApp.controller('SignUpController', [
    '$scope', '$mdDialog', 'WebcamService', 'FaceSnapshotService', '$localStorage', 'Person', '$q', '$interval', function($scope, $mdDialog, WebcamService, FaceSnapshotService, $localStorage, Person, $q, $interval) {
      var vm;
      vm = this;
      vm.user = '';
      vm.snapshotList = [];
      vm.selectedIndex = 0;
      vm.webcam = WebcamService.webcam;
      vm.addSnapshot = function() {
        var snapshot;
        snapshot = {
          data: vm.webcam.makeSnapshot(),
          accepted: void 0,
          inProgress: true
        };
        vm.snapshotList.push(snapshot);
        vm.snapshotVerifying = true;
        return FaceSnapshotService.verifyFacePresence(snapshot.data).then(function(faceData) {
          if (!faceData.success) {
            snapshot.errorMessage = faceData.errorMessage;
            return;
          }
          return FaceSnapshotService.identifyUser(snapshot.data).then(function(userData) {
            if (userData.success && userData.data.person) {
              snapshot.accepted = false;
              snapshot.errorMessage = 'Dieses Gesicht wurde bereits einem Nutzer zugeordnet.';
              return;
            }
            snapshot.accepted = true;
            return snapshot.withLandmarks = FaceSnapshotService.addLandmarks(snapshot.data, faceData.data[0]);
          });
        })["finally"](function() {
          snapshot.inProgress = false;
          return vm.snapshotVerifying = false;
        });
      };
      vm.createUser = function() {
        var user;
        vm.stepsFinished = [false, false, false, false];
        vm.selectedIndex = 2;
        user = new Person({
          personGroup: $localStorage.settings.personGroup,
          name: vm.name
        });
        return user.$save(function(data) {
          var i, len, ref, snapshot, uploadPromises;
          vm.stepsFinished[0] = true;
          user.personId = data.personId;
          uploadPromises = [];
          ref = vm.snapshotList;
          for (i = 0, len = ref.length; i < len; i++) {
            snapshot = ref[i];
            uploadPromises.push(Person.addFace({
              personGroup: $localStorage.settings.personGroup,
              personId: user.personId
            }, FaceSnapshotService.dataURItoBlob(snapshot.data)));
          }
          return $q.all(uploadPromises).then(function() {
            vm.stepsFinished[1] = true;
            return Person.trainFaces({
              personGroup: $localStorage.settings.personGroup
            }, function() {
              var checkTrainingInterval;
              vm.stepsFinished[2] = true;
              return checkTrainingInterval = $interval((function() {
                return Person.trainingStatus({
                  personGroup: $localStorage.settings.personGroup
                }, function(data) {
                  if (data.status === 'succeeded') {
                    $interval.cancel(checkTrainingInterval);
                    vm.stepsFinished[3] = true;
                    return $localStorage.users.push({
                      personId: user.personId,
                      personGroup: $localStorage.settings.personGroup,
                      name: vm.name,
                      secret: vm.secret
                    });
                  } else if (data.status === 'failed') {
                    $interval.cancel(checkTrainingInterval);
                    return vm.stepsFinished[3] = false;
                  }
                });
              }), 2000);
            });
          });
        });
      };
      vm.removeSnapshot = function(snapshot) {
        return vm.snapshotList = vm.snapshotList.filter(function(item) {
          return item.data !== snapshot.data;
        });
      };
      vm.acceptedSnapshots = function() {
        return (vm.snapshotList.filter(function(snapshot) {
          return snapshot.accepted === true;
        })).length;
      };
      vm.closeSignUpDialog = function() {
        $mdDialog.hide();
      };
      return vm;
    }
  ]);

}).call(this);
