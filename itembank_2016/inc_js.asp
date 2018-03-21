<link rel="stylesheet" type="text/css" href="css/examview.css" />
<form name="fmHTMLs" id="fmHTMLs">
	<input type="hidden" name="jsVals" id="jsVals" value="" />
	<input type="hidden" name="htmlstr" id="htmlstr" value="" />
	<input type="hidden" name="useField" id="useField" value="" />
</form>
<script src="/js/jquery-ui.js"></script>
<script src="/js/json2.js"></script>
<script>
var arrDiff=[ // 난이도...
	  ["한글명", "이미지명"]
	, ["상", "top"]
	, ["중", "middle"]
	, ["하", "low"]
]
var arrQtype=[ // 문제 유형..
	  "-" // '0'=''
	, "객관식"	// '1'
	, "객관식"	// '2'
	, "주관식"	// '3'
	, "서술형"	// '4'
];
var isExplainChked=true; // 풀이보기...
function init(){
	var xUrl="getList.asp";

	$.ajax({
		url:xUrl,
		type:"POST",
		dataType:"json",
		data:$("#frmQuestion").serialize(),
//		contentType: 'application/x-www-form-urlencoded; charset=UTF-8', 
		success:function(data){
//			console.log(typeof(data));
//			console.log(data["testStr"]);

			var qCnt=parseInt(data["qCnt"]); // 순서변경 가능한 문제 수(세트문항은 1개로 처리)
			var tmp="", arrOrd=[];
			for (var i=1; i<=qCnt; i++){ // 단원순 정렬용 배열...
				var objQ=data["q"+i];
				if (typeof(objQ)=="object"){
					tmp=objQ["d1"].split("|"); // d1은 무조건 존재...
				}else{
					tmp=objQ.split("|");
				}
				arrOrd[i-1]=[tmp[4]+tmp[6], objQ];
			}
			arrOrd.sort();
			for (i=1; i<=qCnt; i++){
				data["q"+ i]=arrOrd[i-1][1];
			}

			$("#jsVals").val(JSON.stringify(data)); // json to string...
			getJson2Arr(data);
		},
		error:function(request,status,error){
			$("#qListUl").empty();			
			if (request.status==200){
//				console.log(request.responseText);
//				alert(request.responseText);
				alert("에러가 발생했습니다.");
				prevStep();
			}else{
				console.log("error init()...");
				console.log(typeof(request.responseText));
				console.log("code:"+request.status);
				console.log("message:"+request.responseText);
				console.log("error:"+error);
			}
		}
	});
}
var arrJson=[]; // 순서변경용...
var arrCnt=[0, 0, 0, 0]; // total, high, middle, low 문제수...
function showCnt(){
	var totCnt=0;
	for (var i=1; i<arrCnt.length; i++){
		$("#qCnt"+ i).text(arrCnt[i]);
		totCnt+=arrCnt[i];
	}
	$("#qCntTot").text(totCnt);
}
function getJson2Arr(data){ // json --> array (순서변경 대비...)
	var qCnt=parseInt(data["qCnt"]); // 순서변경 가능한 문제 수(세트문항은 1개로 처리)
	var arrTmpcnt=[0,0,0,0]; // 표시 문항 수 재계산...
	for (var i=1; i<=qCnt; i++){
		var qNo="q"+i;
		var objQ=data[qNo];
		arrJson[i-1]=objQ;
		if (typeof(objQ)=="object"){
//			console.log(objQ["dCnt"]);
//			console.log(JSON.stringify(objQ));
			for (j=1; j<=objQ["dCnt"]; j++){
				var tmpD=objQ["d"+ j].split("|");
				arrTmpcnt[tmpD[2]]++;
			}
		}else if (typeof(objQ)!="undefined"){
//			console.log("objQ : "+ objQ);
			var tmpD=objQ.split("|");
			arrTmpcnt[tmpD[2]]++;
		}else{
//			console.log(typeof(objQ));
		}
	}
	arrTmpcnt[0]=arrTmpcnt[1]+arrTmpcnt[2]+arrTmpcnt[3];
	arrCnt=arrTmpcnt;
/*	arrCnt[1]=parseInt(data["cntH"]);
	arrCnt[2]=parseInt(data["cntM"]);
	arrCnt[3]=parseInt(data["cntL"]);
	arrCnt[0]=arrCnt[1]+arrCnt[2]+arrCnt[3];*/

	showListByArr();
	showCnt();
}
function showListByArr(){ // array로 출제목록 표시...
	var i, j, k=1, tmp="";
	$("#divQuestionPool").empty();
	var htmlstr="";
	for (i=0; i<arrJson.length; i++){
		var ele=arrJson[i];
		if (typeof(ele)=="string"){ // 지문無 문항
			tmp+=getList(k, ele, i);
			htmlstr=concatComma("q", htmlstr, ele);
			k++;
		}else if (typeof(ele)=="object"){ // 지문有 문항(세트문항)
			var dCnt=ele["dCnt"];
			var tmp1="";
			htmlstr=concatComma("d", htmlstr, ele["desc_id"] +"|"+ ele["desc_file"] +"|"+ dCnt);
			for (var j=1; j<=dCnt; j++){
				var objD=ele["d"+ j];
				tmp1+=getList(k, objD, "");
				htmlstr=concatComma("q", htmlstr, objD);
				k++;
			}
			tmp+='<li id="lineID_'+ i +'"><ul>'+ tmp1 +'</ul></li>';
		}
	}
	if (tmp!=""){
		$("#qListUl").html('');
		$("#qListUl").html(tmp);
	}
	$("#htmlstr").val(htmlstr);
	getHTMLs();
}
function getHTMLs(){ // html가져오기
	var isChap=getRdoIsChap();
	$("#useField").val(isChap);
	$.ajax({
		type:"POST",
		url:"makeHTML.asp",
		data:$("#fmHTMLs").serialize(),
		dataType:"html",
		success:function(data){
			$("#divQuestionPool").empty();
			$("#divQuestionPool").html(data);
			if (!isExplainChked){
				$(".qExplain").css("display", "none");
			}
		}
	});
}
function concatComma(qd, tgt, src){ // ,로 연결해서 string만들기...
	var tmp="";
	if (tgt!="") tgt+=",";
	tmp+=tgt + qd +"|"+ src;
	return tmp;
}
function popQPre(mode){ // 문제지 표시... 2단구성?
	var _examPreview=window.open("exam_preview.asp", "_examPreview", "width=1160,height=768");
}
function changOrd(){ // '순서변경' 클릭시...
	var tmpli=$("#qListUl li[id^='lineID_']");
	var dftStr="", tmpStr="", tmpArr=[], idx;
	var jsVals=$("#jsVals").val();
	var data=jQuery.parseJSON(jsVals); // string to json...
	for (var i=0; i<tmpli.length; i++){
		if (i>0){
			dftStr+=",";
			tmpStr+=",";
		}
		dftStr+=i; // 0,1,...
		idx=tmpli.eq(i).attr("id").replace("lineID_", "");
		tmpStr+=idx;
		tmpArr[i]=arrJson[idx];

		data["q"+ (i+1)]=tmpArr[i];
	}
	if (dftStr!=tmpStr){
		if (confirm("현재 순서로 적용 하시겠습니까?")){
			$("#jsVals").val(JSON.stringify(data));
			arrJson=tmpArr;
			showListByArr();
		}
	}else{
		alert("순서가 동일 합니다.");
	}
}

var tmpLine='<li$lineID$ onClick="goAnchor($anchorNo$);"><div class="line"><div class="num">$qNo$</div><img src="/images/renew/sub/icon_search_$diffImg$.png" alt="$diffHan$" class="level"/><div class="type">$qType$</div>$icon$</div></li>\n'; // replace용 template
function goAnchor(anchor){
	try{
		location.hash="qid_"+ anchor;
//		var pos=$("#qid_"+ anchor).offset();
//		$("#divQuestionPool").animate({scrollTop:pos.top}, 500);
//		console.log(pos.top);
	}catch(e){}
}
function getList(qNo, qStr, lineID){ // 출제목록 html. q_id | q_type | q_diff | q_file | unitcode | a_file | field1 형식...
	var arr=qStr.split("|");
	var q_id=arr[0];
	var q_type=arr[1];
	var q_diff=arr[2];
	var q_file=arr[3];
	var field1="";
	if (globalSch=="M" && globalSbj=="EN"){
		field1='<img src="/images/renew/sub/img_item_'+ arr[6] +'.png" class="item_subj">';
	}

	var li=tmpLine.replace("$anchorNo$", q_id);
	li=li.replace("$qNo$", qNo);
	if (typeof(lineID)=="number"){
		lineID=" id=\"lineID_"+ lineID +"\"";
	}
	li=li.replace("$lineID$", lineID);	
	li=li.replace("$qType$", arrQtype[q_type]);
	li=li.replace("$diffHan$", arrDiff[q_diff][0]);
	li=li.split("$diffImg$").join(arrDiff[q_diff][1]); // img/class
	li=li.replace("$icon$", field1);

	return li;
}
$(document).ready(function(){
	$(function(){ // drag&drop...
		$( "#qListUl" ).sortable();
		$( "#qListUl" ).disableSelection();
	});
});

function qChange(qStr){ // 문제교체
	var htmls=$("#htmlstr").val();
//	console.log("qChange(qStr) htmls : "+ htmls);
//	console.log("qChange(qStr) jsVals : "+ $("#jsVals").val());
//	var htmls='d|1008542|1008542_J.hwp|4,q|1008542|0|2|1008542_Q.hwp|EL11KO09TOT040000|1008542_A.hwp,q|1008543|0|2|1008543_Q.hwp|EL11KO09TOT040000|1008543_A.hwp,q|1008544|0|2|1008544_Q.hwp|EL11KO09TOT040000|1008544_A.hwp,q|1008545|0|2|1008545_Q.hwp|EL11KO09TOT040000|1008545_A.hwp,q|1008941|0|2|1008941_Q.hwp|EL11KO09TOT040000|1008941_A.hwp,q|1008843|0|2|1008843_Q.hwp|EL11KO09TOT040000|1008843_A.hwp';
//	qStr='q|1008843|0|2|1008843_Q.hwp|EL11KO09TOT040000|1008843_A.hwp'; // q 0
//	qStr='q|1008941|0|2|1008941_Q.hwp|EL11KO09TOT040000|1008941_A.hwp'; // q 1
//	qStr='q|1008542|0|2|1008542_Q.hwp|EL11KO09TOT040000|1008542_A.hwp'; // d

	var arr=htmls.split(",");
	var pos=-1, tmp, dCnt, chgType="q";
	for (var i=0; i<arr.length; i++){
		if (arr[i]==qStr){
			pos=i;
			if (i>0){
				tmp=arr[pos-1].split("|"); // 세트문항의 첫번째만 '교체'가 있으므로...
				if (tmp[0]=="d"){ // 세트문항
					pos=pos-1;
					qStr=arr[pos];
					chgType="d";
				}
			}
			break;
		}
	}

	if (pos>-1){ // 일치하는게 있는 경우...
		tmp="", dCnt=0, tmpArrCnt=[0, 0, 0, 0], tmpNum=-1;
		for (i=0; i<arr.length; i++){
			var letter=arr[i].substr(0,1);
			var arrTmp=arr[i].split("|");

			if (chgType=="d" && i==pos) dCnt=parseInt(arrTmp[3]) + 1;
			if (i!=pos && chgType=="q" && letter=="q" && dCnt==0){
				tmpArrCnt[parseInt(arrTmp[3])]++; // 해당난이도 갯수 증가
			}
			if (chgType=="d" && dCnt==0 && letter=="q"){
				tmpArrCnt[parseInt(arrTmp[3])]++; // 해당난이도 갯수 증가
			}

			if (letter=="d" || dCnt==0){ // 지문 or 일반문항...
				if (i!=pos){
					if (tmp!="") tmp+=",";
					tmp+=arr[i];
				}
			}
			if (dCnt>0) dCnt--;
		}

		if (tmp!=""){
			$("#htmlstr_chg").val(tmp);
			$("#qStrChg").val(qStr);

			var fm=document.frmQuestion;
			fm.cntH.value=tmpArrCnt[1];
			fm.cntM.value=tmpArrCnt[2];
			fm.cntL.value=tmpArrCnt[3];

			var xUrl="getListChange.asp";
			$.ajax({
				url:xUrl,
				type:"POST",
				dataType:"html",
				data:$("#frmQuestion").serialize(),
//				contentType: 'application/x-www-form-urlencoded; charset=UTF-8', 
				success:function(data){
//					console.log(data);
					getChg(qStr, data);
				},
				error:function(request,status,error){
					console.log("error qChange("+ qStr +")...");
					console.log(typeof(request.responseText));
					console.log("code:"+request.status);
					console.log("message:"+request.responseText);
					console.log("error:"+error);
				}
			});
		}
	}
}
function getChg(qStr, cStr){ // 문제교체...
	if ($.trim(cStr)==""){
		alert("해당하는 문항이 없습니다.");
		return;
	}
	var jsVals=$("#jsVals").val();
	jsVals=jsVals.split("\\").join("/");
	qStr=qStr.split("\\").join("/");
	cStr=cStr.split("\\").join("/");

	if (qStr.substr(0,1)=="q"){
		jsVals=jsVals.replace(qStr.substr(2), cStr.substr(2));
		var data=jQuery.parseJSON(jsVals); // string to json...
		var tmp1=qStr.split("|")[3];
		switch (parseInt(tmp1)){
			case 1:	data["cntH"]++;break;
			case 2:	data["cntM"]++;break;
			case 3:	data["cntL"]++;break;
		}
	}else{
		var tmp1=qStr.split("|");
		var tmp2=jsVals.split('"desc_id":'+ tmp1[1]);
		tmp1=tmp2[0].split('":{"');
		tmp2=tmp1[tmp1.length-2].split(',"');

		var qNo=tmp2[tmp2.length-1]; // 몇번째 세트문항인지...
		var data=jQuery.parseJSON(jsVals); // string to json...
		data[qNo]=jQuery.parseJSON(cStr);

		var fm=document.frmQuestion;
		var tmpArrCnt=[0, parseInt(fm.cntH.value),  parseInt(fm.cntM.value),  parseInt(fm.cntL.value)];

		tmp1=cStr.split('":"');
		for (var i=0; i<tmp1.length; i++){
			if (tmp1[i].indexOf("|")>0){
				var tmp2=tmp1[i].split("|")[2]; // 난이도...
				tmpArrCnt[parseInt(tmp2)]++;
			}
		}
		var sumArrCnt=tmpArrCnt.reduce(function(a, b) { return a + b; }, 0); // array의 합...

		data["qCnt"]=sumArrCnt;
		data["cntH"]=tmpArrCnt[1];
		data["cntM"]=tmpArrCnt[2];
		data["cntL"]=tmpArrCnt[3];

		fm.cntH.value=tmpArrCnt[1];
		fm.cntM.value=tmpArrCnt[2];
		fm.cntL.value=tmpArrCnt[3];
	}
	$("#jsVals").val(JSON.stringify(data)); // json to string...
//	console.log("qChange(qStr) jsVals : "+ $("#jsVals").val());
	getJson2Arr(data);
}
$("#chkExplain").change(function(e){ // 풀이보기...
	if (this.checked){
		isExplainChked=true;
		$(".qExplain").css("display", "");
	}else{
		isExplainChked=false;
		$(".qExplain").css("display", "none");
	}	
});
</script>