
/* VARIABLES

/*
An array of Javascript object of JPEGs in the file, each with the
properties size and url, as in
	o.size
	o.url
The app can then make user of these as necessary. For example,
could be used to display a service image if it was under 1 MB, etc
*/
var imageJpegArray = Array();

/**
* JQuery initialization routine
*/
$(document).ready(function() {
    initZoomableImage();

    //$("div.right img").jScale({ls:'200px'});
    initjQueryTools();
});

/**
 * initZoomable create a div that holds the large image (image_wrap).
 * The large image when clicked will use a modal that takes up the full screen.
 * To help with viewing multiple images, there is a carousel that contains thumbnails of all images
 * so that you can change the image you have in the viewer.
*/
function initZoomableImage() {
    if (imageJpegArray.length > 0) {
        var viewPort = "<div id=\"image_wrap\"><a id=\"anchor\" href=\"#\" class=\"thickbox\">" +
            "<img class=\"central_image\" alt=\"" + IMAGE_TITLE + "\" title=\"" + IMAGE_TITLE + "\" src=\"" + THEME_PATH + "images/blank.gif\" />" +
            "</a></div>";

        var totalHtml = viewPort;

        var containHtml = "<div class=\"scrollable\"><div class=\"items\"><div>";
        totalHtml += containHtml;

        for (var i = 0; i < imageJpegArray.length; i++) {
            totalHtml += processImage(imageJpegArray[i]);
        }

        var tailHtml = "</div></div></div>";
        totalHtml += tailHtml;
        $("#photos").prepend(totalHtml);
        if (imageJpegArray.length == 1) {
            $('div.scrollable').css('display', 'none');

        }
    }
}

function processImage(serviceImg)
{
    return "<img src =\""+serviceImg.url+"\" alt=\""+ serviceImg.title +"\" title=\""+ serviceImg.itemTitle + "\"/>";
}


function initjQueryTools() {

    $(".scrollable").scrollable();

    $(".items img").click(
        function() {
            // see if same thumb is being clicked
            if ($(this).hasClass("active")) {
                return;
            }

            // Currently assuming that thumbnail and full image use same url.
            var clickedImage = $(this);
            var url = clickedImage.attr("src");

            // get handle to element that wraps the image and make it semi-transparent
            var wrap = $("#image_wrap").fadeTo("medium", 0.5);

            var img = new Image();

            // call this function after it's loaded
            img.onload = function() {
                // make wrapper fully visible
                wrap.fadeTo("fast", 1);

                // change the image
                wrap.find("img").attr("src", url);

                //wrap.find('img').jScale({ls:'670px'});
                $('#anchor').attr("href", url);
                $('#anchor').attr("title", clickedImage.attr("title") + "<br/>Download: <a href=\"" + url + "\">" + clickedImage.attr("alt") + "</a>");
            };

            // begin loading the image
            img.src = url;

            // activate item
            $(".items img").removeClass("active");
            $(this).addClass("active");

        // when page loads simulate a "click" on the first image
        }).filter(":first").click();
}
