(function() {
  this.FaceAuthApp.controller('AppController', [
    '$localStorage', function($localStorage) {
      if (!$localStorage.settings) {
        $localStorage.settings = {};
      }
      if (!$localStorage.users) {
        return $localStorage.users = [];
      }
    }
  ]);

}).call(this);
