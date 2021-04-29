$(function () {

    function display(bool) {
        if (bool) {
            $("body").show();
        } else {
            $("body").hide();
        } 
    }
    
    display(false)
    
    
    window.addEventListener("message", function(event) {
        if (event.data.status == true) {
            display(true)
        } else {
            display(false)
        }
    })
    
    document.onkeyup = function (data) {
        if (data.which == 27) {
            $.post("http://WCCC/exit" , JSON.stringify({}));
            return;
        }
    }
    
    $(".close").click(function() {
        $.post("http://WCCC/exit" , JSON.stringify({}));
        return;
    })
    
    $("model").click(function() {
        let model = $("#model").val()
        $.post("https://WCCC/main", JSON.stringify({
            text: model
        }))
        return;
    })
    
})