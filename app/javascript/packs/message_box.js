$(function(){
    $(document).on("click","#message_icon", function(){
        //var clickEventType = (( window.ontouchstart!==null ) ? 'click':'touchend');
        $("#message_box").toggleClass("d-none");
    });
})