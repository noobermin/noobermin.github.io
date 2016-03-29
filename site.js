importinto($dom);
importinto(dom);
importinto(ani);

var words = words || null;
var me = me || null;

function restore_top(){
    if (hasclass($byid("top"),"shown")) return;
    $byid("top").rmclass("minimized").addclass("shown");
    words.hide();
    me.hide();
}


function refresh() {
    console.log("refreshing...");
    $byq("nav").rmclass("shown");
    $byid("content").rmclass("shown");
    var section=document.URL.split("#")[1];
    if (!section) {
        restore_top();
    } else if (section.match(/^words/)){
        words.show();
    } else if (section.match(/^me/)){
        me.show();
    } else {
        words.load(section);
        /*setTimeout(function(){
           window.location.href="#"+section;
           $byid("hr").addclass("hidden");
           loadcontent(href, true);
           }, 500);*/
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
            succ(
                  0,function(){
                    $byq("#words").addclass("transitout");},
                300,function(){
                    //for now, just enable embeds because I'm tired of hacking on this.
                    $byq("#words").rmclass("shown","transitout");
                    loadcontent(href,true);
                });
        })
    });
}
function open(){
    $byq("div#main").addclass("shown");
}
function init() {
    firsthacks();
    words=(function(_i){
        if (_i) return;
        var words = $byid("words");
        var main  = $byid("main");
        words.show = function(){
            words.addclass("shown");
            main.addclass("shown");
        }
        words.hide = function(){
            words.rmclass("shown");
            main.rmclass("shown");
        }
        words.load = function(id){
            if (byq("#words #"+id)) {
                window.location.href="#words";//will call words.show()
                var href = $byid(id).attr("href");
                loadcontent(href, true);
            }
        }
        return words;
    })(words);
    
    me = (function(_i){
        var me = $byid("me");
        me.show = function(){
            me.addclass("shown");
        }
        me.hide = function(){
            me.rmclass("shown");
        }
        return me;
    })(me);
    
    refresh();
    //is this still needed
    var top  = $byid("top");
    $byq("#wordslink").evlis(
        'click',function(e){
            if (hasclass(top,"shown")) {
                top.rmclass("shown").addclass("minimized");
                words.show();
            } else if ($byid("content").hasclass("shown")){
                window.location.href="#words";
            } else if (top.hasclass("minimized")) {
                restore_top();
            }
        });
    $byq("#melink").evlis('click',function(e){
        if(hasclass(top,"shown")) {
            top.rmclass("shown").addclass("minimized");
            me.show();
        } else if ($byid("content").hasclass("shown")){
            window.location.href="#words";
        } else if (hasclass(top,"minimized")) {
            restore_top(); }});
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
    $byid("content").inner(
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
