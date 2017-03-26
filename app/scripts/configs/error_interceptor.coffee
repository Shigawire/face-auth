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
              mdToastService = $injector.get('$mdToast')
              mdToastService.show mdToastService.simple().textContent(rejection.data.error.message).position('right').hideDelay(15000)

              $q.reject rejection
          }
      ]
      return
  ]