(function() {
  this.FaceAuthApp.config([
    '$httpProvider', function($httpProvider) {
      $httpProvider.interceptors.push([
        '$q', '$injector', function($q, $injector) {
          return {
            responseError: function(rejection) {
              var mdToastService;
              mdToastService = $injector.get('$mdToast');
              mdToastService.show(mdToastService.simple().textContent(rejection.data.error.message).position('right').hideDelay(15000));
              return $q.reject(rejection);
            }
          };
        }
      ]);
    }
  ]);

}).call(this);
