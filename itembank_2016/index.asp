<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="itembank_2016"
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual='/inc/topmenu_renewal.inc' -->
<script language="JavaScript" type="text/javascript" src="js/subjectList.js?timeu=<%=util_unic() %>"></script>
<form name="frmQuestion" id="frmQuestion" method="post">
	<input type="hidden" name="classtype" id="classtype" value="" />
	<input type="hidden" name="grade" value="" />
	<input type="hidden" name="term" value="" />
	<input type="hidden" name="subject" id="subject" value="" />
	<input type="hidden" name="curriculum" id="curriculum" value="" />
	<input type="hidden" name="author" value="" />
	<input type="hidden" name="units" value="" />
	<input type="hidden" name="servicetarget" value="" />
	<input type="hidden" name="isAll" value="" />
	<input type="hidden" name="cntH" value="" />
	<input type="hidden" name="cntM" value="" />
	<input type="hidden" name="cntL" value="" />
	<input type="hidden" name="field1s" id="field1s" value="" />
	<input type="hidden" name="questiontypes" id="questiontypes" value="" />
	<input type="hidden" name="isChap" id="isChap" value="" />

	<input type="hidden" name="htmlstr_chg" id="htmlstr_chg" value="" />
	<input type="hidden" name="qStrChg" id="qStrChg" value="" />
</form>
<%
Dim sch:sch=UCase(util_nte(request("sch"), "M", "string"))
Dim sbj:sbj=util_nte(request("sbj"), 1, "int") ' 170908 과목명 바로가기... 
Dim bkno:bkno=util_nte(request("bkno"), 1, "int") ' 170908 교재 바로가기... 하단에 script...
%>
<script type="text/javascript">
var frmQuestion = document.frmQuestion;
var isProc=false; // 출제중인지...
var procMsg="현재 진행되는 시험지 출제를 종료하시겠습니까?";
var globalSch="<%=sch %>", globalSbj="";

function chkIsProc(){ // 출제중...
	if (isProc){
		if (confirm(procMsg)){
			isProc=false;
		}
	}
}
function setSbj(sbj, sbjIdx){ // 과목명list...
	chkIsProc();
	if (isProc){
		return;
	}
	if (typeof(sbj)=="undefined") sbj="M";
	if (typeof(sbjIdx)!="number") sbjIdx=0;
	
	//$("#leftListLi").empty();
	var tmp="";
	
	var arr=eval("sbjList"+sbj);
	//alert(arr.legnth);
	if (arr.length>0){
		for (var i=0; i<arr.length; i++){
			tmp+="<li>";
			tmp+="<a href=\"javascript:setSbj('"+sbj+"', "+ i +");\" class=\"title";
			if (i==sbjIdx) 
			tmp+=" on";
			tmp+="\">"+ arr[i][3] +"</a>";
			tmp+="<div class=\"con\">";
			tmp+="<ul class=\"list_accordion_sub\" name='list_accordion_sub' id='list_accordion_sub"+ i +"' style='display:none;'>";
			tmp+="</ul>";
			tmp+="</div>";
			tmp+="</li>";
		}
	}
	$("#leftListLi").html(tmp);

//	if(sbj=="E"){
//		var activeTab=$("ul.list_bank_tab li a:eq(0)").attr("rel");
//		$("#"+activeTab).fadeIn();
//	}else{
//		var activeTab=$("ul.list_bank_tab li a:eq(1)").attr("rel");
//		$("#"+activeTab).fadeIn();
//	}
	//setSubSbj=sbj;
	globalSch=sbj;
	setSubSbj(sbj, sbjIdx);
	onSch(sbj)

	$("ul.list_accordion").children("li").eq(sbjIdx+1).children("a").css("border-top", "1px solid #ddd");
}
function chkQtype(showQtype){
	if (showQtype){
		$("#liQuestiontype").css("display", "");
	}else{
		$("#liQuestiontype").css("display", "none");
	}
}
function setSubSbj(sbj, sbjIdx, idx){
	chkIsProc();
	if (isProc){
		return;
	}
	if (typeof(sbj)=="undefined") sbj=itbDnSbj;
	if (typeof(sbjIdx)!="number") sbjIdx=0;
	if (typeof(idx)!="number") idx=0;

	$("#step01").css("display","");
	$("#step02").css("display","none");
	
	inputOff();
	var tmp="";
	var curri="";
	var arr=eval("sbjSubList"+sbj);
	arr=arr[sbjIdx];

	if (arr[idx][0]=="TH"){ // 기술가정
		$("#liChkSrvC").css("display", "none");
	}else{
		$("#liChkSrvC").css("display", "");
	}

	$("#itb_type").val("");
	var list=$("ul [name=list_accordion_sub]");
	list.css("display", "none");
	list.eq(sbjIdx).css("display", "");
	if (arr.length>0){
		if (sbj=="M" && arr[idx][0]=="EN"){
			$("#liField1").css("display", "");
		}else{
			$("#liField1").css("display", "none");
		}
		for (var i=0; i<arr.length; i++){
			if (!arr[i][6]){
				arr[i][6]="09";
			}
			if (curri!=arr[i][6]){
				curri=arr[i][6];
				tmp+='<li class="divi_tit_icon divi_20'+ curri +'"><img src="/images/renew/sub/icon_tit_'+ curri +'.png" /></li>';
			}
			tmp+="<li>";
				tmp+="<span></span><a href=\"javascript:setSubSbj('"+ sbj +"', "+ sbjIdx +", "+ i +"); "
//				tmp+="getItbSrch('"+ sbj +"', '"+arr[i][0]+"', '"+arr[i][1]+"','"+arr[i][2]+"', '"+arr[i][3]+"' ,'"+arr[i][4]+"');";
				tmp+="\" class=\"";
				if (i==idx){ 
					tmp+="on";
					$("#itemTitle").text(arr[i][5]);
					globalSbj=arr[i][0];
				}
				tmp+="\">"+ arr[i][5];
//				if (arr[i][6]){
//					tmp+='&nbsp;<img src="/images/renew/sub/icon_curri_'+ arr[i][6] +'.png" />';
//				}
				tmp+="<div class=\"arrow\"></div></a>";
			tmp+="</li>";
		}
	}
	list.html(tmp);

	var getItbSrchFun = $("ul [name=list_accordion_sub]:eq("+sbjIdx+") li a").attr("href");
	getItbSrchFun=getItbSrchFun.split(";");
	eval(getItbSrchFun[1]);
	var curri='09';
	if (arr[idx][6]){ // 20170216 "2015개정" 추가...
		curri=arr[idx][6];
	}
	$("#imgCurri").attr("src", "/images/renew/sub/icon_smart_20"+ curri +".png");

	getItbSrch(sbj, arr[idx][0], arr[idx][1], arr[idx][2], arr[idx][3], arr[idx][4], curri);
}
function getRdoIsChap(){
	var rdoVal=$(':radio[name="rdoIsChap"]:checked').val();
	if (rdoVal!="n") rdoVal="y";

	return rdoVal;
}
function getItbSrch(sbj, itbSbj, itbAuthor, itbId, itbGrade, itbTerm, itbCurri){
	if (typeof(sbj)=="undefined") sbj="E";
	if(sbj=="E"){
		sbj="EL"
	}else{
		sbj+="I";
	}
	if (typeof(itbSbj)=="undefined") itbSbj="KO";
	if (typeof(itbCurri)=="undefined") itbCurri="09";
	if (typeof(itbAuthor)=="undefined") itbAuthor="";
	if (typeof(itbId)=="undefined") itbId="2001";
	if (typeof(itbGrade)=="undefined") itbGrade="1";
	if (typeof(itbTerm)=="undefined") itbTerm="1";
	var isChap=getRdoIsChap();
	//console.log("\nsbj : "+sbj+"\nitbSbj : "+itbSbj+"\nitbAuthor : "+itbAuthor+"\nitbId : "+itbId+"\nitbGrade : "+itbGrade+"\nitbTerm : "+itbTerm);
	
	frmQuestion.classtype.value=sbj;
	frmQuestion.subject.value=itbSbj;
	frmQuestion.curriculum.value=itbCurri;
	frmQuestion.author.value=itbAuthor;
	frmQuestion.grade.value=itbGrade;
	frmQuestion.term.value=itbTerm;
	frmQuestion.isChap.value=isChap;

	var list=$("#sectionsList");
	var xUrl="getSections.asp";
	var qry="?classtype="+sbj+"&itbSbj="+itbSbj+"&itbCurri="+itbCurri+"&itbAuthor="+itbAuthor+"&itbId="+itbId+"&itbGrade="+itbGrade+"&itbTerm="+itbTerm+"&isChap="+ isChap;

	list.load(xUrl + qry);
	showDiffBox(sbj, itbSbj);
	//setTimeout("checkboxAllOn()",700);
}
function getIsType(gsch, gsbj){
	var fm=document.frmQuestion;
	var ggrd=fm.grade.value;
	var gtrm=fm.term.value;
	var gisType=true;
	var gcurri=$("#curriculum").val();

	if (gsch=="EL" && "|KO|MA|".indexOf(gsbj)>0){ // 초등 국수 문항유형 안보임...
		gisType=false;
		if (gsbj=="KO" && (gtrm=="2")){ // 국 1-2, 2-2 제외... -> 2학기 제외...
			gisType=true;
		}
		if (gsbj=="KO" && gtrm=="1" && (ggrd!="1" && ggrd!="2")){ // 국09 1-1, 1-1 제외하고 보임... 
			gisType=true;
		}
	}
//	if (gsch=="EL" && gsbj=="MA" && gcurri=="15" && ((ggrd=="1" || ggrd=="2") && gtrm=="1")){ // 수 15개정 1-1, 2-1 제외...
	if (gcurri=="15"){
		gisType=true;
	}
	return gisType;
}
function showDiffBox(sch, sbj){
	var isShowQopt=true; // 180320 문항출처 비노출 과목 추가...
	var fm=document.frmQuestion;
	var oCurri=$("#curriculum").val();
	var oGrd=fm.grade.value;
	var oTerm=fm.term.value;
//	console.log(sch +" : "+ sbj +" : "+ oCurri +" : "+ oGrd +" : "+ oTerm);

	if (sch=="MI"){
		if (oCurri=="15" && (sbj=="SO" || sbj=="EN")){
			isShowQopt=false;
		}
	}else if (sch=="EL"){
		if (oCurri=="15" && oTerm=="1"){
			if ((oGrd=="3" || oGrd=="4") && (sbj=="KO" || sbj=="SO" || sbj=="SC")){
				isShowQopt=false;
			}
		}
	}else if (sch=="HI"){
		if (sbj!="MA"){
			isShowQopt=false;
		}
	}

//	if(sch=="EL"){ // 초등 : 문항 출처 안보이게...
//	if(sch!="MI" && (sch=="HI" && sbj!="MA")){ // 중등 or 고등수학(170828) 아니면 문항 출처 안보이게...
	if (!isShowQopt){
		$(".question_origin").css("display","none");
		$("#servicetargetT").attr("checked", true);
		$("#servicetargetC").attr("checked", true);
	}else{
		$(".question_origin").css("display","");
	}

	var fm=document.frmQuestion;
	var grd=fm.grade.value;
	var trm=fm.term.value;
	var curri=fm.curriculum.value;
	var isDiff=getIsDiff(sch, sbj, grd, trm, curri); //true;
	var isType=getIsType(sch, sbj);//true;

	if (!isDiff){ // 난이도 안보임...(초등 국)
		$("#diffBox").css("display", "none");
		$("#diffCnt").css("display", "table");
		$("#diffBoxRight").css("display", "none");
		$("#btnInputOn").css("display", "none"); // 직접입력 버튼...
	}else{ // 난이도 보임...
		$("#diffBox").css("display", "");
		$("#diffCnt").css("display", "");
		$("#diffBoxRight").css("display", "");
		$("#btnInputOn").css("display", ""); // 직접입력 버튼...
	}
	chkQtype(isType);
}
function inputOn(){
	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");

	cntH.css("background-color", "");
	cntM.css("background-color", "");
	cntL.css("background-color", "");

	cntH.attr("disabled", false);
	cntM.attr("disabled", false);
	cntL.attr("disabled", false);

	var li = $("li [name=num_select]");
	for(var i=0; i<li.length; i++){
		if(li.eq(i).hasClass("on")){
			li.eq(i).css("border-left", "1px solid #bdbdbd");
			li.eq(i).removeClass("on");
		}
	}
}
function inputOff(){
	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");

	cntH.css("background-color", "#eee");
	cntM.css("background-color", "#eee");
	cntL.css("background-color", "#eee");

	cntH.attr("disabled", true);
	cntM.attr("disabled", true);
	cntL.attr("disabled", true);

	cntH.val("");
	cntM.val("");
	cntL.val("");
	
	var li = $("li [name=num_select]");
	for(var i=0; i<li.length; i++){
		if(li.eq(i).hasClass("on")){
			li.eq(i).css("border-left", "1px solid #bdbdbd");
			li.eq(i).removeClass("on");
		}
	}
	clearFm();
	$("#cntQuestion").val(0);
}
function questionSet(set){
	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");
	var cntQuestion = $("#cntQuestion");

	if(set==10){
		cntH.val(2);
		cntM.val(5);
		cntL.val(3);
	}else if(set==20){
		cntH.val(4);
		cntM.val(10);
		cntL.val(6);
	}else if(set==25){
		cntH.val(5);
		cntM.val(13);
		cntL.val(7);
	}else if(set==30){
		cntH.val(6);
		cntM.val(15);
		cntL.val(9);
	}else if(set==50){
		cntH.val(10);
		cntM.val(25);
		cntL.val(15);
	}
	
	cntQuestion.val(Number(cntH.val())+Number(cntM.val())+Number(cntL.val()));

	cntH.css("background-color", "#eee");
	cntM.css("background-color", "#eee");
	cntL.css("background-color", "#eee");

	cntH.attr("disabled", true);
	cntM.attr("disabled", true);
	cntL.attr("disabled", true);
}
function cntQuestionChk(){
	$(document).on("keyup", "#cntH", function() {$(this).val( $(this).val().replace(/[^0-9]/gi,"") );});
	$(document).on("keyup", "#cntM", function() {$(this).val( $(this).val().replace(/[^0-9]/gi,"") );});
	$(document).on("keyup", "#cntL", function() {$(this).val( $(this).val().replace(/[^0-9]/gi,"") );});

	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");
	var cntQuestion = $("#cntQuestion");
	var cnt
	var max=0;

	cnt = Number(cntH.val())+Number(cntM.val())+Number(cntL.val());

	if(cnt>50){
		alert("50문항 이상으로는  출제하실 수 없습니다.");
		cntH.val(10);
		cntM.val(25);
		cntL.val(15);
		cntQuestion.val(Number(cntH.val())+Number(cntM.val())+Number(cntL.val()));
	}else{
		cntQuestion.val(cnt);
	}

}
function checkDepth(obj, depth){
	if($(obj).find(":checkbox").is(":checked")){
		$(obj).addClass("on");
		if(depth==1){
			$(obj).next().css("display", "");
			$(obj).next("li").children("ul.depth02").children("ul.depth03").css("display","");
			$(obj).next("li").children("ul.depth02").children("li").find(":checkbox").attr("checked", true);
			$(obj).next("li").children("ul.depth02").children("li").addClass("on");
			$(obj).next("li").children("ul.depth02").children("ul.depth03").find(":checkbox").attr("checked", true);
			$(obj).next("li").children("ul.depth02").children("ul.depth03").children("li").addClass("on");
		}else if(depth==2){
			$(obj).next("ul").css("display", "");
			$(obj).next("ul").children("li").find(":checkbox").attr("checked", true);
			$(obj).next("ul").children("li").addClass("on");

			var chk=true;
			for(var i=0; i<$(obj).parents("ul.depth02").children("li").find(":checkbox").length; i++){
				if($(obj).parents("ul.depth02").children("li").find(":checkbox").eq(i).is(":checked")==false){
					chk=false;
				}
			}
			if(chk){
				$(obj).parents("li.depth02Li").prev("li").find(":checkbox").attr("checked", true);
				$(obj).parents("li.depth02Li").prev("li").addClass("on");
			}

		}else if(depth==3){
			var chk=true;
			for(var i=0; i<$(obj).parents("ul.depth03").children("li").find(":checkbox").length; i++){
				if($(obj).parents("ul.depth03").children("li").find(":checkbox").eq(i).is(":checked")==false){
					chk=false;
				}
			}
			if(chk){
				$(obj).parents("ul.depth03").prev("li").find(":checkbox").attr("checked", true);
				$(obj).parents("ul.depth03").prev("li").addClass("on");
			}
			chk=true;
			for(var i=0; i<$(obj).parents("ul.depth03").parents("ul.depth02").children("li").find(":checkbox").length; i++){
				if($(obj).parents("ul.depth03").parents("ul.depth02").children("li").find(":checkbox").eq(i).is(":checked")==false){
					chk=false;
				}
			}
			if(chk){
				$(obj).parents("ul.depth03").prev("li").parents("ul.depth02").parents("li.depth02Li").prev("li").find(":checkbox").attr("checked", true);
				$(obj).parents("ul.depth03").prev("li").parents("ul.depth02").parents("li.depth02Li").prev("li").addClass("on");
			}
		}
	}else{
		$(obj).removeClass("on");
	
		if(depth==1){
			$(obj).next("li").css("display", "none");
			$(obj).next("li").children("ul.depth02").children("li").find(":checkbox").attr("checked", false);
			$(obj).next("li").children("ul.depth02").children("li").removeClass("on");
			$(obj).next("li").children("ul.depth02").children("ul.depth03").children("li").find(":checkbox").attr("checked", false);
			$(obj).next("li").children("ul.depth02").children("ul.depth03").children("li").removeClass("on");
		}else if(depth==2){
			$(obj).next("ul").css("display", "none");
			$(obj).next("ul").children("li").find(":checkbox").attr("checked", false);
			$(obj).next("ul").children("li").removeClass("on");

			var chk=true;
			for(var i=0; i<$(obj).parents("ul.depth02").children("li").find(":checkbox").length; i++){
				if($(obj).parents("ul.depth02").children("li").find(":checkbox").eq(i).is(":checked")==false){
					chk=false;
				}
			}
			if(!chk){
				$(obj).parents("li.depth02Li").prev("li").find(":checkbox").attr("checked", false);
				$(obj).parents("li.depth02Li").prev("li").removeClass("on");
			}

		}else if(depth==3){
			for(var i=0; i<$(obj).parents("ul.depth03").children("li").find(":checkbox").length; i++){
				if($(obj).parents("ul.depth03").children("li").find(":checkbox").eq(i).is(":checked")){
					$(obj).parents("ul.depth03").prev("li").find(":checkbox").attr("checked", false);
					$(obj).parents("ul.depth03").prev("li").removeClass("on");
					$(obj).parents("ul.depth03").prev("li").parents("ul.depth02").parents("li.depth02Li").prev("li").find(":checkbox").attr("checked", false);
					$(obj).parents("ul.depth03").prev("li").parents("ul.depth02").parents("li.depth02Li").prev("li").removeClass("on");
				}
			}
			
		}
	}

	checkStr();
}
function checkboxAllOn(){
	$(".select_title").addClass("on");
	$(".depth02LiSub").addClass("on");
	$(".depth02Li").css("display", "");
	$(".depth03LiSub").addClass("on");
	$(".depth03Li").css("display", "");
	$("input[name=depth1_checkbox]").attr("checked", true);
	$("input[name=depth2_checkbox]").attr("checked", true);
	$("input[name=depth3_checkbox]").attr("checked", true);
}
function checkStr(){
	var depth1=$("input[name=depth1_checkbox]");
	var depth2=$("input[name=depth2_checkbox]");
	var depth3=$("input[name=depth3_checkbox]");
	var depth1_str="";
	var depth2_str="";
	var depth3_str="";
	var units="";

	for(var i=0; i<depth1.length; i++){
		if(depth1_str!="" && depth1.eq(i).is(":checked")){
			depth1_str=depth1_str+", ";
		}
		if(depth1.eq(i).is(":checked")){
			depth1_str=depth1_str+"'"+depth1.eq(i).val()+"'";
		}
	}
	for(var i=0; i<depth2.length; i++){
		if(depth2_str!="" && depth2.eq(i).is(":checked")){
			depth2_str=depth2_str+", ";
		}
		if(depth2.eq(i).is(":checked")){
			depth2_str=depth2_str+"'"+depth2.eq(i).val()+"'";
		}
	}
	for(var i=0; i<depth3.length; i++){
		if(depth3_str!="" && depth3.eq(i).is(":checked")){
			depth3_str=depth3_str+", ";
		}
		if(depth3.eq(i).is(":checked")){
			depth3_str=depth3_str+"'"+depth3.eq(i).val()+"'";
		}
	}

	for(var i=0; i<depth1.length; i++){
		if(units!="" && depth1.eq(i).is(":checked")){
			units=units+", ";
		}
		if(depth1.eq(i).is(":checked")){
			//units=units+"'"+depth1.eq(i).val()+"'";
			units=units+depth1.eq(i).val();
		}else{
			var depth2_eq = depth1.eq(i).parents("li.select_title").next("li.depth02Li").children("ul.depth02").children("li.depth02LiSub").find("input[name=depth2_checkbox]");
			for(var j=0; j<depth2_eq.length; j++){
				if(units!="" && depth2_eq.eq(j).is(":checked")){
					units=units+", ";
				}
				if(depth2_eq.eq(j).is(":checked")){
					//units=units+"'"+depth2_eq.eq(j).val()+"'";
					units=units+depth2_eq.eq(j).val();
				}else{
					var depth3_eq = depth2_eq.eq(j).parents("li.depth02LiSub").next("ul.depth03").children("li.depth03LiSub").find("input[name=depth3_checkbox]");
					for(var x=0; x<depth3_eq.length; x++){
						if(units!="" && depth3_eq.eq(x).is(":checked")){
							units=units+", ";
						}
						if(depth3_eq.eq(x).is(":checked")){
							//units=units+"'"+depth3_eq.eq(x).val()+"'";
							units=units+depth3_eq.eq(x).val();
						}
					}
					
				}
			}
		}
	}

	frmQuestion.units.value=units;
	//console.log("units : "+units);

	setTimeout("questionCnt()",100);
}
function questionCnt(val){
	var servicetargetT = $("#servicetargetT");
	var servicetargetC = $("#servicetargetC");
	var isAll = $("#isAll");
	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");
	
	if(servicetargetT.is(":checked") && servicetargetC.is(":checked")){
		frmQuestion.servicetarget.value="TR";
	}else if(servicetargetT.is(":checked")){
		frmQuestion.servicetarget.value="T";
	}else if(servicetargetC.is(":checked")){
		frmQuestion.servicetarget.value="R";
	}else{
		frmQuestion.servicetarget.value="";
		alert("한 개의 항목에 대해서는 선택해주셔야 합니다.");
		if (typeof(val)=="undefined") val="T";
		$("#servicetarget"+ val).prop("checked", true);
		return;
	}

	if(isAll.is(":checked")){
		frmQuestion.isAll.value=isAll.val();
	}else{
		frmQuestion.isAll.value="n";
	}
	frmQuestion.cntH.value=cntH.val();
	frmQuestion.cntM.value=cntM.val();
	frmQuestion.cntL.value=cntL.val();

	var xUrl="getQuestionCnt.asp";
	//	frmQuestion.target="ifrProc2";
	//	frmQuestion.action=xUrl;
	//	frmQuestion.submit();
//	console.log($("#frmQuestion").serialize());
    $.ajax({
		type: "POST",
		url: xUrl,
		//dataType : 'json',
		data: $("#frmQuestion").serialize(),
		success: function(data){
			chkQcnt(data);
		}
	});
}
function getIsDiff(sch, sbj, grd, trm, curri){
	var gisDiff=true;
	if (sch=="EL" && "|KO|".indexOf(sbj)>0){ // 난이도 안보임...(초등 국)		
		if (trm=="1" && curri!="15"){ // 국 1-2, 2-2 제외... -> 2학기 제외...
			gisDiff=false;
		}
		if ((grd!="1" && grd!="2") && trm=="1" && curri!="15"){ // 국 09 1-1, 2-1 제외하고 보임...
			gisDiff=true;
		}
	}
	return gisDiff;
}
function chkQcnt(data){
	var sch=$("#classtype").val();
	var sbj=$("#subject").val();
	var curri=$("#curriculum").val();

	var fm=document.frmQuestion;
	var grd=fm.grade.value;
	var trm=fm.term.value;
	var isDiff=getIsDiff(sch, sbj, grd, trm, curri); //true;
	var isType=getIsType(sch, sbj);//true;

	data=data.split(",");
	if (!isDiff){ // 난이도 안보임...(초등 국)
		var totCnt=parseInt(data[0]) + parseInt(data[1]) + parseInt(data[2]);
		$("#getTotCnt").text(totCnt);
	}else{
		$(".top").text(data[0]);
		$(".middle").text(data[1]);
		$(".low").text(data[2]);
	}
	chkQtype(isType);
}
function clearFm(){
	arrJson=[];
	$("input[name=chk_field1]").attr("checked", true);
	$("input[name=chk_questiontype]").attr("checked", true);
	$("#chkExplain").attr("checked", true); // 풀이보기
	document.fmHTMLs.reset();
//	frmQuestion.reset();
}
function prevStep(){
	$("#step01").css("display","");
	$("#step02").css("display","none");
	$("#htmlstr").val(''); // 문제 유지 하려면 주석 처리...
	$("#divQuestionPool").empty();
	clearFm();
}
function nextStep(){
	$("#qlist_field").css("display", "none");
	var sbj=$("#subject").val();
	if (globalSch=="E" && "|KO|MA|".indexOf(sbj)>0){ // 초등 국수 문항유형 안보임...
	}else{
		chkZero("questiontype");
	}
	if (globalSch=="M" && globalSbj=="EN"){
		$("#qlist_field").css("display", ""); // 영역...
		chkZero("field1");
	}
<% If g_MEM.uid="" Then %>
	alert("문제지 만들기는 로그인 후 사용가능합니다.");
	location.href="/sign/login.asp?retURL="+ location.pathname;
	return;
<% Elseif Not chkIsCerti() Then %>
	menu_o.openAlertPop(false, "", null, 11);
	return;
<% End If %>
	isProc=true; // 출제중 상태...

	checkStr();

	var cntH = $("#cntH");
	var cntM = $("#cntM");
	var cntL = $("#cntL");

	if(cntH.val()=="") cntH.val(0);
	if(cntM.val()=="") cntM.val(0);
	if(cntL.val()=="") cntL.val(0);

	if (cntH.val()==0 && cntM.val()==0 && cntL.val()==0){
		alert("문항 수를 입력해 주세요.");
		return;
	}

	var depth1=$("input[name=depth1_checkbox]");
	var depth2=$("input[name=depth2_checkbox]");
	var depth3=$("input[name=depth3_checkbox]");
	var chk=false;

	for(var i=0; i<depth1.length; i++){
		if(depth1.eq(i).is(":checked")){
			chk=true;
		}
	}
	for(var i=0; i<depth2.length; i++){
		if(depth2.eq(i).is(":checked")){
			chk=true;
		}
	}
	for(var i=0; i<depth3.length; i++){
		if(depth3.eq(i).is(":checked")){
			chk=true;
		}
	}

	if(!chk){
		alert("출제 범위를 선택해주세요.");
		depth1.focus();
		return;
	}

	var servicetargetT = $("#servicetargetT");
	var servicetargetC = $("#servicetargetC");
	var isAll = $("#isAll");
	
	if(servicetargetT.is(":checked") && servicetargetC.is(":checked")){
		frmQuestion.servicetarget.value="TR";
	}else if(servicetargetT.is(":checked")){
		frmQuestion.servicetarget.value="T";
	}else if(servicetargetC.is(":checked")){
		frmQuestion.servicetarget.value="R";
	}else{
		if ($("#classtype").val()=="MI"){
			alert("문항출처를 선택해주십시요.");
			return;
		}
		frmQuestion.servicetarget.value="";
	}

	if(isAll.is(":checked")){
		frmQuestion.isAll.value=isAll.val();
	}else{
		frmQuestion.isAll.value="";
	}

	frmQuestion.cntH.value=cntH.val();
	frmQuestion.cntM.value=cntM.val();
	frmQuestion.cntL.value=cntL.val();

	$("#step01").css("display","none");
	$("#step02").css("display","");
	
	init();
}
function error_popup(qid){
	var xUrl = "error_popup.asp?qid="+qid;
	window.open(xUrl ,"error_popup", "toolbar=no, width=600, height=600, top=0, directories=no, status=no, scrollorbars=yes, resizable=yes"); 
}
function completed(){
	$(".pop_save").css("display","block");
	$(".opacity.type02").css("display","block");
	$("#paperTitle").focus();
}
function completedPop_close(){
	$(".pop_save").css("display","none");
	$(".opacity.type02").css("display","none");
}
function pop_plus(){ // '+문제추가'
	var popPlus=window.open("" ,"pop_plus", "toolbar=no, width=620, height=710, directories=no, status=no, scrollorbars=no, resizable=no"); 

	var xUrl = "plus_popup.asp"
	frmQuestion.target="pop_plus";
	frmQuestion.action=xUrl;
	frmQuestion.submit();
	popPlus.focus();
}
function showLoading(){ // 처리중 이미지...
	$(".pop_save").empty();
	var loadingImg='<img src="/images/common/loading_circle.gif">';
	var loadingTxt='<br /><br /><br /><span style="font-size:13pt;">처리 중입니다. 잠시만 기다려 주십시오.</span>';
	$(".pop_save").html('<div style="text-align:center;height:200px;padding-top:57px;">'+ loadingImg + loadingTxt +'</div>');
}
function completedSubmit(){ // 저장...
	var pageTitle=$.trim($("#paperTitle").val());
	if (pageTitle==""){
		alert("시험지명을 입력하세요.");
		return;
	}
	if (pageTitle.length>30){
		alert("시험지 명은 30자 이내 입니다.");
		return;
	}
	if (confirm("저장 하시겠습니까?")){
		var fm=document.fmExamFin;
		fm.sch_fin.value=globalSch;
		fm.sbj_fin.value=$("#itemTitle").text();
		fm.htmlstr_fin.value=$("#htmlstr").val();
		fm.target="ifrProc";
		fm.action="makeBin.asp";
		fm.submit();
		showLoading();
	}
}

var span = "<span></span>";
$(function(){
	/* Smart Book Left Tab */
	$("ul.list_gnb_tab li:first-child a").addClass("on").append(span);		
	$(".gnb_tab_sub").hide();
	$(".gnb_tab_sub:first").show();

	$("ul.list_gnb_tab li a").click(function(){			
		$("ul.list_gnb_tab li a").removeClass("on");
		$("ul.list_gnb_tab li a span").remove();
		$(this).addClass("on").append(span);			
		$(".gnb_tab_sub").hide();
		var activeTab=$(this).attr("rel");
		$("#"+activeTab).fadeIn();
	});

	$("ul.list_bank_tab li a").append(span);		
	$("ul.list_bank_tab li a:eq(1)").addClass("on"); // default:중등...
	$("ul.list_bank_tab li a:eq(1) span").remove();

	$(".box_smart_sub").hide();
	$(".box_smart_sub:first").show();
	
	$("ul.list_bank_tab li a").click(function(){
		if (!isProc){
			$("ul.list_bank_tab li a").removeClass("on").append(span);
			$(this).addClass("on");
			$(".list_bank_tab li:first-child").css("border-right-width","");
			$(".list_bank_tab li:last-child").css("border-left-width","");		
			$("ul.list_bank_tab li a.on span").remove();
			$(".box_smart_sub").hide();
			var activeTab=$(this).attr("rel");
			$("#"+activeTab).fadeIn();
		}else{
		}
	});
	
		/*num_select_Tab  start*/
	$(".list_bank_tab li > .middle_line").click(function(){
		$(this).addClass("on");
		$(".list_bank_tab li:first-child>a").css("border-right-width","0");
		$(".list_bank_tab li:last-child>a").css("border-left-width","0");
	});				
			
	$(".num_select li").click(function(){
		$(".num_select li").removeClass("on");
		$(this).addClass("on");
		$(".num_select li:nth-child(n+1)").css("border-right-width", "");
		$(".num_select li:nth-child(n+2)").css("border-left-width", "");
		$(".num_select_05").css("border-left-width","");
		var activeTab=$(this).attr("rel");	
	});	
	
	$(".num_select li:nth-child(n+1) a").click(function(){
		$(this).addClass("on");
		/*$(".num_select li:nth-child(n+1) .on").css("border-top-color","#204687");
		$(".num_select li:nth-child(n+1) .on").css("background-color","#204687");*/
	});	
	$(".num_select_01").click(function(){
		$(this).addClass("on");
		$(".num_select_02").css("border-left-width","0");
	});			
	$(".num_select_02").click(function(){
		$(this).addClass("on");
		$(".num_select_01").css("border-right-width","0");
		$(".num_select_02").css("border-left","1px solid #e55c00");
		$(".num_select_03").css("border-left-width","0");
		
	});		
	$(".num_select_03").click(function(){
		$(this).addClass("on");
		$(".num_select_02").css("border-right-width","0");
		$(".num_select_03").css("border-left","1px solid #e55c00");
		$(".num_select_04").css("border-left-width","0");
	});		
	$(".num_select_04").click(function(){
		$(this).addClass("on");
		$(".num_select_03").css("border-right-width","0");
		$(".num_select_04").css("border-left","1px solid #e55c00");
		$(".num_select_05").css("border-left-width","0");
	});			
	$(".num_select_05").click(function(){
		$(this).addClass("on");
		$(".num_select_04").css("border-right-width","0");
		$(".num_select_05").css("border-left","1px solid #e55c00");
	});


		/* Accordion */
		$("ul.list_accordion li").each(function(){
			$(this).children(".con").css('display','none');
			$(this).children(".title").bind("click", function(){
				$(".bd_top_no").css("border-top-width","1px");
				$(".bd_top_no").css("border-top-style","solid");
				$(".bd_top_no").css("border-top-color","red");
				$(this).addClass(function(){						
					if($(this).hasClass("on")){				
						$(this).removeClass("on");
						return "";
					}				
				return "on";
				});			
			$(this).siblings(".con").slideToggle();
			$(this).parent().siblings("li").children(".con").slideUp();
			$(this).parent().siblings("li").find(".on").removeClass("on");
			});
		});
		
			/*education_list_Tab  start*/
			
		$(".education_list li a").click(function(){
			$(".education_list li a").removeClass("on");
			$(this).addClass("on");
			$(".education_list li:nth-child(n+1) a").css("border-right-width", "");
			$(".education_list_05").css("border-left-width","");
			$(".education_list li:nth-child(n+6) a").css("border-right-width", "");
			$(".education_list_10").css("border-left-width","");
			$(".education_list > li > a > span").css("background-color","");					
			$(".education_list > li > a > span").css("background-color","");	
			$(".education_list li:first-child a > span").css("background-color","#d8d8d8");	
			$(".education_list_06 > span").css("background-color","#d8d8d8");
			$(".education_list li a.bd_top").css("border-top-color","#d8d8d8");
			var activeTab=$(this).attr("rel");	
		});	
		
		$(".education_list li:nth-child(n+1) a").click(function(){
			$(this).addClass("on");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		});	
		$(".education_list li:first-child a").click(function(){
			$(this).addClass("on");
		});			
		$(".education_list_02").click(function(){
			$(this).addClass("on");
			$(".education_list li:first-child a").css("border-right-width","0");
		});		
		$(".education_list_03").click(function(){
			$(this).addClass("on");
			$(".education_list_02").css("border-right-width","0");
		});		
		$(".education_list_04").click(function(){
			$(this).addClass("on");
			$(".education_list_03").css("border-right-width","0");
			$(".education_list_05").css("border-left-width","0");
		});	
		$(".education_list.type02 .education_list_04").click(function(){
			$(this).addClass("on");
			$(".education_list_03").css("border-right-width","0");
		});		
		$(".education_list_05").click(function(){
			$(this).addClass("on");
			$(".education_list_04").css("border-right-width","0");
		});					
		$(".education_list_06").click(function(){
			$(this).addClass("on");
			$(".education_list li:first-child a > span").css("background-color","#204687");
		});			
		$(".education_list_07").click(function(){
			$(this).addClass("on");
			$(".education_list_06").css("border-right-width","0");
			$(".education_list_02 > span").css("background-color","#204687");
		});		
		$(".education_list_08").click(function(){
			$(this).addClass("on");
			$(".education_list_07").css("border-right-width","0");
			$(".education_list_03 > span").css("background-color","#204687");
		});		
		$(".education_list_09").click(function(){
			$(this).addClass("on");
			$(".education_list_08").css("border-right-width","0");
			$(".education_list_10").css("border-left-width","0");
			$(".education_list_04 > span").css("background-color","#204687");
		});			
		$(".education_list_10").click(function(){
			$(this).addClass("on");
			$(".education_list_09").css("border-right-width","0");
			$(".education_list_05 > span").css("background-color","#204687");
		});

	$("#wrap").addClass("smart_wrap");
	$(".num3 a").addClass("on");

	var sch = "<%=sch %>";

	if(sch==""){
		setSbj();	
	}else{
		setSbj(sch);
		onSch(sch);
	}
});
function onSch(sch){
	$(".list_bank_tab li a").removeClass("on");
	$(".list_bank_tab li a").append(span);
	if(sch=="E"){
		$(".list_bank_tab li a ").eq(0).addClass("on");
		$(".list_bank_tab li a").eq(0).attr("rel");
		$(".list_bank_tab li a:eq(0) span").remove();
	}else if(sch=="M"){
		$(".list_bank_tab li a").eq(1).addClass("on");
		$(".list_bank_tab li a").eq(1).attr("rel");
		$(".list_bank_tab li a:eq(1) span").remove();
	}else if(sch=="H"){
		$(".list_bank_tab li a").eq(2).addClass("on");
		$(".list_bank_tab li a").eq(2).attr("rel");
		$(".list_bank_tab li a:eq(2) span").remove();
	}
}
function popHelp() {
	var helpPopup = window.open("http://exambank.douclass.com/buildbank/pop_help.htm","helpWin","width=520,height=520,scrollbars=yes,resizable=no");
		if (helpPopup != null)
			helpPopup.focus();
}
function goLab(div){
	if (confirm(procMsg)){
		var url="<%=urlMyLab %>?lab=3";
		var clstype=$("#classtype").val();
		if (div=="scrap"){
			if (clstype=="EL"){
				url+="&labMenu=12&ib_code=3&tab=9"; // 초등
			}else if (clstype=="HI"){
				url+="&labMenu=12&ib_code=5&tab=11"; // 고등
			}else{
				url+="&labMenu=12&ib_code=4&tab=10"; // 중등
			}
		}else{
			if (clstype=="EL"){
				url+="&labMenu=9&ib_code=3&tab=9"; // 초등
			}else if (clstype=="HI"){
				url+="&labMenu=10&ib_code=5&tab=11"; // 고등
			}else{
				url+="&labMenu=10&ib_code=4&tab=10"; // 중등
			}
		}
		location.href=url;
	}
}
function chkZero(chkParam){
	var chks, title;
	if (typeof(chkParam)=="object"){
		chks=$("input[name="+ chkParam.name +"]:checked");
		title=chkParam.title;
	}else{
		chks=$("input[name=chk_"+ chkParam +"]:checked");
		title=chkParam;
	}
	
	if (chks.length<1){
		if (typeof(chkParam)=="object"){
			chkParam.checked=true;
		}else{
			chks.eq(0).checked=true;
		}
		alert("최소 하나는 선택하셔야 합니다..");
	}else{
		var tmp="";
		for (var i=0; i<chks.length; i++){
			if (tmp!="") tmp+=",";
			tmp+=chks.eq(i).val();
		}
		$("#"+ title +"s").val(tmp);
	}
}
function  chkIsChap(){
	var isChap=getRdoIsChap();
	frmQuestion.isChap.value=isChap;

	var list=$("#sectionsList");
	var xUrl="getSections.asp";
	var qry="?classtype="+frmQuestion.classtype.value+"&itbSbj="+frmQuestion.subject.value+"&itbCurri="+frmQuestion.curriculum.value;
	qry+="&itbAuthor="+frmQuestion.author.value+"&itbGrade="+frmQuestion.grade.value+"&itbTerm="+frmQuestion.term.value;
	qry+="&isChap="+isChap;
//	console.log(qry);

	list.load(xUrl + qry);
	showDiffBox(frmQuestion.classtype.value, frmQuestion.subject.value);
//	if (sbj=="M" && arr[idx][0]=="EN"){
	if (isChap=="y"){
		$("#liField1").css("display", "");
	}else{
		$("#liField1").css("display", "none");
	}
}
</script>
	<div class="sub_wrap">
		<div class="box_sub_con clearfix" style="margin-top: 32px;">
			<div class="sub_left">			
				<ul class="list_bank_tab type02 clearfix">
					<li><a href="javascript:setSbj('E');" rel="slnb1">초등</a></li>
					<li><a href="javascript:setSbj('M');" rel="slnb1">중등</a></li>
					<li><a href="javascript:setSbj('H');" rel="slnb1">고등</a></li>
				</ul>
				<div style="width:213px;height:8px;border-left:1px solid #dddddd;border-right:1px solid #dddddd;"></div>
				<div id="slnb1" class="box_smart_sub">
					<ul id="leftListLi" class="list_accordion">
					</ul>
					</ul>
				</div>
<!--#include virtual="/inc/inc_lnb_banner.asp"-->
			</div>
			<div class="sub_right">
				<div class="inner clearfix">
					<div class="title_bank mb30">
						<img id="imgCurri" src="/images/renew/sub/icon_smart_2009.png" class="ml5" />
						<span class="ml2" id="itemTitle"></span>
						<button style="" onClick="goLab();"><p style="width:153px;"><img src="/images/renew/sub/scrap_icon.png" style="padding-right:5px;margin-left: -3px;margin-bottom: 2px;" alt="star_icon"/>시험지관리 바로가기</p></button>
						<button style="margin-right:5px;" onClick="goLab('scrap');"><p style="width:183px;"><img src="/images/renew/sub/scrap_icon.png" style="padding-right:5px;margin-left: -3px;margin-bottom: 2px;" alt="star_icon"/>문항스크랩관리 바로가기</p></button>
					</div>

<!---------------------------------------- step1 화면... -------------------------------------------------->
					<div class="bank_con_wrap mb60" id="step01">
						<ul class="step">
							<li class="step01"><p>Step 1. 출제 문항 검색</p><img src="/images/renew/sub/triangle-right.png" /></li>
							<li class="step02">Step 2. 시험지 편집</li>
						</ul>
						<span class="step_info">평가 및 진단에 필요한 맞춤형 문제지를 직접 만드실 수 있습니다.</span>
						<div class="bank_con mb40">
							<div class="question_origin" style="display:none;">
								<div style="position: relative;top:-22px;display:inline-block;margin-right:8px;">문항 출처</div>
									<ul class="list" style="width:80%;">
										<li id="liChkSrvL"><label><input type="checkbox" name="servicetargetT" id="servicetargetT" value="y" onClick="questionCnt('T');" checked />교사용(교사용CD, 지도서 등)</label></li>
										<li id="liChkSrvC"><label><input type="checkbox" name="servicetargetC" id="servicetargetC" value="y" onClick="questionCnt('C');" checked />참고서(평가문제집, 자습서 등)</label></li>
								</ul>
							</div>	
							<div class="unit_select" id="sectionsList">
							</div>
							<div class="exam_set">
								<div>
									<!--span class="title type02">출제문항수</span>
									<div style="float: right;"><label><input type="checkbox" name="isAll" value="y" id="isAll" checked style="margin-top: -3px;margin-right: 4px;cursor:pointer;" onClick="questionCnt();" /><span style="font-family:'맑은 고딕', 돋움;font-size: 14px;color:#333333;">기 출제되었던 문항 포함하기</span></label></div-->
									<ul class="exam_set_con">
										<li class="check_wrap type01" id="liField1" style="display:none;">
											<span>내용 영역</span>
											<label><input type="checkbox" name="chk_field1" value="'01'" onClick="chkZero(this);" checked title="field1" />어휘</label>
											<label><input type="checkbox" name="chk_field1" value="'02'" onClick="chkZero(this);" checked title="field1" />독해</label>
											<label><input type="checkbox" name="chk_field1" value="'03'" onClick="chkZero(this);" checked title="field1" />문법</label>
											<label><input type="checkbox" name="chk_field1" value="'04'" onClick="chkZero(this);" checked title="field1" />대화</label>
											<!--label><input type="checkbox" value="05" />듣기</label-->
											<label><input type="checkbox" name="chk_field1" value="'06'" onClick="chkZero(this);" checked title="field1" />쓰기</label>
										</li>
										<li class="check_wrap" id="liQuestiontype" style="display:none;">
											<span>문항 유형</span>
											<label><input type="checkbox" name="chk_questiontype" value="'1','2'" onClick="chkZero(this);" checked title="questiontype" />객관식</label>
											<label><input type="checkbox" name="chk_questiontype" value="'3'" onClick="chkZero(this);" checked title="questiontype" />주관식</label>
											<label><input type="checkbox" name="chk_questiontype" value="'4'" onClick="chkZero(this);" checked title="questiontype" />서술형</label>
										</li>
										<li style="padding: 14px 0 15px;">
											<span style="padding-top: 9px;">문항수 선택</span>
											<ul class="num_select">
												<li class="num_select_01" name="num_select" onClick="questionSet(10);"><a href="javascript:void(0);">10</a></li>
												<li class="num_select_02" name="num_select" onClick="questionSet(20);"><a href="javascript:void(0);">20</a></li>
												<li class="num_select_03" name="num_select" onClick="questionSet(25);"><a href="javascript:void(0);">25</a></li>
												<li class="num_select_04" name="num_select" onClick="questionSet(30);"><a href="javascript:void(0);">30</a></li>
												<li class="num_select_05" name="num_select" onClick="questionSet(50);"><a href="javascript:void(0);">50</a></li>
											</ul>
											<!--button type="button" id="btnInputOn" class="btn_text" onClick="inputOn();">직접입력</button-->
											<span class="info">※ 최대 50문항 출제 가능</span>
										</li>
										<li class="last">
											<span id="diffBox" style="display:;">
												<span class="lever_01">난이도 선택</span>											
												<img src="/images/renew/sub/icon_search_top.png" alt="상" class="icon_search_top"/>
												<input type="text" id="cntH" name="cntH" value="" style="background-color:#eee;" maxlength="2" disabled onkeyup="cntQuestionChk()" class="lever_02"/>
												<img src="/images/renew/sub/icon_search_middle.png" alt="중" class="icon_search_middle"/>
												<input type="text" id="cntM" name="cntM" value="" style="background-color:#eee;" maxlength="2" disabled onkeyup="cntQuestionChk()" class="lever_02"/>
												<img src="/images/renew/sub/icon_search_low.png" alt="하" class="icon_search_low"/>
												<input type="text" id="cntL" name="cntL" value="" style="background-color:#eee;margin-right:0" maxlength="2" disabled onkeyup="cntQuestionChk()" class="lever_02 type02"/>
											</span>
											<div id="diffCnt" style="margin:0 auto;display:table;">
												<span class="total_data type01" style="text-align:center;">총</span>
												<input type="text" id="cntQuestion" name="cntQuestion" value="" class="total_data_input" disabled />
												<span class="total_data">문항</span>
												<button class="text_change" id="btnInputOn" onClick="inputOn();"><img src="../images/sub/icon_change.png" alt="되돌리는 아이콘"/>직접입력</button>
											</div>
										</li>
									</ul>
								</div>
							</div>	
						</div>
						<div style="display:table;margin:0 auto; position: relative;">
								<button class="next_btn" onClick="nextStep();">다음 단계<img src="/images/renew/sub/item_next.png" style="margin-left:18px" alt="다음 아이콘"/></button>
								<!--img src="/images/renew/sub/triangle-right02.png" alt="다음버튼" style="position:absolute;top:0;right:-26px;" class="next_btn_tri" onClick="nextStep();" /-->
						</div>
					</div>
<!---------------------------------------- step1 화면... -------------------------------------------------->
<!---------------------------------------- step2 화면... -------------------------------------------------->
					<div class="bank_con_wrap mb60" id="step02" style="display:none;">
						<ul class="step type02">
							<li class="step01 type02">Step 1. 출제 문항 검색<img src="/images/renew/sub/triangle-right03.png" /></li>
							<li class="step02 type02">Step 2. 시험지 편집</li>
						</ul>
						<span class="step_info type02"><div style="width:4px;height:4px;display: inline-block;
margin-bottom: 4px;margin-right: 9px;background:#b7b7b7;"></div>세트문제로 인해 입력하신 문항수와 실제 출제 문항수가 다를 수 있습니다.</span>
						<br/>
						<span class="step_info type02"><div style="width:4px;height:4px;display: inline-block;
margin-bottom: 4px;margin-right: 9px;background:#b7b7b7;"></div>아래 문항 이미지가 깨져보이나요?  <a href="javascript:popHelp();" style="color:#ff6600;">도움말</a> 을 클릭하세요.</span>
						<div class="bank_con type02 mb40">
<!---------------------------------------- html 화면... -------------------------------------------------->
							<div class="question_select">
								<span class="title type03">출제 문항 보기</span>
								<label class="explain_view"><input type="checkbox" id="chkExplain" checked/>풀이보기</label>
								<button type="button" class="preview" onClick="popQPre();"><p style="margin-top: -3px;"><img src="/images/renew/sub/icon_search.png" alt="돋보기 아이콘" style="position: relative;top: -2px;margin-right:3px;">시험지 미리보기</p></button>
								<div class="question_select_con" id="divQuestionPool"><!-----------------------------<div class="question_select_con"> ---------------------------------->
								</div><!-----------------------------<div class="question_select_con"> ---------------------------------->
							</div>

							<div class="question_list">
								<span class="title type03">출제 목록</span>
								<span class="explain">※ 드래그로 순서 변경 가능</span>
								<div class="question_list_con">
									<table>
										<colgroup>
											<col width="47">
											<col width="44">
											<col width="48">
											<col width="67">
										</colgroup>										
										<thead>
											<tr>
												<td>번호</td>
												<td>난이도</td>
												<td>유형</td>
												<td style="text-align:left;padding-left:5px;"><span id="qlist_field">영역</span></td>
											</tr>
										</thead>
									</table>
									<ul class="question_list_info type02 ui-sortable" id="qListUl">	
									</ul>
								</div>
								<div style="clear: both;overflow: hidden;">
									<button type="button" onclick="changOrd();" style="margin-left:5px"><p style="margin-top: -3px;">순서적용</p></button>
									<button type="button" onclick="pop_plus();"><p style="margin-top: -3px;"><img src="/images/renew/sub/icon_plus.png" alt="더하기 아이콘" style="margin-right:6px;vertical-align: baseline;" />문항추가</p></button>
								</div>
							</div>	
							
							<div class="exam_present" id="diffBoxRight">
								<span class="title">출제 현황</span>
								<ul>
									<li>
										<div>
											<img src="/images/renew/sub/icon_search_top.png" alt="상" class="icon_search_top"><span id="qCnt1">0</span>
										</div>
										<div style="margin-left:-4px;">
											<img src="/images/renew/sub/icon_search_middle.png" alt="중" class="icon_search_middle"><span id="qCnt2">0</span>
										</div>
										<div style="width:50px;margin-left:-4px;">
											<img src="/images/renew/sub/icon_search_low.png" alt="하" class="icon_search_low"><span id="qCnt3">0</span>
										</div>
									</li>
									<li class="total"><span>총&nbsp; <span style="color:#ff6600;font-weight:600;" id="qCntTot">0</span> 문항</span></li>
								</ul>
							</div>
						</div>
<!---------------------------------------- html 화면... -------------------------------------------------->

						<div style="margin: 0 auto;display: table;">
							<div style="display: inline-block;">
								<a href="#">
									<!--img src="/images/renew/sub/triangle-left.png" style="margin-right: -4px;z-index: 100;position: relative;top: 0px;" class="prev_btn_tri"/-->
									<button type="button" class="prev_btn" onClick="prevStep();"><img src="/images/renew/sub/item_prev.png" style="margin-right:18px" alt="이전 아이콘"/>이전 단계</button>
								</a>
							</div>
							<button type="button" class="finish_btn" onClick="completed();" >출제 완료</button>
						</div>
					</div>
<!---------------------------------------- step2 화면... -------------------------------------------------->
				</div>
<!--#include virtual='/inc/inc_footer_attention.inc'-->
			</div>
		</div>
<!--#include file="inc_js.asp"-->
<!---------------------------------------- 저장 Popup ... -------------------------------------------------->
		<div class="pop_save" style="width:460px;">
			<div class="save_con_top">
				<span>시험지 저장</span>
				<button type="button" class="popup_close" onClick="completedPop_close();">닫기</button>
			</div>
<form name="fmExamFin" id="fmExamFin" method="post" onkeypress="if(event.keyCode==13){completedSubmit();return false;}">
<input type="hidden" name="sch_fin" id="sch_fin" />
<input type="hidden" name="sbj_fin" id="sbj_fin" />
<input type="hidden" name="htmlstr_fin" id="htmlstr_fin" />
			<div class="pop_save_con">
				<span class="info">
					* 본 자료는 <font color="#204788">나의 연구실 > 문제은행 > 시험지관리</font> 에서 보실 수 있습니다.<br /><br />
					* <font color="#204788">한글 2007  이상</font>에서 더욱 최적화된 시험지를 확인하실 수 있습니다.<br />
					&nbsp; &nbsp;(<font color="#204788">한글97 이하</font> 버전은 지원하지 않습니다.)
				</span>
				<ul class="item_name">
					<li>시험지 명 :</li>
					<li class="text"><input type="text" name="paperTitle" id="paperTitle" /></li>
					<input type="hidden" name="verHWP" id="verHWP" value=1 />
					<!--li class="select">
						<div class="styled-select type05">
							<select name="verHWP" id="verHWP" class="styled-select">
								<option class="select_defalut" value=0>한글97</option>
								<option value=1>한글2007</option>
							</select>	
						</div>
					</li-->
				</ul>
				<span class="info" style="display: block;padding-left: 92px;">(한글, 영문 포함 30자 이내)</span>
				<div class="pop_save_btn">
					<button type="button" onClick="completedSubmit();">저장 완료</button>
					<button type="button" class="popup_cancel" onClick="completedPop_close();">취소</button>
				</div>
			</div>
</form>
		</div>
		<div class="opacity type02"></div>
<!---------------------------------------- 저장 Popup ... -------------------------------------------------->
	</div>
</div>

<!-- //Container -->

<% If sch<>"" And sbj>0 Then ' 170908 과목명 바로가기... %>
<script>
$(document).ready(function(){
	try{
		var lllLen=$("#leftListLi li .title").length;
		var sbjNo=<%=sbj-1 %>;
		var bkNo=<%=bkno-1 %>;
		if (lllLen<sbjNo){ // 없는 과목...
			sbjNo=0;
		}

		setSbj(globalSch,sbjNo);
		setSubSbj(globalSch,sbjNo,bkNo);
	}catch(e){}
});
</script>
<% End If %>

<!--#include virtual='/inc/footer_renewal.inc' -->
<!--#include virtual='/inc/end.inc' -->