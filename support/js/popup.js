var _debug_cnt=0;
var pop_o={
disablePos:{x:0, y:0, w:0, h:0},
uniq:0,
loginReturnURL:"",
pwdReturnURL:"",
innerWH:function(){ 
	var ret={};
	if(top.document.documentElement && top.document.documentElement.scrollTop){
		ret.x=parseInt(top.document.documentElement.scrollLeft);
		ret.y=parseInt(top.document.documentElement.scrollTop);		
	}else{
		ret.x=parseInt(top.document.body.scrollLeft);
		ret.y=parseInt(top.document.body.scrollTop);		
	}
	
	if(top.document.documentElement){
		ret.w=parseInt(top.document.documentElement.clientWidth);				
		ret.h=parseInt(top.document.documentElement.clientHeight);
	}else if(top.window.innerHeight){
		ret.w=parseInt(top.window.innerWidth);				
		ret.h=parseInt(top.window.innerHeight);				
	}else{
		ret.w=parseInt(top.document.body.clientWidth);				
		ret.h=parseInt(top.document.body.clientHeight);
	}
	return ret;
},
getElementRect:function(obj){
	var ret={x:0,y:0,w:0,h:0};
	try{
		if(obj.getBoundingClientRect){
			var rect = obj.getBoundingClientRect();
			ret.x=rect.left-2;
			ret.y=rect.top-2;
			ret.w=rect.right-rect.left;
			ret.h=rect.bottom-rect.top;
		}else{
			ret.x=obj.offsetLeft;
			ret.y=obj.offsetTop;
			var parent = obj.offsetParent;
			while(parent!=null){
				ret.x = ret.x + parent.offsetLeft;
				ret.y = ret.y + parent.offsetTop;
				parent=parent.offsetParent;
			}
			ret.w = obj.offsetWidth;
			ret.h = obj.offsetHeight;
		}
	}catch(e){}
	return ret;
},
openConfirmPop:function(title, msg, confirmFnc, cancelFnc){
	var dname="popConfirm";
	var popAlert = document.getElementById(dname);
	if(popAlert.parentNode!=document.body) document.body.appendChild(popAlert);
	
	var el = document.getElementById("confirmTitle");
	while(el.lastChild) el.removeChild(el.lastChild);
	el.appendChild(document.createTextNode(title));
	var el = document.getElementById("confirmMsg");
	el.innerHTML=msg;
	el.style.fontWeight = "bold";
	el.style.color = "#333333";
	
	pop_o.confirmCallBack=confirmFnc;
	pop_o.cancelCallBack=cancelFnc;
	var popAlert = document.getElementById(dname);
	if(!popAlert.parentNode) document.body.appendChild(popAlert);
	pop_o.setDisable(true,dname);
	var wrect=pop_o.innerWH();
	if(!popAlert.orgH){
		var styleTop=pop_o.getStyle(popAlert, "top");
		popAlert.orgH=0;
		if(styleTop.indexOf("%")>=0) popAlert.orgH=Math.round(wrect.h*parseInt(styleTop)/100);
		else popAlert.orgH=parseInt(styleTop);

		var styleLeft=pop_o.getStyle(popAlert, "left");
		popAlert.orgW=0;
		if(styleLeft.indexOf("%")>=0) popAlert.orgW=Math.round(wrect.w*parseInt(styleLeft)/100);
		else popAlert.orgW=parseInt(styleLeft);
	}else{
		if (isNaN(popAlert.orgH)) popAlert.orgH=0;
	}
	popAlert.style.top=(popAlert.orgH+wrect.y)+"px";
	popAlert.style.display="";
},
delConfirmPop:function(title, msg, confirmFnc, cancelFnc){
	var dname="popConfirm1";
	var popAlert = document.getElementById(dname);
	if(popAlert.parentNode!=document.body) document.body.appendChild(popAlert);
	
	var el = document.getElementById("confirmTitle1");
	while(el.lastChild) el.removeChild(el.lastChild);
	el.appendChild(document.createTextNode(title));
	var el = document.getElementById("confirmMsg1");
	el.innerHTML=msg;
	el.style.fontWeight = "bold";
	el.style.color = "#333333";
	
	pop_o.confirmCallBack=confirmFnc;
	pop_o.cancelCallBack=cancelFnc;
	var popAlert = document.getElementById(dname);
	if(!popAlert.parentNode) document.body.appendChild(popAlert);
	pop_o.setDisable(true,dname);
	var wrect=pop_o.innerWH();
	if(!popAlert.orgH){
		var styleTop=pop_o.getStyle(popAlert, "top");
		popAlert.orgH=0;
		if(styleTop.indexOf("%")>=0) popAlert.orgH=Math.round(wrect.h*parseInt(styleTop)/100);
		else popAlert.orgH=parseInt(styleTop);

		var styleLeft=pop_o.getStyle(popAlert, "left");
		popAlert.orgW=0;
		if(styleLeft.indexOf("%")>=0) popAlert.orgW=Math.round(wrect.w*parseInt(styleLeft)/100);
		else popAlert.orgW=parseInt(styleLeft);
	}else{
		if (isNaN(popAlert.orgH)) popAlert.orgH=0;
	}
	popAlert.style.top=(popAlert.orgH+wrect.y)+"px";
	popAlert.style.display="";
},
closeConfirmPop:function(isConfirm){
	var dname="popConfirm";
	mgr_historyBack=null;
	var popAlert = document.getElementById(dname);
	pop_o.setDisable(false,"wrap");
	popAlert.style.display="none";
	if(isConfirm && pop_o.confirmCallBack) pop_o.confirmCallBack.call();
	else if(!isConfirm && pop_o.cancelCallBack) pop_o.cancelCallBack.call();
},
alertCallBack:null,
openAlertPop:function(dname, title, msg, fnc, code){ 
	var popAlert = document.getElementById(dname);
	var el = document.getElementById("alertTitle");
	while(el.lastChild) el.removeChild(el.lastChild);
	el.appendChild(document.createTextNode(title));
	var el = document.getElementById("alertMsg");
	el.innerHTML=msg;
	
	pop_o.alertCallBack=fnc;
	var popAlert = document.getElementById(dname);
	if(!popAlert.parentNode) document.body.appendChild(popAlert);
	pop_o.setDisable(true,"wrap");
	var wrect=pop_o.innerWH();
	if(!popAlert.orgH){
		var styleTop=pop_o.getStyle(popAlert, "top");
		popAlert.orgH=0;
		if(styleTop.indexOf("%")>=0) popAlert.orgH=Math.round(wrect.h*parseInt(styleTop)/100);
		else popAlert.orgH=parseInt(styleTop);
	}

	popAlert.style.top=(popAlert.orgH+wrect.y)+"px";
	popAlert.style.display="";
},
closeAlertPop:function(dname, vtype){
	var popAlert = document.getElementById(dname);
	pop_o.setDisable(false,"wrap");
	popAlert.style.display="none";
	if(pop_o.alertCallBack) pop_o.alertCallBack.call();
},
openPopup:function (id_name, layerIfrName, url, wrap){
	var divobj = document.getElementById(id_name);
	if(!divobj.parentNode) document.body.appendChild(divobj);
	pop_o.setDisable(true,id_name);
	var wrect=pop_o.innerWH();
	if(!divobj.orgH){
		var styleTop=pop_o.getStyle(divobj, "top");
		divobj.orgH=0;
		if(styleTop.indexOf("%")>=0) divobj.orgH=Math.round(wrect.h*parseInt(styleTop)/100);
		else divobj.orgH=parseInt(styleTop);
	}
	divobj.style.top=(divobj.orgH+wrect.y)+"px";
	divobj.style.display="";
},
closePopup:function (id,wrap){
	var popup = document.getElementById(id);
	pop_o.setDisable(false,wrap);
	popup.style.display="none";
},
displaysetPreview:function(div,display){
  var layer_preview = document.getElementById(div); 
  
  if(display != null){
    layer_preview.style.display = display;
  }
  else{  
    if(layer_preview.style.display =="none")
      layer_preview.style.display = "";
    else
      layer_preview.style.display = "none";
  }
  $('#ifr_preview').attr("src", "");
},
resizeIframe:function(div){
  var obj = document.getElementById(div);
  obj.style.height = 0+"px";
  
  var height=obj.contentWindow.document.body.scrollHeight;
  var width=obj.contentWindow.document.body.scrollWidth;
  obj.style.height = height+10+"px";
  obj.style.width = width+"px";
},
setDisable:function(mode,id){
	var grayObj=document.getElementById("div_gray");
	if(mode){
		if(grayObj) return;		
		grayObj=document.createElement("img");
		grayObj.id="div_gray";
		grayObj.style.position="absolute";
		grayObj.style.backgroundColor="#000000";
		grayObj.style.opacity=0.3;
		grayObj.style.filter = "Alpha(Opacity=30)"; 
		grayObj.style.zIndex=100;
		
		grayObj.oncontextmenu=function(){return false;}
		 
		var tbl=document.getElementById(id);
		if(tbl) {
//			tbl.style.left=(document.body.scrollLeft)+'px';
//			tbl.style.top=(document.body.scrollTop)+'px';
			document.body.insertBefore(grayObj, tbl);
		}else
			document.body.appendChild(grayObj);
		if(window.addEventListener){
			window.addEventListener("resize",  this.graySizeHandler, true);
			window.addEventListener("scroll",  this.graySizeHandler, true);
		}else{
			window.attachEvent("onresize",  this.graySizeHandler);
			window.attachEvent("onscroll",  this.graySizeHandler);
		}
		 this.graySizeHandler();
	}else if(grayObj){
		document.body.removeChild(grayObj);
		if(window.addEventListener){
			window.removeEventListener("resize",  this.graySizeHandler, true);
			window.removeEventListener("scroll",  this.graySizeHandler, true);
		}else{
			window.detachEvent("onresize",  this.graySizeHandler);
			window.detachEvent("onscroll",  this.graySizeHandler);
		}
	}
},
graySizeHandler:function(evt){
	var grayObj=document.getElementById("div_gray");
	if(!grayObj) return;
	var wrect=pop_o.innerWH();
	grayObj.style.left=wrect.x+'px';
	grayObj.style.top=wrect.y+'px';
	grayObj.style.width=wrect.w+'px';
	grayObj.style.height=wrect.h+'px';
},
getStyle:function(el,prop){
	if(el.currentStyle){
		return el.currentStyle[prop]
	}else if(window.getComputedStyle){
		return document.defaultView.getComputedStyle(el,null).getPropertyValue(prop)
	}
	return '';
}
}
