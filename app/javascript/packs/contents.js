$(function(){
    $(".collapse-button").on("click", function() {
        $(this).toggleClass("on-click");
        if ($(this).hasClass('on-click')) {
            $(this).html("↑")
        } else {
            $(this).html("↓ Read More ↓")
        }
    });
});