$(function(){
    $(document).on("click","#message_icon", function(){
        $("#message_box").toggleClass("d-none");
    });
    $(window).scroll(function() {
        $("#message_box").addClass("d-none");
    });
    if ($(window).touchmove) {
        $(window).touchmove(function() {
            $("#message_box").addClass("d-none");
        });
    } else {
        $(window).mousemove(function() {
            $("#message_box").addClass("d-none");
        });
    }
})
