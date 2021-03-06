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
import {Presence} from "phoenix"
socket.connect()

// Now that you are connected, you can join channels with a topic:
let chatInput = $(".chat-input")
let messagesContainer = $("ul.chat")
let room_id = messagesContainer.data("id")
let room_topic = "channels:" + room_id
let guardianToken = $('meta[name="guardian_token"]').attr('content')
let channel = socket.channel(room_topic, {guardian_token: guardianToken})

let userList = $("#user-list")
let presences = {}

let listBy = (id, {metas: [first, ...rest]}) => {
  return first
}

let render_join = (presences) => {
  let result = Presence.list(presences, listBy)
    .map(function(user, index, arr) {
      $(`li#${user['id']} button`).addClass('btn-primary')
      // userList.remove(elem);
      // userList.append(elem);
    })
}

let render_leave = (presences) => {
  let result = Presence.list(presences, listBy)
    .map(function(user, index, arr) {
      $(`li#${user['id']} button`).removeClass('btn-primary')
    })
}

channel.on("presence_state", state => {
  presences = Presence.syncState(presences, state)
  render_join(presences)
})

channel.on("presence_diff", diff => {
  presences = Presence.syncDiff(presences, diff)
  render_leave(diff.leaves)
  render_join(diff.joins)
})


$('.panel-body').animate({ scrollTop: $(".panel-body")[0].scrollHeight}, "fast");




chatInput.on("keypress", event => {
  if (event.keyCode == 13) {
    if (!chatInput.val().replace(/\s/g, '').length == 0) {
      var type = $('.incognito').is(':checked') ? "secure" : "normal"
      sendMessage(channel, chatInput.val(), room_id, type)
    }
  }
})



channel.on("new_msg", payload => {
   messagesContainer.append(payload.message)
   $(".panel-body").animate({ scrollTop: $(".panel-body")[0].scrollHeight}, "slow");
   chatInput.val('')
})

channel.on("destroy_message", payload => {
  var elem = $("li[data-id='" + payload.message_id + "']");
  $(elem).animate({ "opacity" : "0"}, 1000, function(){$(elem).remove();});
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

channel.join()
  .receive("ok", resp => {
    $("ul.chat").scrollTop($("ul.chat")[0].scrollHeight);
  })
  .receive("error", resp => { console.log("Unable to join", resp) })


function sendMessage(channel, body, room_id, type) {
  $.ajax({
     type: "POST",
     url: "/messages",
     data: {
       _csrf_token: $('input[name="_csrf_token"]').val(),
       message: {
         body: body,
         room_id: room_id,
         generated: type == 'generated'
       },
       type: type
     },
     success: result => {
       channel.push("new_msg", result)
     },
     error: e => {
       console.log("ERROR")
       console.log(e)
     }
  })
}

export default socket
