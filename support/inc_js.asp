<script type="text/javascript">
function setParam(param, val){ // fm 값 변경
	var ele=$("#fm_"+ param);
	if (ele.length>0){
		ele.val(val);
	}else{
		alert(param +"이 없습니다.");
	}
}
function goPage(seq, sbj, isEvalVal){ // 이동...
	if (typeof(sbj)!="undefined"){
		if (sbj!="recommand"){ // 161018 창체의 '과목별 추천사이트' 이동...
			setParam("sbj", sbj.substring(sbj.length-1, sbj.length));
		}else{
			setParam("sbj", sbj);
		}
	}
	setParam("book_seq", seq);
	if (seq!=<%=book_seq %>){
//		setParam("data1", "S");
		setParam("data2", "<%'=data2 ' 170412 무조건 '전체'로 처리... %>");
		setParam("unit", "01");
		setParam("page", 1);
	}
	var fm=document.fmSupport;
	if (isEvalVal>0){
		fm.action="<%=evalAsp %>";
	}else{
		if ($("#fm_data1").val()=="S" || sbj=="recommand"){
			fm.action="<%=classAsp %>";
		}else{
			fm.action="<%=evalAsp %>";
		}
	}
//	fm.method="post";
	fm.submit();
}
function setSch(param){
	setParam("data1", "S");
	setParam("page", 1);
	document.location.href="<%=classAsp %>?sch="+ param;
}
function setChapter(chp){
	setParam("unit", chp);
	setParam("page", 1);
	goPage(<%=book_seq %>);
}
function setData1(param){
	setParam("data1", param);
	setParam("page", 1);
	goPage(<%=book_seq %>);
}
function setData2(param){
	setParam("data2", param);
	setParam("page", 1);
	if (param=="Multimedia"){
		$("#fm_mmType").val($("#mmSel").val());
	}else{
		$("#fm_mmType").val('');
	}
	goPage(<%=book_seq %>);
}
function setPage(pg){
	setParam("page", pg);
	goPage(<%=book_seq %>);
}

function goDN(dnIdxs, filePath, type, isNewPaper){
	if(mem_o.gotoLogin()) return;
<% If g_MEM.certify="G" or g_MEM.certify="N" Then %>
	if (mem_o.chkTeacher()){
		if (dnIdxs==""){
			alert("다운로드 할 자료를 선택 해주세요.");
		}else{
<%
	Dim userAgent:userAgent=LCase(Request.ServerVariables("HTTP_USER_AGENT"))
	Dim isAndroid:isAndroid=InStr(userAgent, "android")>0
	Dim isIOS:isIOS=InStr(userAgent, "like mac os x")>0 And (InStr(userAgent, "iphone")>0 Or InStr(userAgent, "ipod")>0 Or InStr(userAgent, "ipad")>0)

	If (isIOS Or isAndroid)  Then
%>
			document.location.href="<%=urlDc %>"+ filePath;	
<%	Else %>
			if (typeof(type)=="undefined" && typeof(isNewPaper)=="undefined"){
				menu_o.uc_idx=dnIdxs;
				menu_o.download();
			}else{
				var dnUrl="/down/downItbDn.asp?itb_seq="+dnIdxs+"&itb_type="+type+"&isNewPaper="+isNewPaper;
				if (type==""){
					document.ifrProc.location.href=dnUrl;
				}else{
					document.ifrSupportH.location.href=dnUrl;
				}
			}
<%
	End If
%>
		}
	}
<% Else %>
//	alert("인증받은 선생님만 다운로드 가능합니다!");
	menu_o.openAlertPop(null, null, null, 11);
<% End If %>
}
function chkSingle(obj){
	var seType=obj.name.replace("chkSingle", "");
	if (!obj.checked) $("input[name=chkAll"+ seType +"]").attr("checked", false);
}
function chkAll(obj, seType){
	$("input[name=chkAll"+ seType +"]").attr("checked", obj.checked);
	$("input[name=chkSingle"+ seType +"]").attr("checked", $("#chkAll"+ seType).is(":checked"));
}
function chkVals(seType){
	var vals="";
	$("input[name=chkSingle"+ seType +"]").each(function(){
		 if ($(this).is(":checked")){
			 if (vals!="") vals+=",";
			 vals+=this.value;
		 }
	});
	return vals;
}
function chkLoop(chkname){
	var chks="";
	for(var i=0; i<$('.'+chkname).length; i++){
		if (chks!="") chks += ",";
		chks += $('.'+chkname).eq(i).val();
	}
	return chks;
}
function newScrap(seqs, sposition){
}
function scrapMulti(seType, isNewPaper){
	if (typeof(isNewPaper)=="undefined"){
		goScrap(chkVals(seType));
	}else{
		gotoScrap(chkVals(seType), isNewPaper);
	}
}
function gotoScrap(itb_seq, isNewPaper){
	if(mem_o.gotoLogin()) return;
<% If chkIsCerti() Then %>
	var itb_seqs="";
	if (typeof(itb_seq)=="undefined"){
		itb_seqs=chkLoop("chkItb");
	}else{
		itb_seqs=itb_seq;
	}

	if (itb_seqs == ""){
		alert("스크랩할 문제지를 선택하세요.");
		return false;
	}

	if (!isNewPaper){
		var fm=document.fmItbList;
		fm.itb_seqs.value=itb_seqs;
		fm.target="ifrProc";
		fm.action="/itembank/itbProc.asp?itb_seqs="+ itb_seqs +"&func=scrap";
	}else{
		var fm=document.frmScrap;
		fm.mode.value=itb_seqs;
		fm.sPosition.value=10; // TP_paper사용...
		fm.scIdxs.value=itb_seqs;
		fm.target.value="ifrProc";
	}
	fm.submit(); 
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
<% End If %>
}
function processComplete(func, rtn){
	if (func == "scrap"){
		pop_o.openConfirmPop( "", rtn,	
			function(){
//				if (confirm("나의 문제은행 페이지로 이동 하시겠습니까?")){
					location.href = "/myLab/?lab=3&labMenu=4"; 
//				}
			}
		);
	}
}
function goDNMulti(seType){
	if(mem_o.gotoLogin()) return;
<% If chkIsCerti() Then %>
	var chks=chkVals(seType);
	if (chks==""){
		alert("다운로드 할 자료를 선택해 주세요.");
	}else{
		xdown.init();
		var dUrl="/down/download_multi_renew.asp?callBy=page&menuDiv=support&seqs="+ chks;
		if (!isNaN(seType)){
			var isNewPaper=false;
			if ($("#isNewPaper").length>0){
				isNewPaper=$("#isNewPaper").val();
			}
			dUrl="/down/download_multi_itb.asp?callBy=page&menuDiv=itb&isNewPaper="+ isNewPaper +"&itb_seqs="+ chks;
		}
//		console.log(dUrl);
//		document.getElementById("ifrProc").src=dUrl;
		$("#ifrProc").attr("src", dUrl);
	}
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
<% End If %>
}
var totDnCnt=0; // 비ie multidownload 총 갯수...
var curDnCnt=0; // 비ie multidownload download 갯수...
function goDNMultiChrom(seType){ // 비ie multidownload...
	if(mem_o.gotoLogin()) return;

	var chks=$("input[name=chkSingle"+ seType +"]:checked");
	totDnCnt=chks.length;
	if (totDnCnt<1){
		alert("다운로드 할 자료를 선택해 주세요.");
	}else{
		var dnNum=0;
		chks.each(function(){
			 if (curDnCnt<totDnCnt && curDnCnt<=dnNum){
<%	If data1="S" Then %>
				goDN(this.value);
<%	ElseIf data1="T" Then %>
//				goDN(this.value, filePath, type, isNewPaper)
				var btnItb="btnItb"+ this.value;
				if ($("#"+ btnItb).length>0){
					var dnItb=($("#"+ btnItb).attr("onclick"));
					eval(dnItb);
				}
				var btnItbA="btnItbA"+ this.value;
				if ($("#"+ btnItbA).length>0){
					var dnItbA=($("#"+ btnItbA).attr("onclick"));
					eval(dnItbA);
				}
<%	End If %>
				curDnCnt++;
				setTimeout(function(){goDNMultiChrom(seType)}, 1000);
				return false;
			 }
			dnNum++;
			if (dnNum==totDnCnt) curDnCnt=0; // 모두 다운로드 했으면 초기화...
		});
	}
}
function goDnSingleCmn(filePath){
	if(mem_o.gotoLogin()) return;

	document.location.href="http://www.douclass.com"+ filePath;	
}

$(function(){
	//교수학습자료 LNB -> 중등 탭
	$(".list_smart_tab.type03 li:first-child+li a.on").each(function(){
		$(".list_smart_tab.type03 li:first-child a").css("border-right", "0");	
		$(".list_smart_tab.type03 li:first-child+li a.on").css("width", "71px");
		$(".list_smart_tab.type03 li:first-child+li+li a").css("border-left", "0");
	});
});
</script>

<% ' 초등용 script... %>
<script>
function showSbjTitleE(idx, grd, ssn){ // 과목 클릭시 목록 보이기...
	$("ul.list_accordion li a").removeClass("on");
	$("ul.list_accordion li div").empty();
	$("#li_sbj"+ idx +" a").addClass("on");	
	$("#li_sbj"+ idx).append(getSbjItemE(idx, -1));
	setParam("grade", grd);
	setParam("season", ssn);
}
function getSbjItemE(idx, seq){ // 과목에 속한 교재 목록...
	var tmp="";
	var curri="";
	tmp+='<div class="con">';
	tmp+='<ul class="list_accordion_sub">';
	if (idx<gnbItbDnSbjListE0.length){ // ' 161018 창체의 '과목별 추천사이트' 이동...
		var arr=gnbItbDnSbjListE0[idx];
		for (var i=0; i<arr.length; i++){
			var isEvalVal=0;
			var arrSeq=arr[i][5];
			if (typeof(arr[i][8])!="undefined"){
				arrSeq=arr[i][8];
				isEvalVal=arrSeq;
			}
			if (curri!=arr[i][0]){
				curri=arr[i][0];
				tmp+='<li class="divi_tit_icon divi_20'+ curri +'"><img src="/images/renew/sub/icon_tit_'+ curri +'.png" /></li>';
			}
			tmp+='<li><span></span><a';
			if ((idx==0 && seq==0 & i==0) || seq==arrSeq || <%=book_seq %>==arrSeq){
				tmp+=' style="font-weight:bold;color:#0e77d9;"';
			}else{
				tmp+=' onClick="goPage('+ arrSeq +', \''+ arr[i][1] +'\', '+ isEvalVal +');" style="cursor:pointer;"';
			}
			tmp+='>'+ arr[i][6];
//			if (arr[i][0]=="15"){ // if (arr[i][0]!="09"){
//				tmp+=' <img src="/images/renew/sub/icon_curri_'+ arr[i][0] +'.png" />';
//			}
			tmp+='</a></li>';
		}
	}else{ // ' 161018 창체의 '과목별 추천사이트' 이동...
		tmp+='<li><span></span><a';
		if ("<%=sbj %>"=="recommand"){
			tmp+=' style="font-weight:bold;color:#0e77d9;"';
		}else{
			tmp+=' onClick="goPage(0, \'recommand\', 0);" style="cursor:pointer;"';
		}
		tmp+='>과목별 추천사이트</a></li>';
	}
	tmp+='</ul>';
	tmp+='</div>';
	
	return tmp;
}
</script>

<% ' 중등/고등용 script... %>
<script>
var thisSbj=arrSbj<%=sch %>;
function getSbjTitle(sbj){
	var tmp="";
	if (isNaN(sbj)){
		for (var i=0; i<thisSbj.length; i++){
			if (sbj==thisSbj[i][0]){
				tmp=thisSbj[i][1];
				break;
			}
		}
	}else{
		switch (sbj){
			case "0": tmp="선택"; break;
			case "1": tmp="재량"; break;
		}
	}

	return tmp;
}
function showSbjTitle(idx, sbj){ // 과목 클릭시 목록 보이기...
	$("ul.list_accordion li a").removeClass("on");
	$("ul.list_accordion li div").empty();
	$("#li_sbj"+ idx +" a").addClass("on");	
	getSbjItem(sbj, idx, -1);
	setParam("sbj", sbj);
}
function getSbjItem(sbj, idx){ // 과목에 속한 교재 목록...
	var xUrl="getLeft.asp?sch=<%=sch %>&sbj="+ sbj +"&book_seq="+ $("#fm_book_seq").val();
	$.ajax({
		url:xUrl,
		type:"POST",
		dataType:"html",
		success:function(data){
			$("#li_sbj"+ idx).append(data);
		}
	});
}

function fncPreview(ucIdx, fType){ // 미리보기...(교수학습자료>단원별 멀티미디어 자료)
	if (fType=="media"){ // 멀티미디어
		try{
			menu_o.openPreViewCore(ucIdx, null, null, "spt");
		}catch(e){}
		menu_o.setDisable(false, "wrap");
	}
}
</script>
<iframe name="ifrSupportH" id="ifrSupportH" width=0 height=0></iframe><% ' download페이지에서 history.back방지용... %>