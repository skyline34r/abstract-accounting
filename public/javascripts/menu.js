var menuContent = "";
$(document).click(function(event) {
	switch(event.target.tagName) {
		case "PRE":
			if(($(event.target).parent().parent().attr("id") == "nav") &&
				($(event.target).html() != menuContent)) {
				$("#nav ul").css({display: "none"});
				$("#nav pre").removeClass("active");
				$(event.target).addClass("active");
				$(event.target).parent().children("ul").css({display: "block"});
				$("#sub-menu").css({display: "block"});
				menuContent = $(event.target).html();
			} else {
				$("#nav ul").css({display: "none"});
				$("#nav pre").removeClass("active");
				$("#sub-menu").css({display: "none"});
				menuContent = "";
			}
			break;
		case "A":
			if($(event.target).parent().parent().parent().parent().attr("id") == "nav") {
				$(event.target).parent().parent().parent().children("pre").addClass("active");
				$(event.target).parent().parent().css({display: "block"});
			} else {
				$("#nav ul").css({display: "none"});
				$("#nav pre").removeClass("active");
				$("#sub-menu").css({display: "none"});
				menuContent = "";
			}
			break;
		default:
			$("#nav ul").css({display: "none"});
			$("#nav pre").removeClass("active");
			$("#sub-menu").css({display: "none"});
			menuContent = "";
	}
});
