(function() {
  var vm;

  this.FaceAuthApp.service('NotificationService', [
    '$mdToast', function($mdToast) {}, vm = this, vm.error = function(message) {
      return $mdToast.show($mdToast.simple().textContent(rejection.message).position(pinTo).hideDelay(3000));
    }
  ]);

}).call(this);
