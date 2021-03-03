jQuery(document).ready(function($){
console.log("prod")
	$(".status").click(function(e) {
		if($(this).text()=="Available"){
			$(this).text("Unvailable");
		}
		else{
			$(this).text("Available");
		}
	});
});//end of jq
