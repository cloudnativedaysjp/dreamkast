$(function(){
    $(".on_air_button").each(function(){
        $(this).click(function(event){
            event.preventDefault();
            $(this).toggleClass("active");
            input = $($(this).children("input"))
            input.prop("checked", !input.prop("checked"));
            unchanged_alert($(this))
        })
    }),
    $("#talk_list").submit(check_tracks);
    $(".talk_list_form").submit(check_tracks);
});

unchanged_alert = function(elm) {
    day = elm.attr("day")
    track_number = elm.attr("track_number")
    day_track = day + '-' + track_number
    on_air_talks = get_on_air_talks(day, track_number)

    if (on_air_talks.length == 0) {
        if (window.foo[day_track] != "") {
            show_alert('変更があります')
        } else {
            delete_alert()
        }
    }
    if (on_air_talks.length == 1) {
        if (window.foo[day_track] != on_air_talks.attr("talk_id")) {
            show_alert('変更があります')
        } else {
            delete_alert()
        }
    }
    if (on_air_talks.length > 1) {
        show_alert('複数選択しています')
    }
}

show_alert = function(msg) {
    if ($("#unchanged-alert").length > 0) {
        $("#unchanged-alert").html(msg);
    } else {
        $("<div id=\"unchanged-alert\" class=\"alert alert-warning\" role=\"alert\">" + msg + "</div>").appendTo('#alert-pane')
    }
}

delete_alert = function() {
    $("#unchanged-alert").remove();
}

check_tracks = function() {
    delete_alert()
    day = $('#'+this.id).parent().attr('day')
    track_number = $('#'+this.id).parent().attr('track_number')
    window.foo[day+'-'+track_number] = get_current_talk(day, track_number)
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
}

get_current_talk = function(date, track_number) {
    let selector = '#nav-' + date + '-' + track_number
    if ($(selector).find('.on_air_button.active').length > 0) {
        return $(selector).find('.on_air_button.active')[0].attributes['talk_id'].value
    } else {
        return ""
    }
}

get_on_air_talks = function(date, track_number) {
    return $('#nav-'+date+'-'+track_number).find('.on_air_button.active')
}