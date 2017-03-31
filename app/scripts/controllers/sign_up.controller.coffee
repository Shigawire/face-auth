# this controller handles user sign-ups
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
    # map "this" to a vm-variable
    vm = @

    # name of the new user 
    vm.user = ''

    # a list of snapshots of the user's face
    vm.snapshotList = []

    # the current index of the sign up's dialog progress cards
    vm.selectedIndex = 0

    # reference to the webcam service
    vm.webcam = WebcamService.webcam

    # function for adding snapshots from the view
    vm.addSnapshot = ->
      # create a new snapshot-Object
      snapshot = {
        data: vm.webcam.makeSnapshot(),
        accepted: undefined,
        inProgress: true
      }

      # push the new snapshot to our snapshotList
      vm.snapshotList.push snapshot

      # the controller is in snapshotVerifying-mode now
      vm.snapshotVerifying = true

      # call FaceSnapshotService to verify there is a face present in the submitted snapshot
      FaceSnapshotService.verifyFacePresence(snapshot.data)
        .then (faceData) ->
          # if there is no face detected we do not even need to try an identification process
          if !faceData.success
            # pass an error for the view :)
            snapshot.errorMessage = faceData.errorMessage
            return

          # if a face is present, verify that the user is not already added to the database
          FaceSnapshotService.identifyUser snapshot.data
            .then (userData) ->
              # if the identification process was successful and we have a specific person ID returned
              # we know that the user exists already
              # ergo, reject this snapshot with an error message
              if userData.success && userData.data.person
                snapshot.accepted = false
                snapshot.errorMessage = 'Dieses Gesicht wurde bereits einem Nutzer zugeordnet.'
                return

              # if the snapshot contains an unknown face it may serve as base for a new sign up
              snapshot.accepted = true
              snapshot.withLandmarks = FaceSnapshotService.addLandmarks snapshot.data, faceData.data[0]
        # in any case, after the FaceSnapshotService has finished we release the controller to allow taking new snapshots
        .finally ->
          snapshot.inProgress = false
          # controller is not in verifying mode anymore
          vm.snapshotVerifying = false
    
    vm.createUser = ->
      # the stepsFinished array depicts the steps of the user creation process
      # step 1: create Person at the API endpoint
      # step 2: upload the Person's faces to the API
      # step 3: enqueue a training job at the API
      # step 4: query the API until the face's training is finished
      vm.stepsFinished = [false, false, false, false]

      # advance the wizard to the last step
      vm.selectedIndex = 2

      # create a new Person at the Microsoft API endpoint (see face_api.factories.coffee for detailed infos about the Person-factory)
      # build a new Person with the app's person group derived from the settings storage
      # and the name the user previously entered
      user = new Person ({ personGroup: $localStorage.settings.personGroup, name: vm.name })
      # does the actual POST-call to the API
      user.$save (data) ->
        # once the Person has been added at the API, the first step is finished
        vm.stepsFinished[0] = true
        # we collect the Microsoft API's personId for our new user
        user.personId = data.personId
        
        # now, we upload all three snapshots :)

        # let us store a list of promises that hold the upload process for each snapshot
        uploadPromises = []
        # send the previously recorded screenshots to the API and attach to the Person
        for snapshot in vm.snapshotList
          # call the addFace endpoint of the Person-factory with the snapshot image converted to binary data
          uploadPromises.push Person.addFace { personGroup: $localStorage.settings.personGroup, personId: user.personId }, FaceSnapshotService.dataURItoBlob(snapshot.data)
        
        # when all uploadPromises are resolved (i.e. the upload of the snapshots is finished)
        $q.all(uploadPromises).then ->
          vm.stepsFinished[1] = true
          # enqueue a training job for the uploaded snapshots
          Person.trainFaces {personGroup: $localStorage.settings.personGroup}, ->
            vm.stepsFinished[2] = true

            # wait until the training has finished by checking the status every two seconds
            # initiate a recurring interval
            checkTrainingInterval = $interval (->
              Person.trainingStatus { personGroup: $localStorage.settings.personGroup }, (data) ->

                # the API will report the training status as succeeded (or failed)
                if data.status == 'succeeded'
                  # stop the interval
                  $interval.cancel checkTrainingInterval
                  vm.stepsFinished[3] = true

                  # now the user is fully present at the Microsoft API 
                  # which means the biometric sign up process is done.
                  # Thus, we add the user to the app's internal database.
                  $localStorage.users.push {personId: user.personId, personGroup: $localStorage.settings.personGroup, name: vm.name, secret: vm.secret}
                else if data.status == 'failed'
                  # stop the interval
                  $interval.cancel checkTrainingInterval
                  vm.stepsFinished[3] = false
            ), 2000

    # remove snapshot from snapshotList
    vm.removeSnapshot = (snapshot) ->
      vm.snapshotList = vm.snapshotList.filter (item) ->
        item.data != snapshot.data
      
    # count the number of snapshots in snapshotList with a detected (i.e. accepted) face
    # this value is used to ensure that exactly three acceptable screenshots are avaiable
    vm.acceptedSnapshots = -> 
      (vm.snapshotList.filter (snapshot) ->
        snapshot.accepted == true).length

    # cancel the sign up dialog
    vm.closeSignUpDialog = ->
      $mdDialog.hide()

      # turn off the camera
      vm.webcam.turnOff()
      return
    
    return vm
]