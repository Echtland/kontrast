#= require 'jquery'
#= require 'vide'
#= require_tree .

$(window).scroll ->
  $this = $(this)
  $cover = $('.cover')
  if $this.scrollTop() < $cover.height()
    $cover.find('h1').css
      'margin-top': ($this.scrollTop()/2)+"px"
      opacity: 1 - ($this.scrollTop()/1000)

debugger
$('#bgVideo').vide {mp4: '/assets/images/vb.mp4'},
  volume: 0
  playbackRate: 0.5
  muted: true
  loop: true
  autoplay: true
  position: '50% 50%'
  posterType: 'jpg'
  resizing: true

