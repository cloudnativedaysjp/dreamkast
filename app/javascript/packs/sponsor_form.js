$(document).on('click', '.add_pdf_fields', function(event) {
    var regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $('.pdf-fields').append($(this).data('fields').replace(regexp, time));
    if ($('div:visible.pdf-field').length >= 3) {
        $('.add-pdf').hide()
    }
    return event.preventDefault();
})

$(document).on('click', '.remove_pdf_field', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.pdf-field').hide();
    if ($('div:visible.pdf-field').length < 3) {
        $('.add-pdf').show()
    }
    return event.preventDefault();
});

$(document).on('click', '.add_key_image_fields', function(event) {
    var regexp, time;
    time = new Date().getTime();
    regexp = new RegExp($(this).data('id'), 'g');
    $('.key-image-fields').append($(this).data('fields').replace(regexp, time));
    if ($('div:visible.key-image-field').length >= 2) {
        $('.add-key-image').hide()
    }
    return event.preventDefault();
})

$(document).on('click', '.remove_key_image_field', function(event) {
    console.log('remove_key_image_field')
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.key-image-field').hide();
    if ($('div:visible.key-image-field').length < 2) {
        $('.add-key-image').show()
    }
    return event.preventDefault();
});
