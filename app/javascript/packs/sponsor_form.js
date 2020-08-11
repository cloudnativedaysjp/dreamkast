$(document).on('click', '.add_pdf_fields', function(event) {
    add_field('pdf', 3);
    return event.preventDefault();
})

$(document).on('click', '.remove_pdf_field', function(event) {
    remove_field('pdf', 3);
    return event.preventDefault();
});

$(document).on('click', '.add_key_image_fields', function(event) {
    add_field('key-image', 2);
    return event.preventDefault();
})

$(document).on('click', '.remove_key_image_field', function(event) {
    remove_field('key-image', 2);
    return event.preventDefault();
});

function add_field(name, max) {
    let time = new Date().getTime();
    let regexp = new RegExp($(this).data('id'), 'g');
    $('.'+name+'fields').append($(this).data('fields').replace(regexp, time));
    if ($('div:visible.'+name+'-field').length >= max) {
        $('.add-'+name+'pdf').hide()
    }
}

function remove_field(name, max) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.'+name+'-field').hide();
    if ($('div:visible.'+name+'-field').length < max) {
        $('.add-'+name).show()
    }
}