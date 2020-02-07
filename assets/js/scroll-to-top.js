

$(window).scroll(function() {
  if ($(this).scrollTop() > 50 ) {
    $('.scroll-to-top:hidden').stop(true, true).fadeIn();
  } else {
    $('.scroll-to-top').stop(true, true).fadeOut();
  }
});
$(function(){
  $(".scroll").click(function(){
    $("html,body").animate({ scrollTop: $(".the-top").offset().top }, "1000");
    return false;
  })
})