$(function() {
	// Expand Panel
	$("#open").click(function(){
		$("div#panel").slideDown("slow");
    $('#sbLogo').hide();
	});	
	
	// Collapse Panel
	$("#close").click(function(){
		$("div#panel").slideUp("slow");
    $('#sbLogo').show();
	});		
	
	// Switch buttons from "Log In | Register" to "Close Panel" on click
	$("#togglePanel a").click(function () {
		$("#togglePanel a").toggle();
	});
		
});