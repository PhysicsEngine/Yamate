function counterRefresh (count) {
  $("#user-counter").val(count);
}

function appendMessage (userid, message) {
  $("#message-box").append("<div class='message'><span class='user-id'>" + userid + ":</span> " + message + "</div>");
}

$("#count-button").click(function(event) {
  var text = this.innerHTML;
  var data = JSON.stringify({ userid: myid, text: text });
  ws.send(data);
});

var myid;

var ws = new WebSocket(location.origin.replace(/^http/, 'ws'));

ws.onmessage = function(msg) {
  var data = JSON.parse(msg.data);
  if (data.you) { myid = data.you; }
  else if (data.text) {
    var id;
    myid==data.userid ? id = 'my-message' : id = data.userid;
    appendMessage(id, data.text);
  }
  else if (data.count) { counterRefresh(data.count); }
}
