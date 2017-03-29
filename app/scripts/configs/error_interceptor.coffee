# this intercepter is used to display error messages that a server may return if a request to the
# Microsoft API was unsuccessful (statusCode = 40x or 50x)
@FaceAuthApp
  .config [
    '$httpProvider'
    ($httpProvider) ->
      $httpProvider.interceptors.push [
        '$q'
        '$injector'
        ($q, $injector) ->
          {
          responseError: (rejection) ->
            # manually inject the $mdToast service
            mdToastService = $injector.get('$mdToast')
            # display a simple $mdToast (https://material.angularjs.org/latest/api/service/$mdToast) with the error message for 15 seconds
            mdToastService.show mdToastService.simple().textContent(rejection.data.error.message).position('right').hideDelay(15000)

            # pass the rejected promise to the app :)
            $q.reject rejection
          }
      ]
      return
  ]