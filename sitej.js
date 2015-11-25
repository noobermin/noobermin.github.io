importinto($dom);
importinto(dom);
function $mklink(id,text,url) {
    if (url) {
	    return $mkel(
	        "a",{id:id, href:url},
	        "",text
        );
    }
    return $mkel(
	    "a",{id:id},
	    "",text
    );
}
function refresh() {
    console.log("refreshing...");
    //$byid("sidenav").rmclass("shown");
    $byid("content").rmclass("shown");
    $byid("hr").rmclass("hidden");
    var section=document.URL.split("#")[1];
    if (!section) {
        $byid("top").addclass("shown");
    } else if (section.match(/^words/) || section.match(/^work/)) {
        $byid("hr").addclass("hidden");
    }
}
function init() {
    console.log("started");
    refresh();
    var nav = $(document.getElementsByTagName("nav")[0]);
    nav.evlis(
	    "click", function(e) {
	        var id = idof(e.target);
            var div;
            if (e.target.tagName === "A") {
                div = e.target.parentElement;
                rmclass(div,"shown");
                //hack for now
                console.log(e.target.href);
                if (e.target.href) {
                    var section = e.target.href.split("#")[1];
                    if (section ==="work" || section ==="words")
                        $byid("hr").addclass("hidden");
                }
            }
        }
    );
    return;
    /* fix this.
    var section=document.URL.split("#")[1];
    
    if (section) {
	    if (section.match(/^words--.)) {
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
    */
}


function words() {
    $byid("nav").prune();
    $byid("content").prune().rmclass("shown");
    $byid("sidenav").addclass("shown");
    $byid("hr").addclass("hidden");
}

function getfile(url, f){
    var xhr = mkxhr();
    xhr.onreadystatechange = function() {
	    console.log("got response");
	    if(xhr.readyState === 4)
	        f(xhr.responseText);
    };
    console.log(document.domain);
    xhr.open("GET",url,true);
    xhr.overrideMimeType("text/plain; charset=utf-8");
    xhr.send();
}

function loadcontent(url,instagram) {
    getfile(url,function(text){writecontent(text,instagram);});
}

function writecontent(text,instagram) {
    var content = $byid("content");
    content.inner(
	    text
    ).append(
	    $mkel(
	        "span",{id:"content-x"},"content-x","⊗"
	    ).evlis(
	        "click",function(){
                $byid("content").prune().rmclass("shown");
            }
	    )
    ).addclass(
	    "shown"
    );
    if (instagram) {
        console.log("holla");
        instgrm.Embeds.process();
    }
}
