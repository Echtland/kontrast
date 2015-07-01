@VideoView = Backbone.View.extend
  el: '#bgVideo'
  events:
    'click .play' : 'openVideo'

  initialize: ->
    return unless @el
    @initBackground()
    @ratio = 0.419
    @video = @$('.video')
    @iframe = @video.find('iframe')
    @originalHeight = @$el.height()
    @closeBtn = @$('.fa-times').on 'click', @closeVideo.bind(@)
    @resizeVideo()

    $(window).on 'resize', @resizeVideo.bind(@)

  initBackground: ->
    @$el.vide {mp4: @el.dataset.video},
      volume: 0
      playbackRate: 0.5
      muted: true
      loop: true
      autoplay: true
      position: '50% 50%'
      posterType: 'jpg'
      resizing: true

  resizeVideo: (e) ->
    width = @iframe.parent().width()
    height = width * @ratio
    @iframe.attr 'height', height + 'px'
    if @video.is(':visible')
      @$el.animate
        'min-height': height
        height: height

  openVideo: ->
    width = @iframe.parent().width()
    height = width * @ratio

    @$el.animate
      'min-height': height
      height: height
    , 'slow', =>
      @video.show().animateCss 'fadeIn'
      @post 'play'
      @closeBtn.show()
      # @post 'setVolume', '0'
    $('html, body').animate
      scrollTop: 0


  closeVideo: ->
    @$el.animate
      'min-height': @originalHeight
      height: @originalHeight
    , 'slow', =>
      @video.queue ->
        $(this).animateCss 'fadeOut'
      .hide()
      @closeBtn.animateCss 'fadeOut'
      @post 'unload'

  triggerPlay: ->
    iframe = @video.find('iframe')[0]

  post: (action, value) ->
    data =
      method: action
    data.value = value if value
    message = JSON.stringify(data)
    @iframe[0].contentWindow.postMessage data, '*'
