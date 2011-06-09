function progressbar(o) {
  if(o) {
    var pBar = document.getElementById("progress-bar-main");
    if (!pBar) {
      var divMain = document.createElement("div");
      divMain.id = "progress-bar-main";
      divMain.className = "progress_bar_main";
      document.body.appendChild(divMain);
      pBar = document.getElementById("progress-bar-main");
    }
    if (o.remove) {
      document.body.removeChild(pBar);
    } else {
      var pBarNote = document.getElementById("progress-bar-note");
      if (!pBarNote) {
        var divNote = document.createElement("div");
        divNote.id = "progress-bar-note";
        divNote.className = "progress_bar_note";
        pBar.appendChild(divNote);
        pBarNote = document.getElementById("progress-bar-note");
        if(o.note) pBarNote.innerHTML = o.note;
      }
      var pBarContainer = document.getElementById("progress-bar-container");
      if (!pBarContainer) {
        var divContainer = document.createElement("div");
        divContainer.id = "progress-bar-container";
        divContainer.className = "progress_bar_container";
        pBar.appendChild(divContainer);
        pBarContainer = document.getElementById("progress-bar-container");
      }
      var pBarStatus = document.getElementById("progress-bar-status");
      if (!pBarStatus) {
        var divStatus = document.createElement("div");
        divStatus.id = "progress-bar-status";
        divStatus.className = "progress_bar_status";
        pBarContainer.appendChild(divStatus);
        pBarStatus = document.getElementById("progress-bar-status");
      }
      if(o.state) {
        pBarStatus.style.width = o.state+"%";
      } else {
        pBarStatus.style.width = "0";
      }
    }
  }
}
