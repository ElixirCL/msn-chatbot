function OnEvent_Initialize(MessengerStart){}
function OnEvent_Uninitialize(MessengerExit){}

function isMe(origin, type) {
  return !(origin != Messenger.MyName && type == 1);
}

function isGroupChat(chat) {
  return !(chat.Contacts.Count == 1);
}

function isEmpty(message) {
  return (message.substr(message.Length - 1, 1) == "﻿");
}

function email(chat) {
  var contacts = new Enumerator(chat.Contacts);
  return contacts.item().Email;
}

function get(url, callback) {
	var xhr = new ActiveXObject("Microsoft.XMLHTTP");
	xhr.open("GET", url, false);
	xhr.onreadystatechange = function() {
		if(xhr.readyState == 4) {
			return callback(xhr.responseText);
		}
		
		Debug.Trace(xhr);
	}
	xhr.send(null);
}

function request(origin, message, callback) {
    return get("http://localhost:3000?origin=" + encodeURIComponent(origin) + "&message=" + encodeURIComponent(message), callback);
}

function OnEvent_ChatWndReceiveMessage(chat, origin, message, type) {

     if(isMe(origin, type) || isGroupChat(chat) || isEmpty(message)) {
       return message;
     }
     
     request(email(chat), message, function(response) {
       chat.sendMessage(response);
     });
     
     return message;
}