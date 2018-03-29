<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="support_dataEval"
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual='/inc/topmenu_renewal.inc' -->
<%
Dim sql, oRS, ii, wquery, ordBy, cols
Dim sch, sbj, data1, data2, unit, book_seq, schNo, grade, season, stepE, page
Dim classAsp:classAsp="index.asp" ' 수업자료
Dim evalAsp:evalAsp="dataEval.asp" ' 평가자료
Dim thisAsp:thisAsp=evalAsp
Dim arrChp, divChpNum

sch=util_nte(request("sch"), "M", "string") ' 학교
sbj=util_nte(request("sbj"), "", "string") ' 과목
book_seq=util_nte(request("book_seq"), 0, "int") ' 교재
data1="T" ' util_nte(request("data1"), "S", "string") ' 자료 - 수업자료:S, 평가자료:T
data2=util_nte(request("data2"), "", "string") ' 수업자료 - 공통:Common, 단원별:Suppor, 멀티미디어:Multimedia, 평가자료 - 전체:"", 나머지 숫자 타입...
unit=util_nte(request("unit"), "01", "string") ' 단원
grade=util_nte(request("grade"), 1, "int") ' 학년
season=util_nte(request("season"), 1, "int") ' 학기

page=util_nte(request("page"), 1, "int")

If sbj="" Then
	sbj="K"
End If
If sch="E" Then 
	schNo=0
	If book_seq=0 Then 
		book_seq=226 ' 국어1-1 ...
	End If 
ElseIf sch="M" Then
	schNo=1
	If book_seq=0 Then 
		book_seq=115 ' 국어① (전경원) ...
	End If 
ElseIf sch="H" Then 
	schNo=2
	If book_seq=0 Then 
		book_seq=170 ' 국어Ⅰ ...
	End If 
End If 

If data1="S" And data2="" Then ' 수업자료:단원별 수업자료 default
	data2="Support"
ElseIf data1="T" And data2<>"" And Not isNumeric(data2) Then ' 평가자료:전체 default
	data2=""
End If 
%>
<script language="JavaScript" type="text/javascript" src="/js/admin_itembank.js"></script>
<script language="JavaScript" type="text/javascript" src="/support/js/itbDnSbjList<%=sch %>.js?unic=<%=util_unic() %>"></script>
<script language="JavaScript" type="text/javascript" src="js/itbDnCmn<%=sch %>.js?unic=<%=util_unic() %>"></script>
<script language="JavaScript" type="text/javascript" src="/itembank/js/popup.js"></script>
<!--#include file="inc_js.asp"-->

<form name="fmSupport" id="fmSupport">
<input type="hidden" name="sch" id="fm_sch" value="<%=sch %>" />
<input type="hidden" name="sbj" id="fm_sbj" value="<%=sbj %>" />
<input type="hidden" name="grade" id="fm_grade" value="<%=grade %>" />
<input type="hidden" name="season" id="fm_season" value="<%=season %>" />
<input type="hidden" name="book_seq" id="fm_book_seq" value="<%=book_seq %>" />
<input type="hidden" name="data1" id="fm_data1" value="<%=data1 %>" />
<input type="hidden" name="data2" id="fm_data2" value="<%=data2 %>" />
<input type="hidden" name="unit" id="fm_unit" value="<%=unit %>" />
<input type="hidden" name="page" id="fm_page" value="<%=page %>" />
</form>

	<div class="sub_wrap">
		<div class="box_sub_con type04 clearfix">
			<div class="sub_left">				
				<ul class="list_smart_tab type03 clearfix">
					<li><a href="javascript:setSch('E');" rel="slnb0"<% If sch="E" Then %> class="on"<% End If %>>초등</a></li>
					<li><a href="javascript:setSch('M');" rel="slnb1" class="middle_line<% If sch="M" Then %> on<% End If %>">중등</a></li>
					<li><a href="javascript:setSch('H');" rel="slnb2"<% If sch="H" Then %> class="on"<% End If %>>고등</a></li>
				</ul>
				<div style="width:213px;height:8px;border-left:1px solid #dddddd;border-right:1px solid #dddddd;"></div>
				<div id="slnb<%=schNo %>" class="box_smart_sub">
					<ul class="list_accordion">
<%
If sch="E" Then
	stepE=grade + season + (grade-3) + 1
Else
	If sch="M" And sbj="C" Then ' 사회...
		stepE="O"
	ElseIf sch="M" And sbj="R" Then ' 도덕...
		stepE="D"
'	ElseIf sch="M" And (sbj="0" Or sbj="I" Or sbj="N") Then ' 선택...
'		stepE="I"
	Else
		stepE=sbj
	End If 
End If 
%>
<script>
function showSbjTitleEval(idx, grd, ssn){ // 과목 클릭시 목록 보이기...
	$("ul.list_accordion li a").removeClass("on");
	$("ul.list_accordion li div").empty();
	$("#li_sbj"+ idx +" a").addClass("on");	
	$("#li_sbj"+ idx).append(getSbjItemEval(idx, -1));
	if (typeof(grd)!="undefined" && typeof(ssn)!="undefined"){
		setParam("grade", grd);
		setParam("season", ssn);
	}
}
function getSbjItemEval(idx, seq){ // 과목에 속한 교재 목록...
	var tmp="";
	var curri="";
	tmp+='<div class="con">';
	tmp+='<ul class="list_accordion_sub">';
	if (idx<itbDnSbjList<%=sch %>.length){ // ' 161018 창체의 '과목별 추천사이트' 이동...
		var arr=itbDnSbjList<%=sch %>[idx];
		for (var i=0; i<arr.length; i++){
			var arrSeq=arr[i][5];
			if (curri!=arr[i][0]){
				curri=arr[i][0];
				tmp+='<li class="divi_tit_icon divi_20'+ curri +'"><img src="/images/renew/sub/icon_tit_'+ curri +'.png" /></li>';
			}
			tmp+='<li><span></span><a';
			if ((idx==0 && seq==0 & i==0) || seq==arrSeq || <%=book_seq %>==arrSeq){
				tmp+=' style="font-weight:bold;color:#0e77d9;"';
				curItbIdx=i;
			}else{
				tmp+=' onClick="goPage('+ arrSeq +', \''+ arr[i][1] +'\');" style="cursor:pointer;"';
			}
			tmp+='>'+ arr[i][6];
//			if (arr[i][0]!="09"){
//				tmp+=' <img src="/images/renew/sub/icon_curri_'+ arr[i][0] +'.png" />';
//			}
			tmp+='</a></li>';
		}
	}else{ // ' 161018 창체의 '과목별 추천사이트' 이동...
		tmp+='<li><span></span><a';
		if ("<%=sbj %>"=="recommand"){
			tmp+=' style="font-weight:bold;color:#0e77d9;"';
			curItbIdx=i;
		}else{
			tmp+=' onClick="goPage(0, \'recommand\');" style="cursor:pointer;"';
		}
		tmp+='>과목별 추천사이트</a></li>';
	}
	tmp+='</ul>';
	tmp+='</div>';
	
	return tmp;
}
try{
	var sbjI=0;
	var curItbIdx=0;
	var arrSch=itbDnSbj<%=sch %>;
	for (var i=0; i<arrSch.length; i++){
		var j=0;
		var tmp='<li id="li_sbj'+ i +'">';
		if ("<%=sch %>"=="E"){
			var grd=parseInt(i/2)+1;
			var ssn=i%2+1;
			tmp+='<a onClick="showSbjTitleEval('+ i +', '+ grd +', '+ ssn +');" class="title';
		}else{
			tmp+='<a onClick="showSbjTitleEval('+ i +');" class="title';
		}
		if (arrSch[i][0]=="<%=stepE %>"){
			tmp+=' on';
			sbjI=i;
		}
		tmp+='" style="cursor:pointer;">'+ arrSch[i][1] + '</a>';
		if (arrSch[i][0]=="<%=stepE %>"){
			tmp+=getSbjItemEval(i, <%=book_seq %>);
		}
		tmp+='</li>';

		document.write(tmp);
	}

	// ' 161018 창체의 '과목별 추천사이트' 이동...
	var tmp='<li id="li_sbj'+ i +'">';
	if ("<%=sch %>"=="E"){
		tmp+='<a onClick="showSbjTitleEval('+ i +', 0, 0);" class="title';
	}else{
		tmp+='<a onClick="showSbjTitleEval('+ i +');" class="title';
	}
	if ("<%=sbj %>"=="recommand"){
		tmp+=' on';
		sbjI=i;
	}
	tmp+='" style="cursor:pointer;">과목별 추천사이트</a>';
	if ("<%=sbj %>"=="recommand"){
		tmp+=getSbjItemEval(i, 0);
	}
	tmp+='</li>';
	document.write(tmp);

}catch(e){}
</script>
					</ul>
				</div>
				<!--a href="<%=urlCd %>"><img src="/images/renew/sub/LNB_box_bn.jpg" /></a-->
<!--#include virtual="/inc/inc_lnb_banner.asp"-->
			</div>
<%
Dim book_title, base_turn, idxChapter

Dim isClass:isClass=True
If sch="E" And (book_seq=226 Or book_seq=228 Or (book_seq>=335 And book_seq<=338)) Then ' 국어1-1, 2-1  ' 초등 국어5-1/2, 6-1/2 --> 평가자료만...
	isClass=False 
End If 

sql="SELECT title, base_turn FROM DBookServiceInfo WHERE seq="& book_seq
'Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
If Not (oRS.BOF Or oRS.EOF) Then 
	book_title=util_nte(Trim(oRS("title")), "", "string")
	base_turn=util_nte(Trim(oRS("base_turn")), "09", "string") ' 09로만 표시...
End If 
'base_turn="09"
Call oRS.close()
%>
			<div class="sub_right">
				<div class="inner">
					<div class="title_learn">
						<img src="/images/renew/sub/icon_smart_20<%=base_turn %>.png" class="ml5" />
						<span class="ml2"><%=book_title %></span>
					</div>
					
					<div style="position:relative;">
						<!-- 단원별 자료 -->
						<div id="divDnCmn" class="leaning_data_wrap">
							<div class="step_data"><img src="/images/sub/learn_data_tap.png"/><p>단원별 자료</p></div>
						</div>
						<!-- 평가&수업 탭 -->
						<ul class="learn_data_type">
							<li style="margin-right:5px"><% If isClass Then %><a href="javascript:setData1('S');"<% If data1="S" Then %> class="on"<% End If %>>수업자료</a><% End If %></li>
							<li><a href="javascript:setData1('T');"<% If data1="T" Then %> class="on"<% End If %>>평가자료</a></li>
						</ul>
					</div>
					<!-- 자료 -->
					<div class="learn_data_con" style="min-height:200px;">
						<ul>
<%
sql="SELECT idx, chapterL, title FROM TP_chapter WHERE DBook_seq="& book_seq &" AND is_delete='n' AND chapterL<>'' AND chapterM='' AND chapterS='' ORDER BY chapterL, pages"
'Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
If Not (oRS.BOF Or oRS.EOF) Then 
	arrChp=oRS.GetRows()
End If 
Call oRS.close()
If isArray(arrChp) Then
	divChpNum=8 ' default. 문단 나누는 기준...
'	divChpNum=(UBound(arrChp, 2)+1)/2
'	divChpNum=-(Int(-divChpNum)) ' 올림...

	For ii=0 To UBound(arrChp, 2)
		If ii=divChpNum Then %>
						</ul><ul>
<%		End If 
		If arrChp(1, ii)=unit Then
			idxChapter=arrChp(0, ii)
		End If 
%>
							<li><a href="javascript:setChapter('<%=arrChp(1, ii) %>');"<% If arrChp(1, ii)=unit Then %> class="on"<% End If %>><%=arrChp(2, ii) %></a></li>
<%
	Next 
	Erase arrChp
End If 
%>
						</ul>
						<div id="dnCmnContent" class="leaning_data" style="display:none;">  
							<div><img src="/images/sub/learning_search.png" style="margin-right:5px;"/>공통자료</div>
						</div>
<script>
function printCmn(){
	var arr=itbDnCmn<%=sch %>;
	var tmp="";

	if ($.isArray(arr[sbjI])){
		if (arr.length>=sbjI){
			if ($.isArray(arr[sbjI][curItbIdx])){
				arr=arr[sbjI][curItbIdx];

				if (arr && arr.length>0){
					tmp+='<ul class="list">';
					for (var i=0; i<arr.length; i++){
						tmp+='<li';
						if (i==(arr.length-1)){
							tmp+=' class="last"';
						}
						tmp+='><span></span><a href="javascript:goDnSingleCmn(\''+ arr[i][1] +'\');">'+ arr[i][0] +'</a></li>';
					}
					tmp+="</ul>";
					$("#dnCmnContent").append(tmp);
					$("#dnCmnContent").css("display","");
				}
			}
		}
	}	
}
function getQry(){
	var arr=itbDnSbjList<%=sch %>[sbjI][curItbIdx];
	var chapL=$("#fm_unit").val();
	var pg=$("#fm_page").val();
	var idx=0;
	var code="-1";

	var qry="?curri="+ arr[0];
	qry+="&subject="+ arr[1];
	qry+="&author="+ arr[2];
	qry+="&grade="+ arr[3];
	if (arr[4]!=""){ // 국어 때문에...
		qry+="&part="+ arr[4];
	}
	qry+="&dbook_seq="+ arr[5];
	qry+="&chapL="+ chapL;
	qry+="&page="+ pg;
	qry+="&Iidx="+ idx;
	qry+="&itb_type=<%=data2%>";

	if (typeof(arr[9])!="undefined"){ // 신규 문제은행 db 사용...
		qry+="&isNewPaper="+ arr[9];
	}
	return qry;
}
printCmn();
</script>
					</div>

					<div id="innerEval" style="min-height:260px;">
					</div>
<script>
var xUrl="getEvalList.asp";
xUrl+=getQry();
$("#innerEval").load(xUrl);
</script>
				</div>
<!--#include virtual='/inc/inc_footer_attention.inc'-->
			</div>
		</div>
	</div>

<style>
.popup_alert {
	width:220px; height:86px; position:absolute; left:50%; top:50%; margin-left:-146px; margin-top:-63px; padding:20px;
	background:url('/itembank/images/sub/bg_pop_addfn.png') no-repeat;
	text-align:center; vertical-align:bottom;
}
.popup_alert2 {
	width:302px; height:126px; position:absolute; left:50%; top:50%; margin-left:-146px; margin-top:-63px;
	background:url('/images/popup/sub6_3_img.png') no-repeat;
	text-align:center; vertical-align:bottom;
}
.popup_alert p {
	margin-top:20px; padding:0px;
	border:0px;	
}
.bt_pop_icon_close {
	width:21px; height:21px; position:absolute; right:2px; top:0px; z-index:900;
	background:url('/itembank/images/icon/bt_close_bk.jpg'); border:0px;
	cursor:pointer; text-indent:-999px;
}
.bt_pop_icon_close2 {
	width:21px; height:21px; position:absolute; right:0px; top:0px; z-index:900;
	background:url('/itembank/images/icon/bt_close_bk.jpg'); border:0px;
	cursor:pointer; text-indent:-999px;
}
.box_popup { max-width:500px; position:absolute; left:50%; top:50%; padding:14px 0;}
.bg_pop_left { height:100%; background:url('/itembank/images/common/pop_bd_left.png') left top repeat-y; }
.bg_pop_right { height:100%; background:url('/itembank/images/common/pop_bd_right.png') right top repeat-y; }
.popup_con { padding:20px; margin:0 3px 0 1px; text-align:center; background:#ffffff; }
.popup_con p { width:100%; padding:20px 0; word-wrap:break-word;  }
.radius_lt { width:50%; height:14px; position:absolute; left:0px; top:0px; background:url('/itembank/images/common/radius_lt.png') left top no-repeat; }
.radius_lb { width:50%; height:14px; position:absolute; left:0px; bottom:0px; background:url('/itembank/images/common/radius_lb.png') left bottom no-repeat; }
.radius_rt { width:50%; height:14px; position:absolute; right:0px; top:0px; background:url('/itembank/images/common/radius_rt.png') right top no-repeat; }
.radius_rb { width:50%; height:14px; position:absolute; right:0px; bottom:0px; background:url('/itembank/images/common/radius_rb.png') right bottom no-repeat; }

.bt_submit_bk {
	width:61px; height:23px;
	background:url('/itembank/images/icon/bt_submit_bk.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}
.bt_submit_bk2 {
	width:151px; height:23px; 
	background:url('/itembank/images/icon/bt_submit_bk2.jpg');
	cursor:pointer; text-indent:-999px; border:0px;
}
</style>
<div class="popup_alert2" id="popConfirm" style="display:none;z-index:10000;">
	<h2 class="p_head"><p style="margin-top:25px;"><span id="confirmTitle"></span></p></h2> 
	<p><span id="confirmMsg"></span></p>
	<div style="text-align:center;margin:40px auto;width:240px;">
	<input type="button" value="확인" name="" class="bt_submit_bk" onClick="javascript:pop_o.closeConfirmPop(false);"></input>
	<input type="button" value="확인후이동" name="" class="bt_submit_bk2" onClick="javascript:pop_o.closeConfirmPop(true);"></input>
	<input type="button" value="닫기" name="" class="bt_pop_icon_close2" onClick="javascript:pop_o.closeConfirmPop(false);"></input>
	</div>
</div>

<!--#include virtual="/inc/xdownload.asp"-->
<!--#include virtual="/scrap/inc_scrapFormNjs.asp"-->
</div>
<!-- //Container -->
<!--#include virtual='/inc/footer_renewal.inc' -->
<!--#include virtual='/inc/end.inc' -->
<%
Function chkIsNew(isNew, isNewDate) ' 20140603 test와 혼용때문에 isnull 추가...
	chkIsNew=False
	If LCase(isNew)="y" And (CStr(Date())<=isNewDate Or isnull(isNewDate)) Then
		chkIsNew=True
	End If 	
End Function
%>