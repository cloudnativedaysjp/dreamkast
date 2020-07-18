$(function(){
    $(document).on("click","#message_icon", function(){
        $("#message_box").toggleClass("d-none");
    });
    $(window).scroll(function() {
        $("#message_box").addClass("d-none");
    });
    $(window).touchmove(function() {
        $("#message_box").addClass("d-none");
    });
})