var ampersand = '&themepath=AmericasViaOAAP/'
var qmark = '?themepath=AmericasViaOAAP/'

$(document).ready(function() {

    $("a[href*='?']:not([href^='http'][href^='javascript'])").each(function(){ 
        // In later versions of jquery, the things in the "not" need to be comma-separated instead of pegged together, e.g. :not([href...],[href...])
        // If jquery is updated, but this isn't changed, the links to the JP2 images will probably stop working.
        this.href += ampersand;
    });
    $("a[href^='/']:not([href*='?'])").each(function(){
        this.href += qmark;
    });
    $("form[action^='/']").bind('submit', function(){
        this.action += qmark;
    });

});
