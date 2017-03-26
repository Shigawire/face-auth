@FaceAuthApp.service 'FaceSnapshotService', [
    '$q'
    '$http'
    'Face'
    '$localStorage'
    ($q, $http, Face, $localStorage) -> 
        vm = @

        # http://stackoverflow.com/questions/32008523/send-an-uploaded-image-to-the-server-and-save-it-in-the-server
        # this helper function converts a Data URL image into the binary format required by the Microsoft Cognitive Services API
        vm.dataURItoBlob = (dataURI) ->
            binary = atob(dataURI.split(',')[1])
            mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0]
            array = []
            i = 0
            while i < binary.length
                array.push binary.charCodeAt(i)
                i++
            new Blob([ new Uint8Array(array) ], type: mimeString)

        # verify there is a face in the submitted snapshot
        vm.verifyFacePresence = (snapshot) ->
            deferred = $q.defer()
            Face.detect vm.dataURItoBlob(snapshot), ((data) ->
                if data.length == 0
                    deferred.resolve {success: false, errorMessage: 'Kein Gesicht im Bild vorhanden.'}
                else 
                    deferred.resolve {success: true, data: data}
            ), (error) ->
                # there was an errorneous response
                # resolve the deferred object with a failure notice
                deferred.resolve {success: false, errorMessage: error.data.error.message}

            # return a promise that the callee can use for callbacks
            return deferred.promise

        # verify that the face is not know to the API, i.e. there is no such user, yet
        vm.verifyFaceUniqueness = (snapshot) ->
            return

        # identify a user, based on a given snapshot
        # on successful identification: returns a personId and the corresponding faceLandmarks in the snapshot

        vm.identifyUser = (snapshot) ->
            deferred = $q.defer()

            # first, submit a face snapshot to the Microsoft Cognitive Services API to receive a faceId
            vm.verifyFacePresence(snapshot).then (faceData) ->
                if !faceData.success
                    # pass the failure result to the callee
                    deferred.resolve faceData
                    # and return
                    return
                face = faceData.data[0]

                # now, use the faceId to assert that the discovered faceId belongs to a person in our registered personGroup
                Face.identify {
                    personGroupId: $localStorage.settings.personGroup, 
                    faceIds: [face.faceId], 
                    maxNumOfCandidatesReturned: 1,
                    confidenceThreshold: 0.5
                }, ((personData) ->
                    deferred.resolve {success: true, data: {person: personData[0].candidates[0], face: face}}
                ), (error) ->
                    deferred.resolve {sucess: false, errorMessage: error.data.error.message}

            return deferred.promise


        vm.addLandmarks = (snapshot, landmarks) ->

            canvas = document.getElementById 'snapshot-storage'
            context = canvas.getContext '2d'

            # draw face rectangle
            context.beginPath()
            context.strokeStyle = 'yellow'
            context.lineWidth = 3
            context.closePath()
            context.strokeRect(
                landmarks.faceRectangle.left,
                landmarks.faceRectangle.top,
                landmarks.faceRectangle.height,
                landmarks.faceRectangle.width)
            context.fill()

            #draw mouth 

            context.beginPath();
            context.strokeStyle = '#00FF00';
            context.lineWidth=2;
            context.moveTo(landmarks.faceLandmarks.mouthLeft.x,landmarks.faceLandmarks.mouthLeft.y);
            context.lineTo(landmarks.faceLandmarks.mouthRight.x,landmarks.faceLandmarks.mouthRight.y);
            context.stroke();

            #draw pupils and mouth
            context.beginPath();
            context.fillStyle = '#00FF00';
            context.fillRect(landmarks.faceLandmarks.pupilLeft.x, landmarks.faceLandmarks.pupilLeft.y, 5, 5);
            context.fillRect(landmarks.faceLandmarks.pupilRight.x, landmarks.faceLandmarks.pupilRight.y, 5, 5);

            context.fillRect(landmarks.faceLandmarks.noseTip.x, landmarks.faceLandmarks.noseTip.y, 5, 5);
            context.stroke();

            return canvas.toDataURL('image/png')
        return vm

   
]