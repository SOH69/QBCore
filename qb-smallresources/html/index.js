$(document).ready(function() {
    window.addEventListener('message', function(event){
        let eData = event.data;
        switch (eData.action) {
            case 'open':
                $('#cover').fadeIn(1000);
                break;
            case 'close':
                $('#cover').fadeOut(1000);
                break;
        }
    })
});