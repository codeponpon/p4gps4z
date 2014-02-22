//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.metisMenu


$(function() {

 $('#side-menu').metisMenu();

 $(window).bind("load resize", function() {
    // console.log($(this).width())
    if ($(this).width() < 768) {
      $('div.sidebar-collapse').addClass('collapse');
    } else {
      $('div.sidebar-collapse').removeClass('collapse');
    }
  });

});