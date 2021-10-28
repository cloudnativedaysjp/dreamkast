// $(function(){
//   $(".on_air_button").each(function(){
//     $(this).click(function(event){
//       button = $(this)[0]
//       console.log('clicked')
//       event.preventDefault();
//
//       isActive = $(this).prop('class').includes(' active ')
//       button.toggleClass("active");
//
//       a = {
//         talk_id: button.attributes['talk_id'].value
//       }
//       if (isActive) {
//         a['action'] = 'start_on_air'
//       } else {
//         a['action'] = 'stop_on_air'
//       }
//       form = button.closest(".talk_list_form")
//       console.log(form)
//       form.closest(".talk_list_form").submit(a);
//
//     })
//   })
// });

// check_tracks = function() {
//     found = []
//     has_error = false
//     $(".on_air_button input:checked").each(function(){
//         if(found.indexOf(this.attributes["track_name"].value) === -1){
//             found.push(this.attributes["track_name"].value);
//         }else{
//             has_error = true;
//             alert("トラックが重複しています");
//         }
//     });
//     if(has_error){
//         return false;
//     }
// }