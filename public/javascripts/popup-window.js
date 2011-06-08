(function($) {
  $.popup = function(o) {
    var o = $.extend({
      time:5000,
      speed:'slow',
      note:null,
      className:null,
      sticked:false,
      remove:false,
      position:{top:0,right:0}
    }, o);
    var pWindow = $('#popup-window');
    if (!pWindow.length) {
      $('body').prepend('<div id="popup-window" class="main_popup"></div>');
      var pWindow = $('#popup-window');
    }
    if (o.remove) {
      pWindow.remove();
    } else {
      pWindow.css('position','fixed').css({right:'auto',left:'auto',top:'auto',bottom:'auto'}).css(o.position);
      var popup = $('<div class="popup"></div>');
      pWindow.append(popup);
      if (o.className) popup.addClass(o.className);
          popup.html(o.note);
      if (o.sticked) {
        var exit = $('<div class="exit"></div>');
        popup.prepend(exit);
        exit.click(function(){
          popup.fadeOut(o.speed,function(){
            $(this).remove();
          })
        });
      } else {
        setTimeout(function(){
          popup.fadeOut(o.speed,function(){
            $(this).remove();
          });
        }, o.time);
      }
    }
  };
})(jQuery);
