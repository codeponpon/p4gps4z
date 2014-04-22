//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.metisMenu
//= require jquery.maskedinput


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

 var checkout_form = $('#checkout-form');
 checkout_form.find('#card_number').mask('9999 9999 9999 9999');
 checkout_form.find('#ccv2').mask('999');
 checkout_form.find('#expire_year').mask('9999');

});