(document).on('click', '.remove_link_field', function(event) {
    $(this).prev('input[type=hidden]').val('1');
    $(this).closest('.link-field').hide();
    return event.preventDefault();
})
