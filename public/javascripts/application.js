// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$('.submittable').live('change', function() {
  $(this).parents('form:first').submit();
});


$('.reply_link').bind('ajax:success', function(){
    $(this).append("<%= render(:partial => 'shared/comment_form') %>");
});