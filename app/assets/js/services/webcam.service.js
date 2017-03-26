(function() {
  this.FaceAuthApp.service('WebcamService', [
    function() {
      var _stream, _video, getVideoData, service, webcam;
      webcam = {};
      webcam.isTurnOn = false;
      webcam.patData = null;
      _video = null;
      _stream = null;
      webcam.patOpts = {
        x: 0,
        y: 0,
        w: 25,
        h: 25
      };
      webcam.channel = {};
      webcam.webcamError = false;
      getVideoData = function(x, y, w, h) {
        var ctx, hiddenCanvas;
        hiddenCanvas = document.createElement('canvas');
        hiddenCanvas.width = _video.width;
        hiddenCanvas.height = _video.height;
        ctx = hiddenCanvas.getContext('2d');
        ctx.drawImage(_video, 0, 0, _video.width, _video.height);
        return ctx.getImageData(x, y, w, h);
      };
      webcam.makeSnapshot = function() {
        var ctxPat, idata, patCanvas;
        if (_video) {
          patCanvas = document.querySelector('#snapshot-storage');
        }
        if (!patCanvas) {
          return;
        }
        patCanvas.width = _video.width;
        patCanvas.height = _video.height;
        ctxPat = patCanvas.getContext('2d');
        idata = getVideoData(webcam.patOpts.x, webcam.patOpts.y, webcam.patOpts.w, webcam.patOpts.h);
        ctxPat.putImageData(idata, 0, 0);
        return patCanvas.toDataURL();
      };
      webcam.onSuccess = function() {
        _video = webcam.channel.video;
        webcam.patOpts.w = _video.width;
        webcam.patOpts.h = _video.height;
        webcam.isTurnOn = true;
      };
      webcam.onStream = function(stream) {
        var activeStream;
        activeStream = stream;
        return activeStream;
      };
      webcam.downloadSnapshot = function(dataURL) {
        window.location.href = dataURL;
      };
      webcam.onError = function(err) {
        webcam.webcamError = err;
      };
      webcam.turnOff = function() {
        var checker;
        webcam.isTurnOn = false;
        if (activeStream && activeStream.getVideoTracks) {
          checker = typeof activeStream.getVideoTracks === 'function';
        }
        if (checker) {
          return activeStream.getVideoTracks()[0].stop();
        }
        return false;
        return false;
      };
      service = {
        webcam: webcam
      };
      return service;
    }
  ]);

}).call(this);
