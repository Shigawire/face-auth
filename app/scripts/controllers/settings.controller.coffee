# this controller provides global settings
@FaceAuthApp.controller 'SettingsController', [
  '$scope'
  '$mdDialog'
  '$localStorage'
  '$http'
  'Person'
  ($scope, $mdDialog, $localStorage, $http, Person) ->
    # map "this" to a vm-variable
    vm = @

    # load the app's settings and users
    vm.settings = $localStorage.settings
    vm.users = $localStorage.users


    # show a dialog to update the Microsoft Cognitive Services API key
    vm.editApiKey = (ev) ->
      confirm = $mdDialog.prompt().title('Bitte gib deinen Microsoft Cognitive Services API Key an').placeholder('API Key').ariaLabel('API Key').initialValue(vm.settings.apiKey).targetEvent(ev).ok('Speichern').cancel('Abbrechen')
      $mdDialog.show(confirm).then ((result) ->
        vm.settings.apiKey = result

        # reload the window to ensure that the $localStorage settings have been passed to all injecting services
        location.reload()
        return
      )
      return

    # show a dialog to update the app's person groups (used at the Microsoft Cognitive Services API)
    vm.editPersonGroup = (ev) ->
      confirm = $mdDialog.prompt().title('Bitte gib eine personGroup an.').textContent('Die Microsoft API benutzt personGroups um Gesichter innerhalb eines Benutzerpools zuzuordnen.\n\nBitte beachte die Hinweise in den Einstellungen!').placeholder('Person group').ariaLabel('Person group').initialValue(vm.settings.personGroup).targetEvent(ev).ok('Speichern').cancel('Abbrechen')
      $mdDialog.show(confirm).then ((result) ->

        # when the person group has been deleted, cancel
        if result == ''
          return
        
        # try to create the person group at the Microsoft API via a simple PUT :)
        $http.put('https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/' + result,
          # submit the person group's name as argument
          {name: result},
          # configure headers
          {
            headers: {
              'Content-Type': 'application/json',
              'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
              }
          }).then ((response) ->

          # on success, overwrite the app's settings with the new person group
          vm.settings.personGroup = result

          # reload the window to ensure that the $localStorage settings have been passed to all injecting services
          location.reload()

          # initiate a training of the person group at the API
          # Person is a particular Angular-factory that connects to the API. See file face_api.factories.coffee for all factories.
          Person.trainFaces {personGroup: result}
          return
        ), (response) ->
          # failure callback
          # the person group already exists, so we just use that
          if response.status == 409
            vm.settings.personGroup = result
          # log the error message
          console.log response
          return
        return
      )
      return

    # vm.deleteUser = (user) ->
    #   # send a deletion request to the Microsoft API
    #   Person.delete { personGroup: user.personGroup, personId: user.personId }, (data) ->
    #     # once the Person has been deleted we can remove the user from our database
    #     console.log data
    #     # remove the deleted user from the app's user database (by filtering out the one that ought to be deleted)
    #     userListWithoutUser = (vm.users.filter (localUser) ->
    #         localUser.personId != user.personId)
    #     $localStorage.users = userListWithoutUser
    return vm

]