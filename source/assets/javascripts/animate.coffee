do ($ = jQuery, window, document) ->
  transitionEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend'

  defaults =
    effect: null
    duration: 0.5
    delay: 0
    queue: false
    done: $.noop

  class AnimateCss
    constructor: (@$el, options) ->
      @settings = $.extend {}, defaults, options
      @_transitionEnd = transitionEnd
      @init()

    init: ->
      if @settings.queue
        @$el.queue @start.bind(@)
      else
        @start()

      return

    start: ->
      $el = @$el
      @$el.one @_transitionEnd, @end.bind(@)
      @setAttributes(@settings.duration + "s", @settings.delay + "s")
      @$el.addClass("animated #{@settings.effect}")

    end: ->
      @setAttributes('', '')
      @$el.removeClass("animated #{@settings.effect}")
      @$el.dequeue() if @settings.queue
      @settings.done.apply(@$el)

    setAttributes: (duration, delay) ->
      for vendor in ['', '-webkit-', '-moz-']
        @$el.css "#{vendor}animation-duration", duration
        @$el.css "#{vendor}animation-delay", delay

  $.fn.queueAnimateCss = (effect, duration, delay) ->
    options = $.extend {}, {effect: effect, queue: true}, options
    new AnimateCss @, options
    return @

  $.fn.animateCss = (effect, options) ->
    options = $.extend {}, {effect: effect}, options
    new AnimateCss @, options
    return @
