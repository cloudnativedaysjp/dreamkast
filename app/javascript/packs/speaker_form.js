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
