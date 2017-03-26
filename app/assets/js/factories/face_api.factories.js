(function() {
  this.FaceAuthApp.factory('Face', [
    '$resource', '$localStorage', function($resource, $localStorage) {
      return $resource('https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=true', {}, {
        detect: {
          method: 'POST',
          isArray: true,
          transformRequest: angular.identity,
          headers: {
            'Content-Type': 'application/octet-stream; charset=binary',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        },
        identify: {
          method: 'POST',
          isArray: true,
          url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/identify',
          headers: {
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        }
      });
    }
  ]);

  this.FaceAuthApp.factory('Person', [
    '$resource', '$localStorage', function($resource, $localStorage) {
      return $resource('https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/persons', {
        personGroup: '@personGroup',
        personId: '@personId'
      }, {
        save: {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        },
        get: {
          headers: {
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        },
        addFace: {
          method: 'POST',
          url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/persons/:personId/persistedFaces',
          transformRequest: angular.identity,
          headers: {
            'Content-Type': 'application/octet-stream; charset=binary',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        },
        trainFaces: {
          method: 'POST',
          url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/train',
          headers: {
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        },
        trainingStatus: {
          method: 'GET',
          url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/training',
          headers: {
            'Content-Type': 'application/json',
            'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
          }
        }
      });
    }
  ]);

}).call(this);
