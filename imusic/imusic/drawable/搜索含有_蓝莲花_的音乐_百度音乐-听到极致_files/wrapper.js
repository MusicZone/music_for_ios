var passport=passport||window.passport||{};passport._modulePool=passport._modulePool||{};passport._define=passport._define||function(a,b){passport._modulePool[a]=b&&b()};passport._getModule=passport._getModule||function(a){return passport._modulePool[a]};passport._load=passport._load||function(c,a,i){if(a){var h=document,f=h.createElement("SCRIPT");f.type="text/javascript";f.charset="UTF-8";var b=c.split("?")[0];var g=Math.round(Math.random()*1000);var e=new Date().getTime();if(f.readyState){f.onreadystatechange=function(){if(f.readyState=="loaded"||f.readyState=="complete"){f.onreadystatechange=null;if(100==g){var d=new Date().getTime()-e;(new Image()).src="http://nsclick.baidu.com/v.gif?pid=111&type=1023&url="+encodeURIComponent(b)+"&time="+d}i&&i()}}}else{f.onload=function(){if(100==g){var d=new Date().getTime()-e;(new Image()).src="http://nsclick.baidu.com/v.gif?pid=111&type=1023&url="+encodeURIComponent(b)+"&time="+d}i&&i()}}if(100==g){f.src=b+"?t="+Math.random()}else{f.src=c}h.getElementsByTagName("head")[0].appendChild(f)}else{var h=document,f=h.createElement("SCRIPT");f.type="text/javascript";f.charset="UTF-8";f.src=c;h.getElementsByTagName("head")[0].appendChild(f);if(f.readyState){f.onreadystatechange=function(){if(f.readyState=="loaded"||f.readyState=="complete"){f.onreadystatechange=null;i&&i()}}}else{f.onload=function(){i&&i()}}}};passport._use=passport._use||function(e,f,h){var a={"http:":"http://passport.bdimg.com","https:":"https://ss0.bdstatic.com/5LMZfyabBhJ3otebn9fN2DJv"};if(passport&&passport._protocol=="https"){var g="https:"}else{var g=window.location?window.location.protocol.toLowerCase():document.location.protocol.toLowerCase()}var d=(a[g]||a["https:"])+f;var c=e+".js";moduleInstance=passport._getModule(c);if(moduleInstance){h&&h(moduleInstance)}else{passport._load(d,true,b)}function b(){var i=passport._getModule(c);if(i){h&&h(i)}else{throw new Error("load "+c+"module script error.")}}};passport.use=passport.use||function(d,c,f){var b=(c&&c.tangram===false)?"":"_tangram";if(c&&c.protocol){passport._protocol=c.protocol}if(d=="reg"&&c&&c.regPhoneOnly){d="regPhone"}if(d=="topBar"&&c&&c.library){passport.library=c.library;b=""}var e={login:"/passApi/js/login_dc77b448.js",login_tangram:"/passApi/js/login_tangram_65dce903.js",loginWLtoPC:"/passApi/js/loginWLtoPC_2069f8e5.js",accConnect:"/passApi/js/accConnect_c361f90b.js",accConnect_tangram:"/passApi/js/accConnect_tangram_2e3c2ddd.js",accRealName:"/passApi/js/accRealName_e68c26c0.js",accRealName_tangram:"/passApi/js/accRealName_tangram_7bb8aca4.js",topBar:"/passApi/js/topBar_7a01d14c.js",topBar_tangram:"/passApi/js/topBar_tangram_a75a5a88.js",loginWap:"/passApi/js/loginWap_74562b51.js",reg:"/passApi/js/reg_92f651ce.js",reg_tangram:"/passApi/js/reg_tangram_ef1afe4b.js",regPhone:"/passApi/js/regPhone_ad5fb2f0.js",regPhone_tangram:"/passApi/js/regPhone_tangram_c3e5a375.js",fillUserName:"/passApi/js/fillUserName_7cadc605.js",fillUserName_tangram:"/passApi/js/fillUserName_tangram_cc58d585.js",qrcode:"/passApi/js/qrcode_77872c36.js",qrcode_tangram:"/passApi/js/qrcode_tangram_3d80c97e.js",realUserTag:"/passApi/js/realUserTag_47a2f73b.js",realUserTag_tangram:"/passApi/js/realUserTag_tangram_e6e61e60.js",bind:"/passApi/js/bind_bd00d33e.js",bind_tangram:"/passApi/js/bind_tangram_4e86a7c1.js",multiBind:"/passApi/js/multiBind_733a34d2.js",multiBind_tangram:"/passApi/js/multiBind_tangram_764c1354.js",multiUnbind:"/passApi/js/multiUnbind_51293837.js",multiUnbind_tangram:"/passApi/js/multiUnbind_tangram_022acc6f.js",changeUser:"/passApi/js/changeUser_c9f66881.js",changeUser_tangram:"/passApi/js/changeUser_tangram_102a5cb0.js",loginMultichoice:"/passApi/js/loginMultichoice_4ed47ce1.js",loginMultichoice_tangram:"/passApi/js/loginMultichoice_tangram_9545c4e0.js",confirmWidget:"/passApi/js/confirmWidget_f5699a20.js",confirmWidget_tangram:"/passApi/js/confirmWidget_tangram_bc9ba87b.js",uni_rebindGuide:"/passApi/js/uni_rebindGuide_3469332e.js",uni_rebindGuide_tangram:"/passApi/js/uni_rebindGuide_tangram_c4e19a84.js"},a=d+b;if(arguments.length==2){f=c}if(c&&c.tangramInst){passport.tangramInst=c.tangramInst}passport._use(a,e[a],f)};