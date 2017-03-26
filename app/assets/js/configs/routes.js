(function() {
  this.FaceAuthApp.config([
    '$stateProvider', '$urlRouterProvider', '$locationProvider', function($stateProvider, $urlRouterProvider, $locationProvider) {
      $urlRouterProvider.otherwise('/dashboard');
      $stateProvider.state('dashboard', {
        url: '/dashboard',
        templateUrl: 'templates/views/dashboard.html',
        controller: 'DashboardController',
        controllerAs: 'vm'
      });
      $stateProvider.state('settings', {
        url: '/settings',
        templateUrl: 'templates/views/settings.html',
        controller: 'SettingsController',
        controllerAs: 'vm'
      });
    }
  ]);

}).call(this);
