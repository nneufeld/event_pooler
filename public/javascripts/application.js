// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$('.submittable').live('change', function() {
  $(this).parents('form:first').submit();
});

$(document).ready( function(){
    $('#send_message').hide();
    $('#user_ranking').hide();
});

$('#event_ends_at').live('focus', function() {
    if (this.value == '')
        this.value = $('#event_starts_at').val();
});

$(function(){
    $('#event_starts_at').datetimepicker({
	ampm: true
    });
});

$(function(){
    $('#event_ends_at').datetimepicker({
	ampm: true
    });
});