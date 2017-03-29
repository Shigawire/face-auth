# this section introduces multiple factories used in the application to interact with the Microsoft API.
# By using a factory for these interaction-tasks we remove a lot of logic from the controller which improves modularity and readability

# For the interaction with the Microsoft Cognitive Services API the Angular's built-in $resource-service is used.

# This is a factory to interact with the 'Face'-endpoint of the Microsoft Cognitive Services API. It is used to detect the presence of faces in 
# snapshots and to identify Persons within a given snapshots
@FaceAuthApp.factory 'Face', [
    '$resource',
    '$localStorage'
    ($resource, $localStorage) ->
        $resource('https://westus.api.cognitive.microsoft.com/face/v1.0/detect?returnFaceId=true&returnFaceLandmarks=true', 
            {},
            { 
                detect: { 
                    method: 'POST',
                    isArray: true,
                    transformRequest: angular.identity,
                    headers: {
                    'Content-Type': 'application/octet-stream; charset=binary',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
                identify: {
                    method: 'POST',
                    isArray: true,
                    url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/identify',
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
            })
]

# The 'Person' factory is used to handle person-related task at the API, i.e. the creation of persons,
# returning a given person, adding faces to a specific person, or training the person's uploaded faces.
@FaceAuthApp.factory 'Person', [
    '$resource',
    '$localStorage'
    ($resource, $localStorage) ->
        $resource('https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/persons/:personId',
            {personGroup: '@personGroup', personId: '@personId'},
            {
                save: {
                    method: 'POST',
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                } 
                get: { 
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
                delete: {
                    method: 'DELETE'
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
                addFace: {
                    method: 'POST',
                    url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/persons/:personId/persistedFaces',
                    # angular magic (http://softwareengineering.stackexchange.com/questions/283109/why-sending-a-file-is-so-difficult-using-angular)
                    transformRequest: angular.identity,
                    headers: {
                    # ensure the snapshot is submitted as binary data
                    'Content-Type': 'application/octet-stream; charset=binary',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
                trainFaces: {
                    method: 'POST',
                    url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/train',
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
                trainingStatus: {
                    method: 'GET',
                    url: 'https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/:personGroup/training',
                    headers: {
                    'Content-Type': 'application/json',
                    'Ocp-Apim-Subscription-Key': $localStorage.settings.apiKey
                    }
                }
            })
]