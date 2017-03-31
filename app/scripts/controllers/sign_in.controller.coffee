# this controller handles login logic
@FaceAuthApp.controller 'SignInController', [
  '$scope'
  'WebcamService'
  'FaceSnapshotService'
  '$localStorage'
  '$mdDialog'
  '$interval'
  ($scope, WebcamService, FaceSnapshotService, $localStorage, $mdDialog, $interval) ->
    # inject "this"
    vm = @
    vm

    # load the webcam service to the scope
    vm.webcam = WebcamService.webcam

    $scope.$watch('vm.webcam.isTurnOn', (newVal, oldVal) ->
      console.log newVal
    )

    # close the dialog window and pass an identified user back to the dashboardController
    vm.closeSignInDialog = ->
      $mdDialog.hide(vm.identifiedUser)

      # turn off the camera
      vm.webcam.turnOff()

    # cancel the sign in process, i.e. return no identified user
    vm.cancelSignInDialog = ->
      $mdDialog.hide(undefined)

      # turn off the camera
      vm.webcam.turnOff()

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

      # call the FaceSnapshotService to identify the user behind the camera
      FaceSnapshotService.identifyUser(vm.snapshot.data)
        .then (userData) ->
          # if the identification process was unsucessful
          if !userData.success
            # pass the reason of the identification failure
            vm.failureReason = userData.errorMessage
            vm.snapshot.identified = false
            return
        
          # get the user from the internal 'database' that matches the returned personId
          vm.identifiedUser = ($localStorage.users.filter (user) ->
            # user.personId is in our database, data.personId is the one returned from the Microsoft Cognitive Services Face API
            user.personId == userData.data.person.personId)[0]
          vm.snapshot.identified = true
          
          # draw the user's faceLandmarks into the snapshot
          # this image now replaces the regular snapshot
          vm.snapshot.withLandmarks = FaceSnapshotService.addLandmarks vm.snapshot.data, userData.data.face
        .finally ->
          vm.snapshot.inProgress = false

    return vm
]