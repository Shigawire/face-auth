@FaceAuthApp.controller 'SignInController', [
  '$scope'
  'WebcamService'
  'FaceSnapshotService'
  '$localStorage'
  '$mdDialog'
  ($scope, WebcamService, FaceSnapshotService, $localStorage, $mdDialog) ->
    # inject "this"
    vm = @

    # load the webcam service to the scope
    vm.webcam = WebcamService.webcam

    # close the dialog window and pass the identifiedUser back to the dashboardController
    vm.closeSignInDialog = ->
      $mdDialog.hide(vm.identifiedUser)

    vm.cancelSignInDialog = ->
      $mdDialog.hide(undefined)

    # take a snapshot and authenticate the user
    vm.doAuthSnapshot = ->
      vm.snapshot = {
        # let the webcam service take the snapshot
        data: vm.webcam.makeSnapshot(),
        # has the user been identified yet?
        identified: false,
        # is the identification still in progress?
        inProgress: true
      }

      # identify the user
      FaceSnapshotService.identifyUser(vm.snapshot.data)
        .then (userData) ->
          if !userData.success
            vm.failureReason = userData.errorMessage
            vm.snapshot.identified = false
            return
        
          # get the user from the internal 'database' that matches the returned personId
          vm.identifiedUser = ($localStorage.users.filter (user) ->
            # user.personId is in our database, data.personId is the one returned from the face API
            user.personId == userData.data.person.personId)[0]
          vm.snapshot.identified = true
          

          # draw the user's faceLandmarks into the snapshot
          vm.snapshot.withLandmarks = FaceSnapshotService.addLandmarks vm.snapshot.data, userData.data.face
        .finally ->
          vm.snapshot.inProgress = false

    return vm
]