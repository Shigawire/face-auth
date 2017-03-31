#https://github.com/jonashartmann/webcam-directive/wiki/Tutorial-to-create-service-for-webcam

@FaceAuthApp.service 'WebcamService', [
  '$rootScope'
  ($rootScope) -> 
    webcam = {}
    webcam.isTurnOn = false
    webcam.patData = null
    _video = null
    _stream = null
    activeStream = null
    webcam.patOpts =
      x: 0
      y: 0
      w: 25
      h: 25
    webcam.channel = {}
    webcam.webcamError = false

    getVideoData = (x, y, w, h) ->
      hiddenCanvas = document.createElement('canvas')
      hiddenCanvas.width = _video.width
      hiddenCanvas.height = _video.height
      ctx = hiddenCanvas.getContext('2d')
      ctx.drawImage _video, 0, 0, _video.width, _video.height
      ctx.getImageData x, y, w, h

    webcam.makeSnapshot = ->
      if _video
          patCanvas = document.querySelector('#snapshot-storage')
      if !patCanvas
          return
      patCanvas.width = _video.width
      patCanvas.height = _video.height
      ctxPat = patCanvas.getContext('2d')
      idata = getVideoData(webcam.patOpts.x, webcam.patOpts.y, webcam.patOpts.w, webcam.patOpts.h)
      ctxPat.putImageData idata, 0, 0
      return patCanvas.toDataURL()

    webcam.onSuccess = ->
      _video = webcam.channel.video
      webcam.patOpts.w = _video.width
      webcam.patOpts.h = _video.height
      webcam.isTurnOn = true
      $rootScope.$apply()
      return

    webcam.onStream = (stream) ->
      activeStream = stream
      activeStream

    webcam.downloadSnapshot = (dataURL) ->
      window.location.href = dataURL
      return

    webcam.onError = (err) ->
      webcam.webcamError = err
      return

    webcam.turnOff = ->
      webcam.isTurnOn = false
      if activeStream && activeStream.getVideoTracks
          checker = typeof activeStream.getVideoTracks == 'function'
      if checker
          return activeStream.getVideoTracks()[0].stop()
      return false
      false

    service = webcam: webcam
    service
]