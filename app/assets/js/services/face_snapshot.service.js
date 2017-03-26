(function() {
  this.FaceAuthApp.service('FaceSnapshotService', [
    '$q', '$http', 'Face', '$localStorage', function($q, $http, Face, $localStorage) {
      var vm;
      vm = this;
      vm.dataURItoBlob = function(dataURI) {
        var array, binary, i, mimeString;
        binary = atob(dataURI.split(',')[1]);
        mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
        array = [];
        i = 0;
        while (i < binary.length) {
          array.push(binary.charCodeAt(i));
          i++;
        }
        return new Blob([new Uint8Array(array)], {
          type: mimeString
        });
      };
      vm.verifyFacePresence = function(snapshot) {
        var deferred;
        deferred = $q.defer();
        Face.detect(vm.dataURItoBlob(snapshot), (function(data) {
          if (data.length === 0) {
            return deferred.resolve({
              success: false,
              errorMessage: 'Kein Gesicht im Bild vorhanden.'
            });
          } else {
            return deferred.resolve({
              success: true,
              data: data
            });
          }
        }), function(error) {
          return deferred.resolve({
            success: false,
            errorMessage: error.data.error.message
          });
        });
        return deferred.promise;
      };
      vm.verifyFaceUniqueness = function(snapshot) {};
      vm.identifyUser = function(snapshot) {
        var deferred;
        deferred = $q.defer();
        vm.verifyFacePresence(snapshot).then(function(faceData) {
          var face;
          if (!faceData.success) {
            deferred.resolve(faceData);
            return;
          }
          face = faceData.data[0];
          return Face.identify({
            personGroupId: $localStorage.settings.personGroup,
            faceIds: [face.faceId],
            maxNumOfCandidatesReturned: 1,
            confidenceThreshold: 0.5
          }, (function(personData) {
            return deferred.resolve({
              success: true,
              data: {
                person: personData[0].candidates[0],
                face: face
              }
            });
          }), function(error) {
            return deferred.resolve({
              sucess: false,
              errorMessage: error.data.error.message
            });
          });
        });
        return deferred.promise;
      };
      vm.addLandmarks = function(snapshot, landmarks) {
        var canvas, context;
        canvas = document.getElementById('snapshot-storage');
        context = canvas.getContext('2d');
        context.beginPath();
        context.strokeStyle = 'yellow';
        context.lineWidth = 3;
        context.closePath();
        context.strokeRect(landmarks.faceRectangle.left, landmarks.faceRectangle.top, landmarks.faceRectangle.height, landmarks.faceRectangle.width);
        context.fill();
        context.beginPath();
        context.strokeStyle = '#00FF00';
        context.lineWidth = 2;
        context.moveTo(landmarks.faceLandmarks.mouthLeft.x, landmarks.faceLandmarks.mouthLeft.y);
        context.lineTo(landmarks.faceLandmarks.mouthRight.x, landmarks.faceLandmarks.mouthRight.y);
        context.stroke();
        context.beginPath();
        context.fillStyle = '#00FF00';
        context.fillRect(landmarks.faceLandmarks.pupilLeft.x, landmarks.faceLandmarks.pupilLeft.y, 5, 5);
        context.fillRect(landmarks.faceLandmarks.pupilRight.x, landmarks.faceLandmarks.pupilRight.y, 5, 5);
        context.fillRect(landmarks.faceLandmarks.noseTip.x, landmarks.faceLandmarks.noseTip.y, 5, 5);
        context.stroke();
        return canvas.toDataURL('image/png');
      };
      return vm;
    }
  ]);

}).call(this);
