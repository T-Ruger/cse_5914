$(function() {
  $('[data-channel-subscribe="room"]').each(function(index, element) {
    var $element = $(element),
        room_id = $element.data('room-id')
        messageTemplate = $('[data-role="message-template"]');
        watsonMessageTemplate = $('[data-role="watson-message-template"]');

    $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000)        

    App.cable.subscriptions.create(
      {
        channel: "RoomChannel",
        room: room_id
      },
      {
        received: function(data) {
        console.log(data.params)
        //write messages to chat
        	if(!data.watsonmsg){
		        var content = messageTemplate.children().clone(true, true);
		        content.find('[data-role="user-avatar"]').attr('src', data.user_avatar_url);
		        content.find('[data-role="message-text"]').text(data.message);
		        $element.append(content);
		        $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000);
          }else{
          	var content = watsonMessageTemplate.children().clone(true, true);
		        content.find('[data-role="user-avatar"]').attr('src', data.user_avatar_url);
		        content.find('[data-role="message-text"]').text(data.message);
		        $element.append(content);
		        $element.animate({ scrollTop: $element.prop("scrollHeight")}, 1000);
		        
		        //build attribute hash
		        var m = new Map();
		        var json = JSON.parse(data.params)
		        for (var k in json) m.set(k, json[k])
		        
		        //send hash to updateList
				    updateList(m);
				    console.log(m)
          }
        }
      }
    );
  });
});
