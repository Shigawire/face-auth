@FaceAuthApp.controller 'SignUpController', [
  '$scope'
  '$mdDialog'
  'WebcamService'
  'FaceSnapshotService'
  '$localStorage'
  'Person'
  '$q'
  '$interval'
  ($scope, $mdDialog, WebcamService, FaceSnapshotService, $localStorage, Person, $q, $interval) ->
    vm = @

    # name of the new user 
    vm.user = ''

    # a list of snapshots of the user's face
    vm.snapshotList = []

    # the current index of the sign up's modal cards
    vm.selectedIndex = 0

    # reference to the webcam service
    vm.webcam = WebcamService.webcam

    # function for adding snapshots from the view
    vm.addSnapshot = ->
      snapshot = {
        data: vm.webcam.makeSnapshot(),
        accepted: undefined,
        inProgress: true
      }

      vm.snapshotList.push snapshot

      vm.snapshotVerifying = true

      # verify there is a face present in the submitted snapshot
      FaceSnapshotService.verifyFacePresence(snapshot.data)
        .then (faceData) -> 
          if !faceData.success
            snapshot.errorMessage = faceData.errorMessage
            return

          # if a face is present, verify that the user is not already added to the database
          FaceSnapshotService.identifyUser snapshot.data
            .then (userData) ->
              console.log userData
              if userData.success && userData.data.person
                snapshot.accepted = false
                snapshot.errorMessage = 'Dieses Gesicht wurde bereits einem Nutzer zugeordnet.'
                return
              snapshot.accepted = true
              snapshot.withLandmarks = FaceSnapshotService.addLandmarks snapshot.data, faceData.data[0]

        .finally ->
          snapshot.inProgress = false
          vm.snapshotVerifying = false
    
    vm.createUser = ->
      # step 1: create Person at the API endpoint
      # step 2: upload the Person's faces
      # step 3: enqueue a training job 
      # step 4: wait until training is finished

      vm.stepsFinished = [false, false, false, false]
      # advance the wizard to the last step
      vm.selectedIndex = 2

      # create a new Person at the Microsoft API endpoint
      user = new Person ({ personGroup: $localStorage.settings.personGroup, name: vm.name })
      user.$save (data) ->
        vm.stepsFinished[0] = true
        user.personId = data.personId
        
        # let us store a list of promises that hold the upload process for each snapshot
        uploadPromises = []
        # send the previously recorded screenshots to the API and attach to the Person
        for snapshot in vm.snapshotList
          uploadPromises.push Person.addFace { personGroup: $localStorage.settings.personGroup, personId: user.personId }, FaceSnapshotService.dataURItoBlob(snapshot.data)
        
        # when all uploadPromises are resolved (i.e. the upload of the snapshots is finished)
        $q.all(uploadPromises).then ->
          vm.stepsFinished[1] = true
          # enqueue a training job for the uploaded snapshots
          Person.trainFaces {personGroup: $localStorage.settings.personGroup}, ->
            vm.stepsFinished[2] = true
            # wait until the training has finished

            checkTrainingInterval = $interval (->
              Person.trainingStatus { personGroup: $localStorage.settings.personGroup }, (data) ->

                # the API will report the training status as succeeded (or failed)
                if data.status == 'succeeded'
                  $interval.cancel checkTrainingInterval
                  vm.stepsFinished[3] = true

                  # add the user to the internal database
                  $localStorage.users.push {personId: user.personId, name: vm.name, secret: vm.secret}
                else if data.status == 'failed'
                  $interval.cancel checkTrainingInterval
                  vm.stepsFinished[3] = true
            ), 2000

    # remove snapshot from snapshotList
    vm.removeSnapshot = (snapshot) ->
      vm.snapshotList = vm.snapshotList.filter (item) ->
        item.data != snapshot.data
      
    # count the number of snapshots in snapshotList with a detected (i.e. accepted) face
    vm.acceptedSnapshots = -> 
      (vm.snapshotList.filter (snapshot) ->
        snapshot.accepted == true).length

    vm.closeSignUpDialog = ->
      $mdDialog.hide()
      return
    
    return vm
]