$(document).ready(function() {

    // Create mailto link for contact information
    var url = "mai";
    url += "lto:dl";
    url += "i@r";
    url += "ice.edu";
    $(".contact-us").attr("href",url);

    // Create collapsable divs for certain metadata fields and other toggleables
    $('div.hiddenvalue').hide();
    $('span.show-hide').show();
    $('div.hiddenfield').click(function() {
        $(this).parent().next().find("div").slideToggle('fast');
        $(this).find("span.hide").toggle();
        $(this).find("span.show").toggle();
    });

    // For metadata tables, set the even/odd classes here instead of bothering with a bunch of nasty XSL.
    $(".ds-includeSet-table tr:odd").addClass("odd");
    $(".ds-includeSet-table tr:even").addClass("even");

    // Change style if we're not on production
	if (location.href.indexOf('dspacetest') > 0) {
	    $("h1.primary-header").css({'background-image' : 'url(/themes/Rice/images/dspacetest-background.png)'});
	}
	if (location.href.indexOf('dspacedev') > 0) {
	    $("h1.primary-header").css({'background-image' : 'url(/themes/Rice/images/dspacedev-background.png)'});
	}

	if (window.location.hash == '#collapseBrowse' && window.location.href.replace(window.location.hash,'').indexOf("browse") != -1) {
		collapseBrowseControls();
	}
});




function collapseBrowseControls() {
	$("#ds-trail").hide();
	$("#ds-options").hide();
	$("#context-browse-search").hide();
	$("#aspect_artifactbrowser_ConfigurableBrowse_div_browse-navigation").hide();
	$("#aspect_artifactbrowser_ConfigurableBrowse_div_browse-controls").hide();
	$("#ds-body").css("margin-left","0px");
	$("#rice-main").css("background-image","url()");
	
	// modify all body links to preserve collapsed state
	$("#ds-body a").attr('href', function(h) {
		return $(this).attr('href')+'#collapseBrowse';
	});

	// add link to turn controls back on
	var link = $("<a id=\"browse-restore\" href=\""+window.location.href.replace(window.location.hash,'')+"\">Show full browse controls</a>");
	$(".pagination.top").after(link);
}

function showJPEG2000Viewer(bitstreamurl){
    var bits = bitstreamurl.split(/\?/);
    if(bits!= null){
	bitstreamurl = bits[0];
    }
    var url = document.location.href;
    var baseurl = "";

    if (url != null){
    var proto = window.location.protocol;
	var ss = url.split(/\//);
	var ss1 = ss[1];
	var ss2 = ss[2];
	if((ss[1] != null) && (ss[1].indexOf('rice.edu') > 0)){
	    baseurl = proto+'//' + ss1;

	}
	else {
	    if((ss[2] != null) && (ss[2].indexOf('rice.edu')>0)){
		baseurl = proto+'//' + ss2;
	    }
	}
    }
    var fullurl = baseurl + "/jp2/viewer.html?url=" + baseurl + bitstreamurl;
    window.location = fullurl;

}

// Ying added this for mp4 streaming
function getfullURL (bitstreamurl) {

    var server = "";
    if (location.href.indexOf('dspacetest') > 0) {
        server = "dspacetest";
    }else if((location.href.indexOf('dspacedev') > 0)) {
        server = "dspacedev";
    }else if((location.href.indexOf('dspaceland') > 0)) {
        server = "dspaceland";
    }else{

        server= "dspace";
    }

    return "http://"+server+".rice.edu/"+bitstreamurl;
}

function streamingIt(format, title, streamingfilename){

    //SERVER-SPECIFIC
    var uri = "";
    var server = "";
    if (location.href.indexOf('dspacetest') > 0) {
        server = "dspacetest";
    }else if((location.href.indexOf('dspacedev') > 0)) {
        server = "dspacedev";
    }else if((location.href.indexOf('dspaceland') > 0)) {
        server = "dspaceland";
    }else{

        server= "dspace";
    }

    if(format == 'win'){
	uri = "mms://wmdp.rice.edu/"+server+"/streaming/";
    }else if(format == 'real'){
        uri = "rtsp://rmdp.rice.edu/"+server+"/streaming/";
    }
    // var fullurl = "http://webcast.rice.edu/webcast.php?action=view&format=" + encodeURIComponent(format) + "&title=" + encodeURIComponent(title) + "&uri=" + encodeURIComponent(uri) + encodeURIComponent(streamingfilename);
    //--- var fullurl = "http://edtech.rice.edu/cms/?option=com_iwebcast&action=view&format=" + encodeURIComponent(format) + "&title=" + encodeURIComponent(title) + "&uri=" + encodeURIComponent(uri) + encodeURIComponent(streamingfilename);
    //var fullurl	= encodeURIComponent(uri) + encodeURIComponent(streamingfilename);
    var fullurl = uri + streamingfilename;

    window.open(fullurl, "CDS streaming");

}


/* 
Two search inputs (repository and context), with default helper text in each.  
If the user clicks in or tabs to an input, and the default text is there, replace it with nothing and let the user type in their own text.  
If the user leaves the input, replace it with the default text iff the user has left the input blank. 
*/

var valueRepository = '';
var valueContext = '';
var iterationRepository = 0;
var iterationContext = 0;

function removeLabel(input, context) {
  if (iterationRepository == 0 && !context) {
     valueRepository = input.value;
  }
  if (iterationContext == 0 && context) {
     valueContext = input.value;
  }
  if ((input.value == valueRepository && !context) || (input.value == valueContext && context)) {
    input.style.color = '#000000';
    input.value = '';
  }
  if (iterationRepository == 0 && !context) {
     iterationRepository = 1;
  }
  if (iterationContext == 0 && context) {
     iterationContext = 1;
  }
}
function resurrectLabel(input, context) {
  if (input.value == '' && !context) {
     input.value = valueRepository;
     input.style.color = '#999999'
  }
  if (input.value == '' && context) {
     input.value = valueContext;
     input.style.color = '#999999'
  }
}

//END  Ying added this for mp4 html5 streaming
