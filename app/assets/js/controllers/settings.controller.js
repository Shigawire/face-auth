(function() {
  this.FaceAuthApp.controller('SettingsController', [
    '$scope', '$mdDialog', '$localStorage', '$http', 'Person', function($scope, $mdDialog, $localStorage, $http, Person) {
      var vm;
      vm = this;
      vm.settings = $localStorage.settings;
      vm.users = $localStorage.users;
      vm.editApiKey = function(ev) {
        var confirm;
        confirm = $mdDialog.prompt().title('Bitte gib deinen Microsoft Cognitive Services API Key an').placeholder('API Key').ariaLabel('API Key').initialValue(vm.settings.apiKey).targetEvent(ev).ok('Speichern').cancel('Abbrechen');
        $mdDialog.show(confirm).then((function(result) {
          vm.settings.apiKey = result;
          location.reload();
        }));
      };
      vm.editPersonGroup = function(ev) {
        var confirm;
        confirm = $mdDialog.prompt().title('Bitte gib eine personGroup an.').textContent('Die Microsoft API benutzt personGroups um Gesichter innerhalb eines Benutzerpools zuzuordnen.\n\nBitte beachte die Hinweise in den Einstellungen!').placeholder('Person group').ariaLabel('Person group').initialValue(vm.settings.personGroup).targetEvent(ev).ok('Speichern').cancel('Abbrechen');
        $mdDialog.show(confirm).then((function(result) {
          if (result === '') {
            return;
          }
          $http.put('https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/' + result, {
            name: result
          }, {
            headers: {
              'Content-Type': 'application/json',
              'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
            }
          }).then((function(response) {
            vm.settings.personGroup = result;
            location.reload();
            Person.trainFaces({
              personGroup: result
            });
          }), function(response) {
            if (response.status === 409) {
              vm.settings.personGroup = result;
            }
            console.log(response);
          });
        }));
      };
      return vm;
    }
  ]);

}).call(this);
