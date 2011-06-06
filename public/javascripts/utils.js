function escape(text)
{
  return text.replace(/&/g, '&amp;')
             .replace(/</g, '&lt;')
             .replace(/>/g, '&gt;')
             .replace(/"/g, '&quot;');
}
function unescape(text)
{
  return text.replace(/&quot;/g, '"')
             .replace(/&lt;/g, '<')
             .replace(/&gt;/g, '>')
             .replace(/&amp;/g, '&');
}
function getDateString(date) {
  var m = parseInt(date.getUTCMonth()) + 1;
  m = m < 10 ? "0" + m : m;
  var d = date.getUTCDate() < 10 ? "0" + date.getDate() : date.getDate();
  var y = date.getFullYear();
  return m + "/" + d + "/" + y;
}
