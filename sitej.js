importinto($dom);
importinto(dom);

function refresh() {
    console.log("refreshing...");
    $byq("nav").rmclass("shown");
    $byid("content").rmclass("shown");
    $byid("hr").rmclass("hidden");
    var section=document.URL.split("#")[1];
    if (!section) {
        $byid("top").addclass("shown");
    } else if (section.match(/^words/) || section.match(/^work/)) {
        $byid("hr").addclass("hidden");
    } else if ($byid(section)){
        if ($byq("#words #"+section)) {
            window.location.href="#words";
            setTimeout(function(){
                $byid("hr").addclass("hidden");
                loadcontent($byid(section).attr("href"), true);
            }, 500);
        }
    }
}
function getwordstags(){
    var words = $byqs("#words ul li");
    console.log(words);
}
/*a bunch of dirty hacks for javascript
  enabled browsers*/
function firsthacks(){
    $byqs("#words li a").forEach(function(c){
        var href = c.attr("href");
        c.evlis("click",function(e){
            e.preventDefault();
            e.stopPropagation();
            loadcontent(href,true);//for now, just enable embeds because I'm tired of hacking on this.
        })
    });
}
function init() {
    firsthacks();
    refresh();
    //is this still needed
    $byq("nav").evlis(
	    "click", function(e) {
            var div;
            if (e.target.tagName === "A") {
                div = e.target.parentElement;
                rmclass(div,"shown");
                if (e.target.href) {
                    var section = e.target.href.split("#")[1];
                    if (section ==="work" || section ==="words")
                        $byid("hr").addclass("hidden");
                }
            }
        }
    );
}


function words() {
    $byq("nav").prune();
    $byid("content").prune().rmclass("shown");
    $byid("sidenav").addclass("shown");
    $byid("hr").addclass("hidden");
    console.log("I am ever called");
}

function getfile(url, f){
    request(
        url,"","GET",
        {overrideMimeType:"text/plain; charset=utf-8"}
    ).then(f);
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
        instgrm.Embeds.process();
    }
}
