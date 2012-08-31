/*globals $ */

function listImages(collection, item) {
	// TODO: Check for an initialized datatable & if it exists, destroy it
	//Clear away any existing contents of the table in the DOM
	$('tbody#page-images').empty();
	// Hide the item selector div and display a modal dialogue while the appropriate page image links are retrieved
	$('#itemSelector').hide();
	$('#loading_modal').ajaxStart(function(){
		$(this).modal('show');
	});

	// Check to see if a partial manifest already exists
	var checkServer = $.ajax({
		type: "HEAD",
		url: "/metadata/manifests/" + item + ".xml"
	});
	// If a partial manifest exists, GET it and construct a table with the data returned
	checkServer.done(function() {
		var manifestPromise = $.ajax({
			type: "GET",
			url: "/metadata/manifests/" + item + ".xml",
			dataType: "xml"
		});
		// Create table rows with info retrieved from the server: filename | link to page image | label
		manifestPromise.done(function(xml) {
			// Set the name of the item as the title for the table
			$('#imageTable > h2').append(item);
			// Parse the XML returned by AJAX and build html strings with the data. Add them to the table
			$(xml).find("item").each(function(){
				var tdString = '<tr><td>'+$(this).children("filename").text()+'</td><td><a class="fancybox" href="http://sga.mith.org/images/derivatives/'+collection+'/'+$(this).children("filename").text()+'" target="_blank"><i class="icon-picture"></i></a></td><td class="editable">'+$(this).children("label").text()+'</td></tr>';
				$('#page-images').prepend(tdString);
			});
		});
		// Initialize jquery datatable from DOM table to add pagination, sorting, editing functionality
		manifestPromise.done(function() {
			// dataTable() takes an object with initialization parameters. See dataTable API
			var editableTable = $('#imageDataTable').dataTable({
				"bDestroy":true,
				"bStateSave": true,
				"sPaginationType": "full_numbers",
				"bAutoWidth": false
			});
			// Make the rows editable (this adds another dependency)
			$('td.editable', editableTable.fnGetNodes()).editable(function(value, settings) {
				var aPos = editableTable.fnGetPosition(this);
				editableTable.fnUpdate(value, aPos[0], aPos[1]);
			},
			{
				onblur : "submit"
			});
		});
		// Add an event handler to reset to item selection state
		$('#prev-to-manifest button').one('click', function() {
			// Hide the table, deactivate save, tear down data tables functionality & empty the table
			$('#imageTable').hide();
			$('#jsSave').off();
			$('#imageDataTable').dataTable().fnDestroy();
			$('tbody#page-images').empty();
			$('#imageTable > h2').empty();
			// Run getItems again to get the item list
			getItems($('#select-repo option:selected').attr('value'));
		});

		// When everything is constructed, add save handler, show the div with the table and clear the modal dialogue
		manifestPromise.done(function() {
			$('#jsSave').on("click", function(){
				saveManifest();
			});
			$('#imageTable').show();
			$('#loading_modal').ajaxStop(function(){
				$(this).modal('hide');
			});
		});
	}); // End of manifest exists block

	// If no manifest exists, GET the listing from the sga.mith.org/images directory & build the table from that
	checkServer.fail(function() {
		var remoteDirPromise = $.ajax({
			type: "GET",
			url: "/metadata/xq/image_getter.xquery?coll-id="+collection+"&item="+item,
			dataType: "xml"
		});
		remoteDirPromise.done(function(xml){
			$('#imageTable > h2').append(item);
			$(xml).find("a").each(function(){
				var tdString = '<tr><td>'+$(this).text()+'</td><td><a href="http://sga.mith.org/images/derivatives/'+collection+'/'+$(this).text()+'" target="_blank"><i class="icon-picture"></i></a></td><td class="editable">&#x20;</td></tr>';
				$('#page-images').prepend(tdString);
			});
		});
		remoteDirPromise.done(function() {
			// dataTable() takes an object with initialization parameters. See dataTable API
			var editableTable = $('#imageDataTable').dataTable({
				"bDestroy":true,
				"bStateSave": true,
				"sPaginationType": "full_numbers",
				"bAutoWidth": false
			});
			// Make the rows editable (this adds another dependency)
			$('td.editable', editableTable.fnGetNodes()).editable(function(value, settings) {
				var aPos = editableTable.fnGetPosition(this);
				editableTable.fnUpdate(value, aPos[0], aPos[1]);
			},
			{
				onblur : "submit"
			});
		});
		// Add an event handler to reset to item selection state
		$('#prev-to-manifest button').one('click', function() {
			// Hide the table, deactivate save, tear down data tables functionality & empty the table
			$('#imageTable').hide();
			$('#jsSave').off();
			$('#imageDataTable').dataTable().fnDestroy();
			$('tbody#page-images').empty();
			$('#imageTable > h2').empty();
			// Run getItems again to get the item list
			getItems($('#select-repo option:selected').attr('value'));
		});

		// When everything is constructed, add save handler, show the div with the table and clear the modal dialogue
		remoteDirPromise.done(function() {
			$('#jsSave').on("click", function(){
				saveManifest();
			});
			$('#imageTable').show();
			$('#loading_modal').ajaxStop(function(){
				$(this).modal('hide');
			});
		});

	}); // End of manifest does not exist block
}

function getItems(param) {
	"use strict";
	$('#ajax-loader').ajaxStart(function () {
    	$(this).show();
    	// Make sure the list of items is empty
    	if ($('#ajax-file-manifest').children().length !== 0) {
    		$('#ajax-file-manifest').empty();
    	}
    });
	var getItemPromise = $.ajax({
		type: 'GET',
		url: '/metadata/xq/dir_parser.xquery?coll-id=' + param,
		dataType: 'xml',
		timeout: 30000
	});	
	getItemPromise.done(function(xml) {
        if($(xml).find('error').length !== 0) {
            var errorMsg = '<div class="alert alert-error fade in"><a class="close" data-dismiss="alert" href="#">×</a><strong>'+$(xml).find('error').text()+'</strong> Please make sure the correct holdings information has been selected. [HTTP status code '+$(xml).find('error').attr('http-status-code')+']</div>';
           $('.container').prepend(errorMsg);
           $(".alert").alert();
           // $('#next-to-manifest button').on("click", function() {
           //          window.getItems($('#institution-code .xforms-value').text());
           //      });
        }
        else {
        var arr = [];
        $(xml).find("a").each(function () {
            arr.push($(this).attr("href"));
        });
        arr.shift();
        var all_items = $.map(arr, function(n){
            return n.split("-")[1];
        });
        var i,
            len = all_items.length,
            out = [],
            obj = {};
        for (i=0;i < len; i++){
            obj[all_items[i]] = 0;
        }
        for (i in obj){
            out.push(i);
        }
        $.map(out, function(val){
            return $('#ajax-file-manifest').prepend('<li id="'+val+'" class="sga-item"><a href="#">'+ val + '</a></li>' );
        });
    }
    });
	// Create an event listener on each li in the newly-created list of items
	getItemPromise.done(function () {
		$('.sga-item').on('click', 'a', function() {
			listImages($('#select-repo option:selected').attr('value'), $(this).parent().attr('id'));
			});
	});
	// Clean-up and show the list of items returned
	getItemPromise.done(function() {
		// Don't show an empty list
		if ($('#ajax-file-manifest').children().length !== 0) {
			// Disable the library selector --- don't want to change collections now that we have items
			$('#itemSelector').show();
			$('#select-repo select').attr('disabled', 'disabled');
			/* Unload the event listener on the image manifest button
			Don't want to fetch items again unless the load action fails */
			$('#next-to-manifest button').off();
		} else {
			// Need some error catching here
		}
		$('#ajax-loader').ajaxStop(function() {
			$(this).hide()
			});
	});
}

function setImageEventListener() {
	"use strict";
// Add event listener for image manifest section
    $('#next-to-manifest button').on("click", function () {
    window.getItems($('#select-repo option:selected').attr('value'));
});
}

function saveManifest() {
    var xmlString = '<?xml version="1.0" encoding="UTF-8"?><items>';
    var data = $('#imageDataTable').dataTable().fnGetData();
    $.each(data, function(index, value){
        xmlString += '<item id="'+ $('#imageTable > h2').text()+'"><filename>'+value[0]+'</filename><label>'+value[2]+'</label></item>';
    });
    xmlString += '</items>';
    var savePromise = $.ajax({
        type: "PUT",
        url: "/metadata/manifests/"+$('#itemID').text()+".xml",
        contentType: "application/xml",
        data: xmlString
    });
    savePromise.done(function(){
         var saveMsg = '<div class="alert alert-success fade in"><a class="close" data-dismiss="alert" href="#">×</a>Saved!</div>';
         $('#msgPlaceHolder').append(saveMsg);
         $(".alert").alert();
         window.setTimeout(function() { $(".alert-success").alert('close'); }, 2000);
    });
}


$(document).ready(
    function () {
        "use strict";

        // Do some basic re-styling of the page---for aesthetic reasons only
        $("div.container").css("margin-top", "40px");
        $("textarea.xforms-value").addClass('input-xlarge').css('height', '150px');

        // Add classes to use Twitter bootstrap
        $("button").addClass('btn');
        $(".navbar button").addClass("btn-inverse");
        // Emphasize certain buttons
        $("#img-to-finish button").addClass("btn-large btn-success");
        $("#next-to-manifest button").addClass("btn-primary btn-large");
        $("#surrogate-to-finish button").addClass("btn-large btn-success");
        $('.xforms-submit button').addClass('btn btn-primary btn-large');

        // Substitute attractive Twitter bootstrap + FontAwesome tooltips for ugly XSLTForms ones
        $(".xforms-required-icon").replaceWith('<span class="xforms-required-icon"><i class="icon-asterisk icon-large"></i></span>');
        $(".xforms-alert-icon").replaceWith('<i class="icon-remove-sign icon-large"></i>');
        // Tweak the display of the new icons
        $(".icon-large").css("display", "inline");
        // Activate the tooltip function on links
        $("a").popover();

        // Add placeholder text to the form
        $("#main-title input").attr("placeholder", "e.g., Frankenstein Notebook A");
        $("#creation-date input").attr("placeholder", "e.g., 1815");
        $("#item-label textarea").attr("placeholder", "Fragment of manuscript of Frankenstein (1818) (Draft Notebook A) containing parts of chapters 3-14 (plus further chapters unidentified)");
        $("#lib-collection input").attr("placeholder", "The Abinger Papers, 1780-1937");
        $("#lib-idno input").attr("placeholder", "MS. Abinger c. 56 ");
        $("#physical-extent input").attr("placeholder", "163 leaves");
        $("#physical-support textarea").attr("placeholder", "Paper with watermark: anchor in a circle with star on top, countermark B-B with trefoil similar to Moschin, Anchor N 1680, 1570-1585.");
        $("#foliation-orig textarea").attr("placeholder", "Folio numbers were added in brown ink ca. 1720-1730 in the upper right corner of all recto-pages.");
        $('#physical-condition textarea').attr("placeholder", "The manuscript shows signs of damage from water and mould on its outermost leaves.");
        $("#manu-hands textarea").attr("placeholder", "The manuscript is written in two contemporary hands. Hand I writes ff. 1r-22v and hand II ff. 23 and 24.");
        $("#metadata-creator input").attr("placeholder", "Liz Denlinger");
        $("#source textarea").attr("placeholder", "Oxford, Bodleian Library, Finding aid for MS. Abinger c. 56");
        $("#surrogate1 textarea").attr("placeholder", "Shelley, Mary W, and Charles E. Robinson. The Frankenstein Notebooks. New York: Garland Pub, 1996. Print.");
        $("#who input").attr("placeholder", "Charles Carter");
        $("#revision textarea").attr("placeholder", "Added more detailed information about hands");
        $("#change-repeat input").attr("placeholder", "Click to edit");

        // Hide elements that will be used later for AJAX functionality
        $('#itemSelector').hide();
        $('#imageTable').hide();
        $('#ajax-loader').hide();

        $(".fancybox").fancybox();
        setImageEventListener();
    }
);

$(window).load(function() {
// If not a blank form (loading existing data), disable the repository selector
        if(location.pathname.search(/edit/) !== -1) {
            $('#select-repo select').attr('disabled', 'disabled');
        }
});