function loadScript(sScriptSrc, oCallback) {
  var oScript = document.createElement("script");
  oScript.type = "text/javascript";
  oScript.src = sScriptSrc;
  oScript.onload = oCallback;
  oScript.onreadystatechange = function() {
    if (this.readyState == "complete") {
      oCallback();
    }
  };
  document.getElementsByTagName("head")[0].appendChild(oScript);
}
function loadCss(sCssSrc, oCallback) {
  var oCss = document.createElement("link");
  oCss.href = sCssSrc;
  oCss.type="text/css";
  oCss.rel="stylesheet";
  var sheet, cssRules;
  if("sheet" in oCss) {
    sheet = "sheet";
    cssRules = "cssRules";
  } else {
    sheet = "styleSheet";
    cssRules = "rules";
  }
  var timeout_id = setInterval(function() {
                                 if(oCss[sheet] && oCss[sheet][cssRules].length ) {
                                   clearInterval(timeout_id);
                                   clearTimeout(timeout_id);
                                   oCallback();
                                 }
                               }, 10 );
  document.getElementsByTagName("head")[0].appendChild(oCss);
}
