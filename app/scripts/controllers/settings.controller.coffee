@FaceAuthApp.controller 'SettingsController', [
  '$scope'
  '$mdDialog'
  '$localStorage'
  '$http'
  ($scope, $mdDialog, $localStorage, $http) ->
    vm = @

    if !$localStorage.settings
      $localStorage.settings = {}

    vm.settings = $localStorage.settings

    vm.editApiKey = (ev) ->
      confirm = $mdDialog.prompt().title('Bitte gib deinen Microsoft Cognitive Services API Key an').placeholder('API Key').ariaLabel('API Key').initialValue(vm.settings.apiKey).targetEvent(ev).ok('Speichern').cancel('Abbrechen')
      $mdDialog.show(confirm).then ((result) ->
        vm.settings.apiKey = result
        return
      )
      return

    vm.editPersonGroup = (ev) ->
      confirm = $mdDialog.prompt().title('Bitte gib eine personGroup an.').textContent('Die Microsoft API benutzt personGroups um Gesichter innerhalb eines Benutzerpools zuzuordnen.\n\nBitte beachte die Hinweise in den Einstellungen!').placeholder('Person group').ariaLabel('Person group').initialValue(vm.settings.personGroup).targetEvent(ev).ok('Speichern').cancel('Abbrechen')
      $mdDialog.show(confirm).then ((result) ->
        if result == ''
          return
          
        $http.put('https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/' + result, 
          {name: result}, 
          {
            headers: {
              'Content-Type': 'application/json',
              'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
              }
          }).then ((response) ->
          vm.settings.personGroup = result
          return
        ), (response) ->
          # failure callback

          # the person group already exists, so we just use it
          if response.status == 409
            vm.settings.personGroup = result
          console.log response
          return
        return
      )
      return
      
    return vm

]