$(function(){
    $(".on_air_button").each(function(){
        $(this).click(function(event){
            event.preventDefault();
            $(this).toggleClass("active");
            console.log($($(this).children("input")))
            input = $($(this).children("input"))
            input.prop("checked", !input.prop("checked"));
        })
    })
});
