@FaceAuthApp
  .config [
    '$stateProvider'
    '$urlRouterProvider'
    '$locationProvider'
    ($stateProvider, $urlRouterProvider, $locationProvider) ->
      # enable HTML5 URLS
      #$locationProvider.html5Mode true
      $urlRouterProvider.otherwise '/dashboard'
      $stateProvider.state 'dashboard',
        url: '/dashboard'
        templateUrl: 'templates/views/dashboard.html'
        controller: 'DashboardController'
        controllerAs: 'vm'
      $stateProvider.state 'settings',
        url: '/settings'
        templateUrl: 'templates/views/settings.html'
        controller: 'SettingsController'
        controllerAs: 'vm'
      return
  ]