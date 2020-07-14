console.log("opened");
$(function(){
    $('.talk .radio input:radio').click(function(){
        $('.content[day_slot=' + $(this).attr('day_slot') + ']').removeClass('checked');
        $('.content[talk_number=' + $(this).attr('talk_number') + ']').addClass('checked');
    });
})
