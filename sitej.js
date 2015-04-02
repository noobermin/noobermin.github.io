function $mklink(id,text,url) {
    if (url) {
	return $mkel(
	    "a",{id:id, href:url},
	    "link",text);
    }
    return $mkel(
	"a",{id:id},
	"link",text
    );
}

function init() {
    console.log("started");
    $byid("hr").rmclass("hidden");
    $byid("sidenav").rmclass("shown");
    $byid("content").rmclass("shown");
    var nav = $byid("nav");
    nav.prune().append(
	$mklink("me","me."),
	$mklink("work","work."),
	$mklink("words","words.")
    ).addtempclass(
	"newlink",300
    ).evlis(
	"click", function(e) {
	    var id = idof(e.target);
	    if (id !== "me" && id !== "work" &&  id !== "words") return;
	    nav.addtempclass("transitout",200);
	    setTimeout(function(){
		if (id == "me") me();
		else if (id == "work") {
		    nav.prune();
		    nav.inner("You expect something here?");
		} else if (id == "words") words();
		nav.addtempclass("newlink",1000);
	    },200);
	}
    );
    //check url
    var section=document.URL.split("#")[1];

    if (section) {
	if (section.match(/^words--.*/)) {
	    section = section.replace(/^words--/,"");
	    var el = $byid(section);
	    if (el.el) {
		words();
		el.el.onclick();
	    }
	} else {
	    console.log("incorrect link \""+section+"\"");
	}
    }
}

function me(){
    var nav=$byid("nav");
    nav.prune().append(
	$mkel("p",{id:"pp"}).append(
	    $mklink(
		"1","1/","http://github.com/noobermin"
	    ),
	    $mklink(
		"2","2/","http://instagram.com/windywalk"
	    ),
	    $mklink(
		"3","3/","http://twitter.com/oneno_one"
	    )
	)
    );
}

function words() {
    $byid("nav").prune();
    $byid("sidenav").addclass("shown");
    $byid("hr").addclass("hidden");
}

function loadwords(url) {
    var xhr = mkxhr();
    xhr.onreadystatechange = function() {
	console.log("got response");
	if(xhr.readyState === 4 && xhr.status === 200)
	    writecontent(xhr.responseText);
    };
    xhr.open("GET",url,true);
    xhr.overrideMimeType("text/html; charset=utf-8");
    xhr.send();
}
function writecontent(text) {
    var content = $byid("content");
    content.inner(text);
    content.addclass("shown");
}


