$(document).on('click', '.add_link_fields', function(event) {
    var regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $('.link-fields').append($(this).data('fields').replace(regexp, time));
    return event.preventDefault();
})

$(document).on('click', '.remove_link_field', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.link-field').hide();
    return event.preventDefault();
})