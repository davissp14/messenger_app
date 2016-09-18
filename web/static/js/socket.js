// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let chatInput = $(".chat-input")
let messagesContainer = $("ul.chat")
let room_id = messagesContainer.data("id")

let room_topic = "channels:" + room_id
let guardianToken = $('meta[name="guardian_token"]').attr('content')

let channel = socket.channel(room_topic, {guardian_token: guardianToken})

chatInput.on("keypress", event => {
  if (event.keyCode == 13) {
    if (!chatInput.val().replace(/\s/g, '').length == 0) {
      $.ajax({
         type: "POST",
         url: "/messages",
         data: {
           _csrf_token: $('input[name="_csrf_token"]').val(),
           message: {
             body: chatInput.val(),
             room_id: room_id,
             incognito: $('.incognito').is(':checked')
           }
         },
         success: e => {
           messagesContainer.append(e["message"])
           $("ul.chat").animate({ scrollTop: $("ul.chat")[0].scrollHeight}, "slow");
         },
         error: e => {
           console.log("ERROR")
           console.log(e)
          //  alert.text(e.responseJSON["message"])
          //  alert.show()
         }
       })



       // channel.push("new_msg", {
       //   body: chatInput.val(), room_id: room_id, incognito: incognito
       // })
      // let incognito = $('.incognito').is(':checked');
      // channel.push("new_msg", {
      //   body: chatInput.val(), room_id: room_id, incognito: incognito
      // })
      // chatInput.val("")
    }
  }
})

channel.on("destroy_message", payload => {
  var elem = $("li[data-id='" + payload.message_id + "']");
  $(elem).animate({ "opacity" : "0"}, 1000, function(){$(elem).remove();});
})

channel.on("new_msg", payload => {
  if (payload.incognito == true) {
    renderSecretMessage(payload)
  } else {
    renderMessage(payload)
  }
  $("ul.chat").animate({ scrollTop: $("ul.chat")[0].scrollHeight}, "slow");
})

channel.on("member_joined", payload => {
  var elem = $('li#' + payload.user_id + " button")
  $(elem).removeClass('btn-secondary')
  $(elem).addClass('btn-success')
})

channel.on("member_leave", payload => {
  var elem = $('li#' + payload.user_id + " button")
  $(elem).removeClass('btn-success')
  $(elem).addClass('btn-secondary')
})

function renderMessage(message) {
  var name = sanitize(message.name)
  var body = urlify(sanitize(message.body))
  var image = message.image + '?s=40'
  var timestamp = message.time

  $("ul.chat").append(`
    <li class="left clearfix">
      <span class="chat-img pull-left">
        <img src=${image} alt="User Avatar" />
      </span>
      <div class="chat-body clearfix">
        <div class="header">
          <strong class="primary-font">${name}</strong>
          <small class="chat-time text-muted">
            ${timestamp}
          </small>
        </div>
        <p>
          ${body}
        </p>
     </div>
  </li>
`)
}

function renderSecretMessage(message) {
  var name = sanitize(message.name)
  var body = urlify(sanitize(message.body))
  var image = message.image + '?s=40'
  var timestamp = message.time
  var temp_id = message.temp_id

  $("ul.chat").append(`
    <li class="left clearfix snap" data-id=${temp_id}>
      <span class="chat-img pull-left">
        <img src=${image} alt="User Avatar" />
      </span>
      <div class="chat-body clearfix">
        <div class="header">
          <strong class="primary-font">${name}</strong>
          <small class="chat-time text-muted">
            ${timestamp}
          </small>
        </div>
        <p>
          ${body}
        </p>
     </div>
  </li>
`)
}

function urlify(text) {
    var urlRegex = /((?:(http|https|Http|Https|rtsp|Rtsp):\/\/(?:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,64}(?:\:(?:[a-zA-Z0-9\$\-\_\.\+\!\*\'\(\)\,\;\?\&\=]|(?:\%[a-fA-F0-9]{2})){1,25})?\@)?)?((?:(?:[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}\.)+(?:(?:aero|arpa|asia|a[cdefgilmnoqrstuwxz])|(?:biz|b[abdefghijmnorstvwyz])|(?:cat|com|coop|c[acdfghiklmnoruvxyz])|d[ejkmoz]|(?:edu|e[cegrstu])|f[ijkmor]|(?:gov|g[abdefghilmnpqrstuwy])|h[kmnrtu]|(?:info|int|i[delmnoqrst])|(?:jobs|j[emop])|k[eghimnrwyz]|l[abcikrstuvy]|(?:mil|mobi|museum|m[acdghklmnopqrstuvwxyz])|(?:name|net|n[acefgilopruz])|(?:org|om)|(?:pro|p[aefghklmnrstwy])|qa|r[eouw]|s[abcdeghijklmnortuvyz]|(?:tel|travel|t[cdfghjklmnoprtvwz])|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw]))|(?:(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9])\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[1-9]|0)\.(?:25[0-5]|2[0-4][0-9]|[0-1][0-9]{2}|[1-9][0-9]|[0-9])))(?:\:\d{1,5})?)(\/(?:(?:[a-zA-Z0-9\;\/\?\:\@\&\=\#\~\-\.\+\!\*\'\(\)\,\_])|(?:\%[a-fA-F0-9]{2}))*)?(?:\b|$)/gi
    return text.replace(urlRegex, function(url) {
        return '<a href="' + url + '" target="_blank">' + url + '</a>';
    })
}

function sanitize(str) { return $('<div />').text(str).html() }

$("ul.chat").animate({ scrollTop: $("ul.chat")[0].scrollHeight}, "fast");

channel.join()
  .receive("ok", resp => {
    $("ul.chat").scrollTop($("ul.chat")[0].scrollHeight);
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

export default socket
