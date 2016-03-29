importinto($dom);
importinto(dom);
importinto(ani);

var page = page || null;

function refresh() {
    console.log("refreshing...");
    page.landing();
    var section=document.URL.split("#")[1];
    if (!section) {
        return;
    } else if (section.match(/^words/)){
        page.words();
    } else if (section.match(/^me/)){
        page.me();
    } else {
        page.load(section);
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
        c.evlis("click",function(e){
            e.preventDefault();
            e.stopPropagation();
            page.load(idof(c));
        })
    });
}
function open(){
    $byq("div#main").addclass("shown");
}
function init() {
    firsthacks();

    //model
    page=(function(){
        var words,me,top,
            content;
        var main = $byid("main");
        content = $byid("content");
        words=(function(_i){
            if (_i) return;
            var words = $byid("words");
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
                    var href = $byid(id).attr("href");
                    loadcontent(href, true);
                    return true;
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
        function restore_top(){
            if (hasclass($byid("top"),"shown")) return;
            $byid("top").rmclass("minimized").addclass("shown");
            words.hide();
            me.hide();
        };

        var top  = $byid("top");
        var ret = {};
        function unload(){
            content.rmclass("shown");
        }
        ret.words = function(){
            if (page.state === "wordsarticle") unload();
            top.rmclass("shown").addclass("minimized");
            words.show();
            page.state = "words";
        };
        ret.me = function(){
            if (page.state === "wordsarticle") unload();
            top.rmclass("shown").addclass("minimized");
            me.show();
            page.state = "me";
        };
        ret.landing=function(){
            page.state = "landing";
            words.hide();
            me.hide();
            content.rmclass("shown");
            restore_top();
        };
        ret.load = function(id){
            if (!words.load(id)) return;
            if (page.state === "words") {
                succ(
                    0,function(){
                        $byq("#words").addclass("transitout");},
                    300,function(){
                        $byq("#words").rmclass("shown","transitout");
                        content.addclass("shown");
                    });
            } else {
                main.addclass("shown");
                top.rmclass("shown").addclass("minimized");
                content.addclass("shown");
            }
            page.state="wordsarticle";
        };
        return ret;
    })();
    refresh();
    //is this still needed
    //control
    $byq("#wordslink").evlis('click',function(e){
        switch(page.state) {
            case "words":
                page.landing();
                break;
            default:
                page.words();
        }    
    });
    $byq("#melink").evlis('click',function(e){
        switch(page.state) {
            case "me":
                page.landing();
                break;
            default:
                page.me();
        }
    });
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
    );
    if (instagram) {
        instgrm.Embeds.process();
    }
}
