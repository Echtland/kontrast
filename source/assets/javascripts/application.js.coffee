#= require 'jquery'
#= require 'underscore'
#= require 'backbone'
#= require 'vide'
#= require_tree .

$('#bgVideo').vide {mp4: '/woibbadinga/assets/images/vb.mp4'},
  volume: 0
  playbackRate: 0.5
  muted: true
  loop: true
  autoplay: true
  position: '50% 50%'
  posterType: 'jpg'
  resizing: true

VideoView = Backbone.View.extend
  el: '#bgVideo'
  events:
    'click .play' : 'openVideo'

  initialize: ->
    @ratio = 0.419
    @video = @$('.video')
    @iframe = @video.find('iframe')
    @originalHeight = @$el.height()
    @closeBtn = @$('.fa-times').on 'click', @closeVideo.bind(@)
    @resizeVideo()

    $(window).on 'resize', @resizeVideo.bind(@)

  resizeVideo: (e) ->
    width = @iframe.parent().width()
    height = width * @ratio
    console.log "#{width} x #{height}"
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

CollapseView = Backbone.View.extend
  el: '.section-collapse'
  events:
    'click .collapse-next' : 'nextItem'
    'click .collapse-prev' : 'prevItem'
    'click .collapse-all'  : 'toggle'
    # 'webkitAnimationEnd .collapse-item' : 'aniend'

  initialize: ->
    @items = @$('.collapse-item')
    @controls = @$('.collapse-control')
    @currentItem = 0
    @totalItems = @items.length
    @allOpen = false

    @collection = new Backbone.Collection()
    for item, i in @items
      item.dataset.number = i
      $(item).hide() if i > 0
      image = $(item).find('.section-image')
      imageSrc = image.find('img').attr('src')
      $(item).find('.section-image').css 'background-image', "url('#{imageSrc}')"
      model = new Backbone.Model({item: item, number: i})
      @collection.add model

    @state = new Backbone.Model
      currentItem: 0
      allOpen: false

  getCurrentItem: ->
    $(@items[@currentItem])

  nextItem: ->
    return if @allOpen
    current = $(@items[@currentItem])
    if (@currentItem + 1) >= @totalItems
      next = $(@items[0])
      @currentItem = 0
    else
      next = $(@items[@currentItem + 1])
      @currentItem = @currentItem + 1

    current.animateCss 'slideOutLeft',
      duration: 0.3
      done: -> @hide()
    next.css('position', 'absolute').css('top', '0').show().animateCss 'slideInRight',
      duration: 0.3
      done: -> @css('position', '').css('top', '')


  prevItem:  ->
    return if @allOpen
    current = $(@items[@currentItem])
    if (@currentItem - 1) < 0
      next = $(@items[@totalItems - 1])
      @currentItem = @totalItems - 1
    else
      next = $(@items[@currentItem - 1])
      @currentItem = @currentItem - 1

    current.animateCss 'slideOutRight',
      duration: 0.3
      done: -> @hide()
    next.css('position', 'absolute').css('top', '0').show().animateCss 'slideInLeft',
      duration: 0.3
      done: -> @css('position', '').css('top', '')

  toggle: ->
    items = if @allOpen then @items.toArray().reverse() else @items

    for item, i in items
      number = parseInt(item.dataset.number)
      $this = $(item)

      unless @allOpen
        @$el.queue 'toggle', @open.bind(@, item, i)
      else
        # unless number == @currentItem
        @$el.queue 'toggle', @close.bind(@, item, i)

    @$el.queue 'toggle', (next) =>
      @allOpen = if @allOpen then false else true
      next()

    @$el.queue 'toggle', @show.bind(@, @getCurrentItem())
    @$el.queue 'toggle', (next) =>
      unless @allOpen
        @controls.show().animateCss 'flipInX'
        next()
      else
        # @controls.animateCss 'fadeOut',
        #   done: ->
        #     @hide()
        @controls.hide()
        next()
    @$el.dequeue('toggle').clearQueue()
    $('html, body').animate
      scrollTop: @$el.offset().top
    return

  show: (current, next) ->
    return next() if @allOpen
    delay = (0.2 + 0.1 + @totalItems * 0.1) * 1000
    setTimeout =>
      current.removeClass('closed').show().animateCss('fadeIn')
      next()
    , delay

  open: (element, i, next) ->
    $el = $(element)
    $el.one 'click', (e) =>
      @currentItem = parseInt e.currentTarget.dataset.number
      $('html, body').animate
        scrollTop: @$el.offset().top
      @toggle()
    $el.removeClass('closed').addClass('open')
    $el.show().animateCss 'fadeIn',
      duration: 0.3
      delay: i * 0.1
    next()
    return

  close: (element, i, next) ->
    $el = $(element)
    $el.off 'click'
    $el.animateCss 'fadeOut',
      duration: 0.3
      delay: i * 0.1
      done: ->
        @removeClass('open').addClass('closed')
        @hide() #.css('position', 'absolute').removeClass 'section-small'
    next()
    return

$(document).ready ->
  vv = new VideoView
  cv = new CollapseView().render()

  $('#toggle-menu').click (e) ->
    e.preventDefault()
    $this = $(this)
    if $this.hasClass('visible')
      $('.nav-menu').fadeOut()
      $('.nav-menu-sub').fadeOut()
    else
      $('html, body').animate
        scrollTop: 0
      $('.nav-menu').fadeIn()
      $('.nav-menu-sub').fadeIn()
    $('body').toggleClass 'overlay-open'
    $this.toggleClass('visible').toggleClass('hidden')
