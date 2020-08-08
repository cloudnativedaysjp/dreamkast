$(function(){
    $(".on_air_button").each(function(){
        $(this).click(function(event){
            event.preventDefault();
            $(this).toggleClass("active");
        })
    })
});

// document.querySelectorAll('.on_air_button').forEach(function(button){

//     button.addEventListener("click", (event) => {
//         console.log("pressed");

//         
//     })
// })