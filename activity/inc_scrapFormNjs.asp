<form name="frmScrap" method="post" target="hidden_ifrScrap" action="/activity/proc_scrap.asp">
<input type="hidden" name="mode" value="" />
<input type="hidden" name="sPosition" value="" />
<input type="hidden" name="selSeq" value="" />
<input type="hidden" name="scIdxs" value="" />
<input type="hidden" name="paperName" value="" />
<input type="hidden" name="entryname" value="" />
<input type="hidden" name="kwds" value="" />
</form>
<% If g_MEM.uid<>"dsdat00" Then %>
<iframe name="hidden_ifrScrap" src="" frameborder=0 width=0 height=0 /></iframe>
<% Else %>
<iframe name="hidden_ifrScrap" src="" frameborder="0" width="800" height="500"></iframe>
<% End If %>
<script type="text/javascript">
//<[CDATA[
try{
	if (parent.top && parent.top.document){
		mem_o=parent.mem_o;
	}
}catch(e){}
function goScrap(scIdxs){
<% If g_mem.uid<>"" Then %>
<%	If g_MEM.certify="G" or g_MEM.certify="N" Then %>
if (mem_o.chkTeacher()){
	if (scIdxs==""){
//		alert("스크랩 할 자료를 선택 해주세요.");
		mypop_Sc.view("addScSelect");
	}else{
		for(var i=0; i<$("#leftListLi li a").length; i++){
			if($("#leftListLi li a").eq(i).hasClass("on")){
				if($("#leftListLi li a").eq(i).text()=="사진자료실"){
					D.frmScrap.sPosition.value=9;
				}
			}
		}
		D.frmScrap.mode.value=scIdxs;
		D.frmScrap.scIdxs.value=scIdxs;
//		mypop_Sc.view("addScConfirm");
		D.frmScrap.submit();
	}
}
<%	Else %>
//	alert("인증받은 선생님만 다운로드 가능합니다!");
	menu_o.openAlertPop(null, null, null, 11);
<%	End If %>
<% Else %>
//	alert("로그인을 해주세요.");
	mem_o.gotoLogin();
<% End If %>
}
function goScrapDel(scIdxs, sPosition, selSeq){
	if (scIdxs==""){
//		alert("삭제 할 스크랩을 선택 해주세요.");
		mypop_Sc.view("delScSelect",function(){});
	}else{
		var D=document;
		D.frmScrap.mode.value="del";
		D.frmScrap.scIdxs.value=scIdxs;
		D.frmScrap.sPosition.value=sPosition;
		D.frmScrap.selSeq.value=selSeq;
		D.frmScrap.action="/activity/proc_scrap.asp";
//		D.frmScrap.submit();
		mypop_Sc.view("delScConfirm",function(){});
	}
}
/*
	문제지 만들기 스크랩 삭제
*/
function goMakeScrapDel(scIdxs, sPosition, myexam){
	if (scIdxs==""){
//		alert("삭제 할 문제지를 선택 해주세요.");
		mypop_Sc.view("delScSelect",function(){});
	}else{
		var D=document;
		D.frmScrap.mode.value="del";
		D.frmScrap.sPosition.value=sPosition;
		D.frmScrap.scIdxs.value=scIdxs;
		if (myexam) D.frmScrap.action = "/scrap/proc_exam.asp"
		//D.frmScrap.submit();
		mypop_Sc.view("delScConfirm",function(){});
	}
}
/*
	검색어 삭제  2011.12.15
*/
function goSearchWordDel(scIdxs){
	if (scIdxs==""){
		mypop_Sc.view("delScSelect",function(){});
	}else{
		var D=document;
		D.frmScrap.mode.value="del";
		D.frmScrap.scIdxs.value=scIdxs;
		D.frmScrap.action = "/scrap/proc_search.asp"	
		//D.frmScrap.submit();		
		mypop_Sc.view("delScConfirm",function(){});
	}
}
/*
	검색 스크랩  2011.12.12
*/
function goSrchScrap(sPosition, scIdxs){
<% If g_mem.uid<>"" Then %>
	if (mem_o.chkTeacher()){
		document.frmScrap.sPosition.value=sPosition;
		document.frmScrap.mode.value=scIdxs;
		document.frmScrap.scIdxs.value=scIdxs;
//		mypop_Sc.view("addScConfirm");
		document.frmScrap.submit();
	}
<% Else %>
	mem_o.gotoLogin();
<% End If %>
}
/*
	검색어 저장  2011.12.15
*/
function goSrchWordSave(dic,entryname,kwds,scIdxs){
<% If g_mem.uid<>"" Then %>
	if (mem_o.chkTeacher()){
		//alert(scIdxs);
		document.frmScrap.sPosition.value=dic;
		document.frmScrap.mode.value="ins";
		document.frmScrap.entryname.value=entryname;
		document.frmScrap.kwds.value=kwds;
		document.frmScrap.scIdxs.value=scIdxs;
		document.frmScrap.action = "/scrap/proc_search.asp";
		document.frmScrap.submit();
	}
<% Else %>
	mem_o.gotoLogin();
<% End If %>
}
/*
	나의 문제지 이동  2011.12.19
*/
function goSelectedPaper(mode,scIdxs,paperName){
<% If g_mem.uid<>"" Then %>
	if (mem_o.chkTeacher()){
		if (scIdxs==""){
			mypop_Sc.actText = "이동할";
			mypop_Sc.scText="문제를";
			mypop_Sc.view("addScSelect",function(){});
		}else{
			document.frmScrap.paperName.value=paperName;
			document.frmScrap.mode.value=mode;
			document.frmScrap.scIdxs.value=scIdxs;
			document.frmScrap.action = "/scrap/proc_paper.asp";
			document.frmScrap.submit();
		}
	}
<% Else %>
	mem_o.gotoLogin();
<% End If %>
} 
function goDeletePaper(paperName, sPosition){
	if (paperName==""){
		mypop_Sc.view("delScSelect",function(){});
	}else{
		var D=document;
		D.frmScrap.mode.value="del";
		D.frmScrap.paperName.value=paperName;
		D.frmScrap.sPosition.value=sPosition;
		D.frmScrap.action = "/scrap/proc_paper.asp";
		mypop_Sc.view("delScConfirm_paper",function(){});
		//D.frmScrap.submit();
		
	}
}

var mypop_Sc={};
mypop_Sc.retURL="<%=util_toJSStr(util_currentURL())%>";
mypop_Sc.actText="삭제할";
mypop_Sc.scText="스크랩을";

if ( mypop_Sc.retURL.indexOf("labMenu=4")>0 && mypop_Sc.retURL.indexOf("subMenu=3")>0 ){
	mypop_Sc.scText="문제를";
}else if ( mypop_Sc.retURL.indexOf("labMenu=4")>0 ){
	mypop_Sc.scText="문제지를";
}
if ( mypop_Sc.retURL.indexOf("labMenu=5")>0 ){
	mypop_Sc.scText="검색어를";
}
mypop_Sc.chk=function(){
	var mySmartTitle=document.frm_confirm.mySmartTitle.value.trim();
	if(mySmartTitle==""){
		alert('교과서의 이름을 입력해 주세요.'); return;
		return;	
	}
	document.frm_confirm.retURL.value=mypop_Sc.retURL;
	document.frm_confirm.submit();
}
mypop_Sc.add=function(seq, idx){
	<% If g_mem.grade>=100 Then %>
		alert("관리자 입니다.");
		return;
	<%End If%>
	document.frm_confirm.seq.value=seq;
	document.frm_confirm.idx.value=idx;
	mypop_Sc.view('add', function(){
		
	});
}
mypop_Sc.confirm=function(){
	mypop_Sc.view('confirm', function(){
		
	});
}
mypop_Sc.del=function(idx){
	document.frm_delSc.idx.value=idx;
	document.frm_delSc.retURL.value=mypop_Sc.retURL;
	mypop_Sc.view('del', function(){
		
	});
}
mypop_Sc.resizeHandler=function(){
	var popup=document.getElementById("popup_"+mypop_Sc.div);
	if(!popup) return;
	else if(popup.style.display!="block") return;
	var scTop, scLeft, maxW, maxH;
	if(document.documentElement){
		scLeft=parseInt(document.documentElement.scrollLeft);
		scTop=parseInt(document.documentElement.scrollTop);
		maxW=parseInt(document.documentElement.clientWidth);				
		maxH=parseInt(document.documentElement.clientHeight);
	}else if(window.innerHeight){
		scLeft=parseInt(document.body.scrollLeft);
		scTop=parseInt(document.body.scrollTop);
		maxW=parseInt(window.innerWidth);				
		maxH=parseInt(window.innerHeight);				
	}else{
		scLeft=parseInt(document.body.scrollLeft);
		scTop=parseInt(document.body.scrollTop);
		maxW=parseInt(document.body.clientWidth);				
		maxH=parseInt(document.body.clientHeight);
	}

	var rect=comm_o.getElementRect(popup);
	popup.style.left=((maxW-rect.w)/2+scLeft)+'px';
	popup.style.top=((maxH-rect.h)/2+scTop)+'px';

}
mypop_Sc.view=function(div, fnc){
	mypop_Sc.hide();
	mypop_Sc.div=div;

	var popup=document.getElementById("popup_"+div);
	menu_o.setDisable(true);
	document.body.appendChild(popup);
	popup.style.display="block";
	popup.style.zIndex=10000;
	mypop_Sc.resizeHandler();
	if(window.addEventListener){
		window.addEventListener("resize",  mypop_Sc.resizeHandler, mypop_Sc);
		window.addEventListener("scroll",  mypop_Sc.resizeHandler, mypop_Sc);
	}else{
		window.attachEvent("onresize",  mypop_Sc.resizeHandler);
		window.attachEvent("onscroll",  mypop_Sc.resizeHandler);
	}
}
mypop_Sc.hide=function(){
	document.getElementById("popup_addScSelect").style.display="none";//추가선택
	document.getElementById("popup_addScConfirm").style.display="none";//저장확인
	document.getElementById("popup_addScDone").style.display="none";//저장완료
	document.getElementById("popup_addScDone2").style.display="none";//저장완료
	document.getElementById("popup_addScDone4").style.display="none";//저장완료
	document.getElementById("popup_addScDone9").style.display="none";//저장완료
	document.getElementById("popup_addScExist").style.display="none";//이미저장
	document.getElementById("popup_delScConfirm").style.display="none";//삭제확인
	document.getElementById("popup_delScSelect").style.display="none";//삭제선택
	document.getElementById("popup_delScDone").style.display="none";//삭제완료
	document.getElementById("popup_delScConfirm_paper").style.display="none";//나의문제지 삭제확인
	menu_o.setDisable(false);
	
	if(window.addEventListener){
		window.removeEventListener("resize",  mypop_Sc.resizeHandler, mypop_Sc);
		window.removeEventListener("scroll",  mypop_Sc.resizeHandler, mypop_Sc);
	}else{
		window.detachEvent("onresize",  mypop_Sc.resizeHandler);
		window.detachEvent("onscroll",  mypop_Sc.resizeHandler);
	}
}
mypop_Sc.reload=function(){
	mypop_Sc.hide();
	top.location.reload(true);
}
function printScText(){
	document.write ( mypop_Sc.scText );
}
function printActText(){
	document.write ( mypop_Sc.actText );
}
//]]>
</script>

<style type="text/css">
#popup_addScSelect{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScSelect .exit{float:left; width:302px; height:21px;}
#popup_addScSelect .exit img{float:right;}
#popup_addScSelect .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScSelect .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScSelect .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:110px;}
#popup_addScSelect .popup_icon li{float:left;text-align:center; margin-left:10px;}

#popup_addScConfirm{float:left; width:392px; height:166px; background:url(/images/popup/sub6_2_img.png); display:none;position:absolute;}
#popup_addScConfirm .exit{float:left; width:392px; height:21px;}
#popup_addScConfirm .exit img{float:right;}
#popup_addScConfirm .popup_text{float:left; margin-left:17px; margin-top:20px; text-align:center;}
#popup_addScConfirm .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScConfirm .popup_icon{float:left; margin-top:25px; margin-left:120px;}
#popup_addScConfirm .popup_icon li{float:left; margin-left:10px;}

#popup_addScDone{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScDone2{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScDone4{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScDone9{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScDone .exit{float:left; width:302px; height:21px;}
#popup_addScDone2 .exit{float:left; width:302px; height:21px;}
#popup_addScDone4 .exit{float:left; width:302px; height:21px;}
#popup_addScDone9 .exit{float:left; width:302px; height:21px;}
#popup_addScDone .exit img{float:right;}
#popup_addScDone2 .exit img{float:right;}
#popup_addScDone4 .exit img{float:right;}
#popup_addScDone9 .exit img{float:right;}
#popup_addScDone .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScDone2 .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScDone4 .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScDone9 .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScDone .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScDone2 .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScDone4 .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScDone9 .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScDone .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:80px;}
#popup_addScDone2 .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:80px;}
#popup_addScDone4 .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:80px;}
#popup_addScDone9 .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:80px;}
#popup_addScDone .popup_icon li{float:left;text-align:center; margin-left:10px;}
#popup_addScDone2 .popup_icon li{float:left;text-align:center; margin-left:10px;}
#popup_addScDone4 .popup_icon li{float:left;text-align:center; margin-left:10px;}
#popup_addScDone9 .popup_icon li{float:left;text-align:center; margin-left:10px;}

#popup_addScExist{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_addScExist .exit{float:left; width:302px; height:21px;}
#popup_addScExist .exit img{float:right;}
#popup_addScExist .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_addScExist .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_addScExist .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:110px;}
#popup_addScExist .popup_icon li{float:left;text-align:center; margin-left:10px;}

#popup_delScSelect{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_delScSelect .exit{float:left; width:302px; height:21px;}
#popup_delScSelect .exit img{float:right;}
#popup_delScSelect .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_delScSelect .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_delScSelect .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:110px;}
#popup_delScSelect .popup_icon li{float:left;text-align:center; margin-left:10px;}

#popup_delScConfirm{float:left; width:392px; height:166px; background:url(/images/popup/sub6_2_img.png); display:none;position:absolute;}
#popup_delScConfirm .exit{float:left; width:392px; height:21px;}
#popup_delScConfirm .exit img{float:right;}
#popup_delScConfirm .popup_text{float:left; margin-left:17px; margin-top:20px; text-align:center;}
#popup_delScConfirm .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_delScConfirm .popup_icon{float:left; margin-top:25px; margin-left:120px;}
#popup_delScConfirm .popup_icon li{float:left; margin-left:10px;}

#popup_delScDone{float:left; width:302px; height:126px; background:url(/images/popup/sub6_3_img.png); display:none;position:absolute;}
#popup_delScDone .exit{float:left; width:302px; height:21px;}
#popup_delScDone .exit img{float:right;}
#popup_delScDone .popup_text{float:left; margin-left:-17px; margin-top:5px; text-align:center;}
#popup_delScDone .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_delScDone .popup_icon{float:left; text-align:center;margin-top:10px; margin-left:110px;}
#popup_delScDone .popup_icon li{float:left;text-align:center; margin-left:10px;}

#popup_delScConfirm_paper {float:left; width:392px; height:166px; background:url(/images/popup/sub6_2_img.png); display:none;position:absolute;}
#popup_delScConfirm_paper .exit{float:left; width:392px; height:21px;}
#popup_delScConfirm_paper .exit img{float:right;}
#popup_delScConfirm_paper .popup_text{float:left; margin-left:17px; margin-top:20px; text-align:center;}
#popup_delScConfirm_paper .popup_text ul{font-family:"돋움"; font-size:12px; font-weight:bold; color:#333333; width:352px; height:52px; line-height:18px;}
#popup_delScConfirm_paper .popup_icon{float:left; margin-top:25px; margin-left:120px;}
#popup_delScConfirm_paper .popup_icon li{float:left; margin-left:10px;}

.popup_button { margin-left:50px; }
.bt_submit_bk {
	width:61px; height:23px; display:block; margin:0 auto; float:left; margin-right:5px;
	background:url('../itembank/images/icon/bt_submit_bk.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}
.bt_submit_bk3 {
	width:151px; height:23px; display:block; margin:0 auto; float:left;
	background:url('../itembank/images/icon/bt_submit_bk3.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}
.bt_submit_bk4 {
	width:151px; height:23px; display:block; margin:0 auto; float:left;
	background:url('../itembank/images/icon/bt_submit_bk4.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}
.bt_submit_bk5 {
	width:151px; height:23px; display:block; margin:0 auto; float:left;
	background:url('../itembank/images/icon/bt_submit_bk5.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}

</style>
<div id="popup_addScConfirm">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li>선택하신 <script>printScText();</script> 저장 하시겠습니까?</li></ul></div>
	<div class="popup_icon">
		<ul>
			<li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="document.frmScrap.submit();" style="cursor:pointer;" /></div></li>
			<li><div class="popup_out_icon"><img src="/images/popup/popup_out_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li>
		</ul>
	</div>
</div>
<div id="popup_addScSelect">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><br /><script>printScText();</script> 선택 해주세요.</li></ul></div>
	<div class="popup_icon">
		<ul><li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li></ul>
	</div>
</div>
<div id="popup_addScExist">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><br />이미 존재하는 자료 입니다.</li></ul></div>
	<div class="popup_icon">
		<ul><li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li></ul>
	</div>
</div>
<div id="popup_addScDone">
<input type="hidden" name="sc2pageHref" id="sc2pageHref" value="/myLab/?labMenu=2" />
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><span id="sc2pageText">스크랩이 완료되었습니다.</span></li></ul></div>
	<div class="popup_button" style="margin-left:120px;">
		<input type="button" value="닫기" name="" class="bt_submit_bk" onClick="mypop_Sc.hide();" />
		<!--<input type="button" value="확인후이동" name="" class="bt_submit_bk3" onClick="top.location.href=document.getElementById('sc2pageHref').value;" />-->
	</div>
</div>
<div id="popup_addScDone2">
<input type="hidden" name="sc2pageHref2" id="sc2pageHref2" value="/myLab/?labMenu=2" />
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><span style="font-weight:bold; color:#333;">스크랩이 완료되었습니다.</span></li></ul></div>
	<div class="popup_button">
		<input type="button" value="닫기" name="" class="bt_submit_bk" onClick="mypop_Sc.hide();" />
		<input type="button" value="확인후이동" name="" class="bt_submit_bk3" onClick="top.location.href=document.getElementById('sc2pageHref').value;" />
	</div>
</div>
<div id="popup_addScDone4">
<input type="hidden" name="sc2pageHref4" id="sc2pageHref4" value="/myLab/?labMenu=2" />
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><span style="font-weight:bold; color:#333;">스크랩이 완료되었습니다.</span></li></ul></div>
	<div class="popup_button">
		<input type="button" value="닫기" name="" class="bt_submit_bk" onClick="mypop_Sc.hide();" />
		<input type="button" value="확인후이동" name="" class="bt_submit_bk5" onClick="top.location.href=document.getElementById('sc2pageHref').value;" />
	</div>
</div>
<div id="popup_addScDone9">
<input type="hidden" name="sc2pageHref9" id="sc2pageHref9" value="/myLab/?labMenu=2" />
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><span style="font-weight:bold; color:#333;">스크랩이 완료되었습니다.</span></li></ul></div>
	<div class="popup_button">
		<input type="button" value="닫기" name="" class="bt_submit_bk" onClick="mypop_Sc.hide();" />
		<input type="button" value="확인후이동" name="" class="bt_submit_bk4" onClick="top.location.href=document.getElementById('sc2pageHref').value;" />
	</div>
</div>
<div id="popup_delScSelect">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><br /><script>printActText();</script>&nbsp;<script>printScText();</script> 선택해 주세요.</li></ul></div>
	<div class="popup_icon">
		<ul><li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li></ul>
	</div>
</div>
<div id="popup_delScDone">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li><br />삭제했습니다.</li></ul></div>
	<div class="popup_icon">
		<!--ul><li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="self.location.reload(true);" style="cursor:pointer;" /></div></li></ul-->
		<ul><li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="top.location.href=document.getElementById('sc2pageHref').value;" style="cursor:pointer;" /></div></li></ul>
	</div>
</div>
<div id="popup_delScConfirm">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li>해당 자료를 삭제하시겠습니까?</li></ul></div>
	<div class="popup_icon">
		<ul>
			<li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="document.frmScrap.submit();" style="cursor:pointer;" /></div></li>
			<li><div class="popup_out_icon"><img src="/images/popup/popup_out_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li>
		</ul>
	</div>
</div>
<div id="popup_delScConfirm_paper">
	<div class="exit"><img src="/images/popup/popup_exit_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div>
	<div class="popup_text"><ul><li>선택하신 나의 문제지를 삭제하시겠습니까?</li>
	<li>삭제된 내용은 복구 불가하오니 </li>
	<li>신중한 결정바랍니다.</li></ul></div>
	<div class="popup_icon">
		<ul>
			<li><div class="popup_ok_icon"><img src="/images/popup/popup_ok_icon.gif" onClick="document.frmScrap.submit();" style="cursor:pointer;" /></div></li>
			<li><div class="popup_out_icon"><img src="/images/popup/popup_out_icon.gif" onClick="mypop_Sc.hide();" style="cursor:pointer;" /></div></li>
		</ul>
	</div>
</div>