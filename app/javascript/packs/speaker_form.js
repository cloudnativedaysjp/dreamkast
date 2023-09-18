$(document).on('click', '.add_talk_fields', function(event) {
    event.preventDefault();
    var regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $('.talk-fields').append($(this).data('fields').replace(regexp, time));
    if ($('div:visible.talk-field').length >= 3) {
        $('.add-talk').hide()
    }
    return false;
})

$(document).on('click', '.remove_talk_field', function(event) {
    event.preventDefault();
    if (confirm("このセッションを削除しますか？")) {
        $(this).parent().find('.destroy_flag_field').val(1)
        $(this).closest('.talk-field').hide();
        $(this).parent().find('input').removeAttr('required max min maxlength pattern');
        $(this).parent().find('textarea').removeAttr('required max min maxlength pattern');
        $(this).parent().find('select').removeAttr('required max min maxlength pattern');
        if ($('div:visible.talk-field').length < 3) {
            $('.add-talk').show()
        }
    }
    return false;
});



window.onload = function() {
　　document.getElementById('speaker_talks_attributes_0_talk_category_id').addEventListener('change', function(event) {
        console.log('changed');
        console.log($(this).attr('params'));
        if ($(this).attr('params') == 'Keynote') {
            $(".radio_button_session_times.20min").attr("disabled", false);
        } else {
            e = $(this).closest('div.talk-field').find(".radio_button_session_times.20min").first()
            e.prop('checked', false)
            e.attr("disabled", true);
        }
    });
}