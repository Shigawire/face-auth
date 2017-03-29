# this section configures the App's routing.
# For this demo there is only a dashboard and a settings controller
@FaceAuthApp
  .config [
    '$stateProvider'
    '$urlRouterProvider'
    '$locationProvider'
    ($stateProvider, $urlRouterProvider, $locationProvider) ->
      # default route
      $urlRouterProvider.otherwise '/dashboard'
      $stateProvider.state 'dashboard',
        url: '/dashboard'
        templateUrl: 'templates/views/dashboard.html'
        controller: 'DashboardController'
        # inject the controller as view model (vm)-variable
        # read more about this here https://johnpapa.net/angularjss-controller-as-and-the-vm-variable/
        controllerAs: 'vm'
      $stateProvider.state 'settings',
        url: '/settings'
        templateUrl: 'templates/views/settings.html'
        controller: 'SettingsController'
        controllerAs: 'vm'
      return
  ]