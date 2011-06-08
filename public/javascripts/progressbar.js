function progressbar(o) {
  var o = $.extend({
    state:0,
    note:"",
    remove:false,
    position:{top:0,left:0}
  }, o);
  var pBar = $("#progress-bar-main");
  if (!pBar.length) {
    $('body').prepend('<div id="progress-bar-main" class="progress_bar_main"></div>');
    pBar = $("#progress-bar-main");
  }
  if (o.remove) {
    pBar.remove();
  } else {
    pBar.css(o.position);
    var pBarNote = $("#progress-bar-note");
    if (!pBarNote.length) {
      pBarNote = $("<div id='progress-bar-note' class='progress_bar_note'>" + o.note + "</div>");
      pBar.append(pBarNote);
    }
    var pBarContainer = $("#progress-bar-container");
    if (!pBarContainer.length) {
      pBarContainer = $("<div id='progress-bar-container' class='progress_bar_container'></div>");
      pBar.append(pBarContainer);
    }
    var pBarStatus = $("#progress-bar-status");
    if (!pBarStatus.length) {
      pBarStatus = $("<div id='progress-bar-status' class='progress_bar_status'></div>");
      pBarContainer.append(pBarStatus);
    }
    pBarStatus.css('width', o.state+"%");
  }
}
