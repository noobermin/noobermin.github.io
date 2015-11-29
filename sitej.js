importinto($dom);
importinto(dom);
function $mklink(id,text,url) {
    var r = $mkel("a",{id:id},"",text);
    url && r.attr("href",url);
    return r;
}
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
        c.attr("href","").evlis("click",function(e){
            e.preventDefault();
            loadcontent(href,true);//for now, just enable embeds because I'm tired of hacking on this.
        })
    });
}
function init() {
    firsthacks();
    refresh();
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
    $byq("nav").prune();
    $byid("content").prune().rmclass("shown");
    $byid("sidenav").addclass("shown");
    $byid("hr").addclass("hidden");
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
