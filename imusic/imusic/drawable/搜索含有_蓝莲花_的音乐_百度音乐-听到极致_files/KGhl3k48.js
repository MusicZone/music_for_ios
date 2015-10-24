(function(t){t.widget("ting.autoComplete",{options:{},_create:function(){var e=this;e.widgetEventPrefix="auto.";e.sugInput=t(".s_ipt_wr input");e.sugResult=t(".sug-result");e.sugType="search";e.keyword="";e._dataCache={};e.classStyle={FIRST_ITEM:"first-item",LAST_ITEM:"last-item",OVER:"over",CI:"ci"};e.keyMgr={DOWN:40,UP:38,ESC:27,ENTER:13};e.currentItem=null;e.selectEventInterval=150;e._lastSelectTime=null;e._focusing=false;e.logTime=0;e.num=0;e.timeId=null;e.loadPic=t("#loading-pic");e.addInputEventListener();e.DefaultCdPic="//mu7.bdstatic.com/static/images/default/album_default_40.png";e.DefaultAvatarPic="//mu5.bdstatic.com/static/images/default/artist_default_40.png"},addInputEventListener:function(){var e=this;e.sugInput.bind("blur",function(){if(!e._focusing){e.hide()}});e.sugInput.bind("focus input propertychange",function(t){if(e.timeId===null){e.timeId=setTimeout(function(){e.textChangeHandler(t)},50)}});e.sugInput.bind("keydown",function(t){if(t.keyCode!=40&&t.keyCode!=38&&t.keyCode!=27&&t.keyCode!=13){return}var s=(new Date).valueOf();var i=parseInt(s-e._lastSelectTime,10)||0;if(i>=e.selectEventInterval){e._lastSelectTime=s;e.keySelectHandler(t)}});e.sugResult.bind("mouseenter",function(t){e._focusing=true});e.sugResult.bind("mouseleave",function(t){e.currentItem=null;e._focusing=false});e.sugResult.bind("mousedown",function(s){var i=s.target,a=i.nodeName.toUpperCase(),n="",r=null;if(a!="A"){r=t(i).parents("a:first").get(0);if(r&&t(r,e.sugResult)){i=r}else{return}}var l=t(i).parents("dl:first").attr("class")||"sug-people";var u=l.match(/sug-(\w+)/),o;if(u){o=u[1];e.channelName=o;if(o=="people"){n="clicklog"}else{n="suggestionlog"}}e._trigger(n,null,e);return})},handleResponse:function(e){var s=this;var i=s.format(e);s.sugResult.html(i);if(s.sugInput.val()&&"音乐盒".indexOf(s.sugInput.val())!=-1)var a='<dl data-module="search" class="sug-artist clearfix">'+'<dt class="sug-title clearfix">链接</dt>'+'<dd class="first-item">'+'<a href="http://play.baidu.com" class="">'+'<img width="40px" height="40px" src="//mu7.bdstatic.com/static/i/mBwqO2fj.png" alt="音乐盒"><span>音乐盒</span>'+"</a></dd>"+"</dl>";s.sugResult.find(".shadowright").prepend(a);require(["music_icon"],function(){t(".music-icon-hook",s.sugResult).musicIcon({hasTip:false})});t(".music-icon-hook .list-micon",s.sugResult).bind("click",function(){var e=t(this).parent().data("log")||{};e.act=t(this).data("action");ting.logger.plogClick("clicksearch",e)});t(".music-icon-hook .list-micon.icon-needvip").bind("click",function(){var e=t(this);var s=e.parents(".music-icon-hook").data("musicicon");var i={};var a=function(t){var e=document.createElement("div");e.innerHTML=t;try{return e.childNodes[0].nodeValue}catch(s){return t}};if(BDUS&&BDUS.vipState!="gold"){ting.showTip({$tar:e,type:"needgoldvip",cancelEvent:"blur",reason:"pay_listen"})}else{var n=s.type;var r="playSong";switch(n){case"song":r="playSong";break;case"album":r="playAlbum";break;case"diy":r="playDiy";break;case"artist":r="playArtist";break}ting.media[r](a(s.id),i)}});s.mouseOverHandler();s.mouseOutHandler();s.currentItem=null;s.loadPic.css("display","none");ting.logger.log("exposure",{expoitem:"sug",sub:s.sugType});this.show()},handleReady:function(t){var e=this;e._dataCache[e.keyword||"remlist"]=t;e.handleResponse(t)},textChangeHandler:function(e){var s=this;s.timeId=null;var i=s.sugInput.val();if(s.keyword==t.trim(i)&&s.keyword!=i){return}s.keyword=t.trim(i);s.logTime=(new Date).valueOf();s.loadPic.css("display","block");var a=s._dataCache[s.keyword||"remlist"];if(a!==undefined){s.handleResponse(a)}else{s._dataCache={};s._trigger("change",e,s)}},keySelectHandler:function(e){var s=window.event?event.keyCode:e.which;var i=0;var a=this.currentItem;var n=null;switch(s){case this.keyMgr.UP:e.preventDefault();i--;break;case this.keyMgr.DOWN:e.preventDefault();i++;break;case this.keyMgr.ESC:this.sugInput.blur();this.hide();break;case this.keyMgr.ENTER:e.preventDefault();var r=this.currentItem;if(r){this.sugInput.blur();var l=this.currentItem.parents("dl:first").attr("class");var u=l.match(/sug-(\w+)/),o;if(u){o=u[1];this.channelName=o}else{return}this._trigger("suggestionlog",null,this);location.href=t("a",r).attr("href");ting.sugControl=false;return}else{if(!t.trim(this.sugInput.val())){return null}else{this.sugInput.blur();this._trigger("commonlog",null,this);var c=this;setTimeout(function(){c.element.submit()},500)}}break;default:break}if(i){if(i==1){if(a){n=a.nextAll("dd").eq(0);if(!n.length){if(!a.parent().nextAll("dl").length){n=t("dd:first",this.sugResult)}else{n=a.parent().nextAll("dl").eq(0).children("dd:first")}}}else{n=t("dd:first",this.sugResult)}}else if(i==-1){if(a){n=a.prevAll("dd").eq(0);if(!n.length){if(!a.parent().prevAll("dl").length){n=t("dd:last",this.sugResult)}else{n=a.parent().prevAll("dl").eq(0).children("dd:last")}}}else{n=t("dd:last",this.sugResult)}}if(a){t("a",a).removeClass("over")}if(n.length){t("a",n).addClass("over");this.currentItem=n}else{this.currentItem=null}}},mouseOverHandler:function(){var e=this;t("dd",e.sugResult).bind("mouseenter",function(s){t("a",e.sugResult).removeClass("over");e.currentItem=t(this);t(this).children("a").addClass("over")})},mouseOutHandler:function(){var e=this;t("dd",e.sugResult).bind("mouseleave",function(s){t(this).children("a").removeClass("over");e.currentItem=null})},toKeyWord:function(t){if(!this.keyword){return t}else{var e=this.keyword.toLowerCase();var s=t.toLowerCase().indexOf(e);var i=e.length;if(this.keyword&&s>=0){return t.substring(0,s)+'<span class="'+this.classStyle.CI+'">'+t.substring(s,s+i)+"</span>"+t.substring(s+i)}else{return t}}},toContent:function(t,e,s,i){var a=function(t){if(t%2==1)return{isPlay:true,isCollect:true};var e=window.thirdConf,s=t.toString(2),i=s.length,a={};for(var n=0;n<i;n++){if(s[n]==1){var r=i-n-1;if(e[r].pc.is_play){a.isPlay=e[r].pc.is_play;a.isCollect=e[r].pc.is_collect;break}}}return a};if(!t.length){return}var n=this;var i=i||"search";var r=['<dl data-module="'+i+'" class = "sug-'+e+' clearfix"><dt class = "sug-title clearfix">'+s+"</dt>"];var l=0;var u=n.DefaultCdPic;var o=n.DefaultAvatarPic;var c=315;if(i=="search"){switch(e){case"artist":if(t.length<3){l=t.length}else{l=3}break;case"song":if(t.length<9-n.num){l=t.length}else{l=9-n.num}break;case"album":if(t.length<2){l=t.length}else{l=2}break;default:break}}else{l=t.length}for(var d=0;d<l;d++){n.num++;var g=t[d];if(l===1){r.push('<dd class = "'+n.classStyle.FIRST_ITEM+" "+n.classStyle.LAST_ITEM+'">')}else{if(d===0){r.push('<dd class = "'+n.classStyle.FIRST_ITEM+'">')}else if(d==l-1){r.push('<dd class = "'+n.classStyle.LAST_ITEM+'">')}else{r.push("<dd>")}}if(g.resource_provider){g.filter=a(g.resource_provider)}else{g.filter={isPlay:true,isCollect:true,playFee:g.playFee}}if(g.bitrate_fee){g.feeData=JSON.parse(g.bitrate_fee);if(g.feeData[0]&&g.feeData[0]=="-1|-1"){g.filter.playFee=true}else{g.filter.playFee=false}}else{g.filter.playFee=false}switch(e){case"artist":if(!!g.artistpic){o=g.artistpic}else{o=n.DefaultAvatarPic}r.push('<a href="/artist/'+g.artistid+'?pst=sug"><img width="40px" height="40px" src="'+o+'" alt="'+g.artistname+'" /><span>'+n.toKeyWord(ting.cutString.cutStr(g.artistname,c-60,true,14))+"</span>"+n.yyrIconHtml(g.yyr_artist)+"</a>"+n.musicIconHtml(g.artistid,"artist",g.filter)+"</dd>");break;case"song":var m=ting.cutString.getP(g.songname,14),f="",h="",p=0;if(n.sugType=="recommend"){h='<img width="40px" height="40px" src="'+(g.songpic||n.DefaultCdPic)+'" />';p=58;c=c-p}var v=g.songid;if(m>=c-38){f='<a href="/song/'+v+'?pst=sug">'+h+'<span class="songname">'+n.toKeyWord(ting.cutString.cutStr(g.songname,c-17,true,14))+"</span>"+n.yyrIconHtml(g.yyr_artist)+"</a>"+n.musicIconHtml(g.songid,"song",g.filter)+n.mvIconHtml(g.songid,g.has_mv)+"</dd>"}else if(m<c-38&&m>=c-53){f='<a href="/song/'+v+'?pst=sug">'+h+'<span class="songname">'+n.toKeyWord(g.songname)+'</span><span class="artistname">-...</span>'+n.yyrIconHtml(g.yyr_artist)+"</a>"+n.musicIconHtml(g.songid,"song",g.filter)+n.mvIconHtml(g.songid,g.has_mv)+"</dd>"}else if(m<c-53){var y=c-m-24;f='<a href="/song/'+v+'?pst=sug">'+h+'<span class="songname">'+n.toKeyWord(g.songname)+'</span><span class="artistname"><i class="h-line">-</i>'+n.toKeyWord(ting.cutString.cutStr(g.artistname,y,true,14))+"</span>"+n.yyrIconHtml(g.yyr_artist)+"</a>"+n.musicIconHtml(g.songid,"song",g.filter)+n.mvIconHtml(g.songid,g.has_mv)+"</dd>"}r.push(f);break;case"album":if(!!g.artistpic){u=g.artistpic}else{u=n.DefaultCdPic}r.push('<a href="/album/'+g.albumid+'?pst=sug"><div class = "borderdiv"><span class="sidepic"></span><img width="40px" height="40px" src="'+u+'" alt="'+g.albumname+'" /></div><div>《'+n.toKeyWord(ting.cutString.cutStr(g.albumname,c-80,true,14))+'》</div><div class="artistname album-artist-name">'+n.toKeyWord(ting.cutString.cutStr(g.artistname,c-70,true,14))+n.yyrIconHtml(g.yyr_artist)+"</div></a>"+n.musicIconHtml(g.albumid,"album",g.filter)+"</dd>");break;case"mv":r.push('<a href="/playmv/'+g.mvid+'?pst=sug">'+n.toKeyWord(ting.cutString.cutStr(g.mvname,c,true,14))+"</a></dd>");break;case"playlist":c=c-58;r.push('<a href="/songlist/'+g.playlistid+'?pst=sug"> <img width="40px" height="40px" src="'+(g.playlistpic||n.DefaultCdPic)+'" /> <span class="songname">'+n.toKeyWord(ting.cutString.cutStr(g.playlistname,c,true,14))+"</span>"+n.yyrIconHtml(g.yyr_artist)+"</a>"+n.musicIconHtml(g.songids.replace(/,/g,"_"),"song",g.filter)+"</dd>");break;default:break}}r.push("</dl>");return r.join("")},musicIconHtml:function(t,e,s){var i='<a class="list-micon icon-play" data-action="play" title="播放" href="#"></a>';var a='<a class="list-micon icon-needvip" data-action="play" title="播放" href="#"><span class="icon-text">VIP</span></a>';var n='<i class="module-line music-icon-line"></i>';var r='<a class="list-micon icon-add" data-action="add" title="添加" href="#"></a>';var l='<span class="music-icon-hook" data-log="{&quot;page&quot;:&quot;suglog&quot;,&quot;pos&quot;:&quot;sug_'+e+'&quot;}" data-musicicon="{&quot;id&quot;:&quot;'+t+"&quot;,&quot;type&quot;:&quot;"+e+"&quot;,&quot;iconStr&quot;:&quot;play add&quot;,&quot;moduleName&quot;:&quot;sugIcon&quot;,&quot;playFee&quot;:"+s.playFee+'}">';if(s){if(s.playFee){l+=a}else{if(s.isPlay){l+=i;if(s.isCollect){l+=n+r}}else{if(s.isCollect){l+=r}}}}else{l+=i+n+r}l+="</span>";return l},yyrIconHtml:function(t){if(t!=undefined&&t!="0"&&t!=0){var e='<span class="yyr-icon-hook"></span>'}else e="";return e},mvIconHtml:function(t,e){if(e!="0"&&e!=0&&e!=undefined){var s='<span class="mv-icon-hook">'+'<a href="/mv/'+t+'"></a>'+"</span>"}else s="";return s},format:function(e){this.num=0;var s=e.Pro,e=e.data,i={artist:"",album:"",song:""},a="",n;var r=t.browser.msie&&t.browser.version=="6.0";if(!e){return}this.sugType="search";if(e.artist){i.artist=this.toContent(e.artist,"artist","歌手")||""}if(e.album){i.album=this.toContent(e.album,"album","专辑")||""}if(e.song){i.song=this.toContent(e.song,"song","歌曲")||""}if(e.list){this.sugType="recommend";n="<h2>大家正在搜</h2>";if(e.list.song){i.rmdlist=n+this.toContent(e.list.song,"song","歌曲","hot")||""}if(e.list.artist){i.rmdartist=this.toContent(e.list.artist,"artist","歌手","hot")||""}if(e.list.mv){i.rmdmv=this.toContent(e.list.mv,"mv","MV","hot")||""}if(e.list.playlist){i.rmdplaylist=this.toContent(e.list.playlist,"playlist","歌单","hot")||""}}if(e.recommend){n="<h2>猜你喜欢</h2>";i.recommend=n+this.toContent(e.recommend.song,"song","歌曲","individuation")||""}var l=r?'<iframe src="about:blank" frameborder="0"></iframe>':"";if(s){for(var u=0;u<s.length;u++){a+=i[s[u]]}}else{for(var o in i){a+=i[o]}}return l+'<div class = "shadowleft"><div class="shadowright"><div class="'+(this.sugType=="recommend"?"rmd-layer":"")+'">'+a+"</div></div></div>"},show:function(){this.sugResult.show()},hide:function(){this.sugResult.hide()},destroy:function(){this.sugInput.unbind();this.sugResult.unbind()}})})(jQuery);
/** If u are interested in our code and would like to make it robust, just contact us^^ <@音乐前端> **/
/** Generated by M3D. **/