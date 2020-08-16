$(function(){
    $(".on_air_button").each(function(){
        $(this).click(function(event){
            event.preventDefault();
            $(this).toggleClass("active");
            input = $($(this).children("input"))
            input.prop("checked", !input.prop("checked"));
        })
    }),
    $("#talk_list").submit(function(){
        found = []
        has_error = false
        $(".on_air_button input:checked").each(function(){
            if(found.indexOf(this.attributes["track_name"].value) === -1){
                found.push(this.attributes["track_name"].value);
            }else{
                has_error = true;
                alert("トラックが重複しています");
            }
        });
        if(has_error){
            return false;
        }
    });
});
