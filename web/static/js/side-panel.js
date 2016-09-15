
// Make navigation feel a bit quicker.
$('li.room').on('click', function(){
  $('li.room a.active').removeClass('active');
  $(this).find('a').addClass('active');
})
