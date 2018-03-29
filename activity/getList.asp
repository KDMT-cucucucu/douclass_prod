<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getList"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<%
Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim getup_seq:getup_seq=util_nte(request("getup_seq"), 0, "int")
Dim geteq:geteq=util_nte(request("geteq"), 0, "int")
Dim getsubeq:getsubeq=util_nte(request("getsubeq"), 0, "int")
Dim typeSeq:typeSeq=util_nte(request("typeSeq"), 3, "int")
Dim selSeq:selSeq=util_nte(request("selSeq"), 1, "int")

Dim cateB:cateB=util_nte(Trim(request("cateB")), "", "string")
Dim cateS:cateS=util_nte(Trim(request("cateS")), "", "string")

'Response.write "seq : "&seq&"<br />"
'Response.write "getup_seq : "&getup_seq&"<br />"
'Response.write "geteq : "&geteq&"<br />"
'Response.write "getsubeq : "&getsubeq&"<br />"
'Response.write "typeSeq : "&typeSeq&"<br />"
'Response.write "selSeq : "&selSeq&"<br />"

Dim sql, oRS, ii, mode, cnt
Dim dbt, wquery, orderBy
Dim page, pagesize, count, totPage, blockpg

Dim seqQuery
Dim cp_seq, depth1, depth2, depth3, cp_title
Dim content_seq, school, subject, content_title, coment, thumbnail, video, image, document, link, content_type, content, tag, orderNo, regDate, isDisplay, isNew, isDelete
Dim reqQnaTab
Dim publicYN
Dim orderby1
Dim iii, depth4

pagesize=util_nte(request("pagesize"), 10, "int")
page=util_nte(request("page"), 1, "int")

school=util_nte(request("school"), "", "string")
content_title=util_nte(Trim(request("content_title")), "", "string")
reqQnaTab=util_nte(Trim(request("reqQnaTab")), "", "string")
orderby1=util_nte(request("orderby1"), "", "string")
'Response.write "reqQnaTab : "&reqQnaTab&"<br />"

depth4=util_nte(request("depth4"), 0, "int")

Dim title, board, template, search, reply
Dim up_seq, lnbTitle, lnbComent, cnt_seq
Dim sql2, oRS2, cnt2, cellLimit:cellLimit=5
%>
<%
Sub printSrch(count)
%>

					<div class="education_data_type">			
						<div class="styled-select type03">
							<select name="school" class="styled-select" id="school">
								<option class="select_defalut" value="">전체</option>
								<option value="E"<% If school="E" Then %> selected<% End If %>>초등</option>
								<option value="M"<% If school="M" Then %> selected<% End If %>>중등</option>								
								<option value="H"<% If school="H" Then %> selected<% End If %>>고등</option>								
							</select>	
						</div>						
						<input type="text" name="content_title" id="content_title" value="<%=content_title %>" />
						<input type="submit" value="검색" onClick="srchList()" />
						<div style="float:right;margin-top: 22px;margin-right: 3px;">
							<span>전체 자료수</span><span style="margin:0px 3px;">:</span><span class="data_value"><%=count %></span><span>건</span>
						</div>
					</div>		
<%
End Sub
Sub printScrap()
%>
									<label>
										<input type="checkbox" name="chkAll" id="chkAll" onClick="checkAll(this);" />
										전체 선택/해지
									</label>
									<button style="margin-left: 5px;" onClick="gotoScrap();"><p>스크랩</p></button>
									<button style="margin-left: -6px;float:right;margin-right: 11px;" onClick="alert('준비중입니다.')">
										<p style="width:141px;">
										<img src="/images/renew/sub/scrap_icon.png" style="padding-right:5px;margin-left: -3px;margin-bottom: 2px;" alt="star_icon"/>나의 스크랩 바로가기
										</p>
									</button>
<%
End Sub
%>
<%
If selSeq=depthSeqStudent And (geteq>0 Or (getup_seq<>(depthSeqStudent+1) And geteq=0)) Then ' 학생 참여형 수업 && 자유학년제(하드코딩...)
	sql = "SELECT * FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (typeSeq+1) &" AND up_seq="& seq
	If depth4>0 Then
		sql=sql &" AND seq="& depth4
	End If 
Else 
	sql = "SELECT * FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="&typeSeq&" AND seq="& seq
End If 
'	If g_Mem.uid="kdmtdev" Then
'		Response.write sql
'	End If 
Set oRS=g_oDB.Execute(sql)
	If Not (oRS.BOF Or oRS.EOF) Then
		up_seq = oRS("up_seq")
		title = Trim(oRS("title"))
		coment = Trim(oRS("coment"))
		board = oRS("board")
		template = oRS("template")
		search = oRS("search")
		reply = oRS("reply")
	End If
Call oRS.Close()
Set oRS = Nothing
'Response.write "board : "& board &"<br />"

If up_seq>0 Then 'title
	If selSeq=depthSeqStudent Then
		sql = "SELECT title, Coment FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& typeSeq &" AND seq="& seq
	Else 
		sql = "SELECT title, Coment FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth=2 AND seq="& up_seq
	End If 
'	Response.write sql &"<br />"
	Set oRS=g_oDB.Execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			lnbTitle = Trim(oRS("title"))
			lnbComent = Trim(oRS("Coment"))
		End If
	Call oRS.Close()
	Set oRS = Nothing
End If

%>
<script>
function goEtcDetail(selSeq, typeSeq, upSeq, geteq, seq, getsubeq, cSeq, pg){
//	if(mem_o.gotoLogin()) return;
<% If g_Mem.uid<>"" Then %>
<% If chkIsCerti() Then %>
	var rUrl="/activity/activity_detail.asp";
	rUrl+="?selSeq="+ selSeq +"&typeSeq="+ typeSeq +"&getup_seq="+ upSeq +"&geteq="+ geteq +"&seq="+ seq +"&getsubeq="+ getsubeq +"&content_seq="+ cSeq +"&page="+ pg;
	rUrl+="&depth4=<%=depth4 %>";

	location.href=rUrl;
<% Else %>
	menu_o.openAlertPop(false, "", null, 11);
	return;
<% End If %>
<% Else %>
	mem_o.gotoLogin();
<% End If %>
}
function setEtcTabLi(up_seq, eq, seq, subeq){
	setEtcSubLi(up_seq, eq, seq, subeq);
}

$(document).ready(function(){
var getsubeq = <%=getsubeq %>;
		$(".education_list li a").click(function(){
			$(".education_list li a").removeClass("on");
			$(this).addClass("on");
			$(".education_list li:nth-child(n+1) a").css("border-right-width", "");
			$(".education_list_05").css("border-left-width","");
			$(".education_list li:nth-child(n+6) a").css("border-right-width", "");
			$(".education_list_010").css("border-left-width","");
			$(".education_list_15").css("border-left-width","");
			$(".education_list_20").css("border-left-width","");
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


		if(getsubeq==1){
			$(".education_list li:first-child a").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==2){
			$(".education_list_02").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==3){
			$(".education_list_03").css("border-right-width","0");
			$(".education_list_05").css("border-left-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==4){
			$(".education_list_04").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==5){
			$(".education_list li:first-child a > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==6){
			$(".education_list_06").css("border-right-width","0");
			$(".education_list_02 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==7){
			$(".education_list_07").css("border-right-width","0");
			$(".education_list_03 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==8){
			$(".education_list_08").css("border-right-width","0");
			$(".education_list_010").css("border-left-width","0");
			$(".education_list_04 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==9){
			$(".education_list_09").css("border-right-width","0");
			$(".education_list_05 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==10){
			$(".education_list_06 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==11){
			$(".education_list_011").css("border-right-width","0");
			$(".education_list_07 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==12){
			$(".education_list_012").css("border-right-width","0");
			$(".education_list_08 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==13){
			$(".education_list_013").css("border-right-width","0");
			$(".education_list_015").css("border-left-width","0");
			$(".education_list_09 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==14){
			$(".education_list_014").css("border-right-width","0");
			$(".education_list_010 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==15){
			$(".education_list_011 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==16){
			$(".education_list_016").css("border-right-width","0");
			$(".education_list_012 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==17){
			$(".education_list_017").css("border-right-width","0");
			$(".education_list_013 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==18){
			$(".education_list_018").css("border-right-width","0");
			$(".education_list_020").css("border-left-width","0");
			$(".education_list_014 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==19){
			$(".education_list_019").css("border-right-width","0");
			$(".education_list_015 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}


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
			$(".education_list_010").css("border-left-width","0");
			$(".education_list_04 > span").css("background-color","#204687");
		});			
		$(".education_list_010").click(function(){
			$(this).addClass("on");
			$(".education_list_09").css("border-right-width","0");
			$(".education_list_05 > span").css("background-color","#204687");
		});
		$(".education_list_011").click(function(){
			$(this).addClass("on");
			$(".education_list_06 > span").css("background-color","#204687");
		});			
		$(".education_list_012").click(function(){
			$(this).addClass("on");
			$(".education_list_011").css("border-right-width","0");
			$(".education_list_07 > span").css("background-color","#204687");
		});		
		$(".education_list_013").click(function(){
			$(this).addClass("on");
			$(".education_list_012").css("border-right-width","0");
			$(".education_list_08 > span").css("background-color","#204687");
		});		
		$(".education_list_014").click(function(){
			$(this).addClass("on");
			$(".education_list_013").css("border-right-width","0");
			$(".education_list_015").css("border-left-width","0");
			$(".education_list_09 > span").css("background-color","#204687");
		});			
		$(".education_list_015").click(function(){
			$(this).addClass("on");
			$(".education_list_014").css("border-right-width","0");
			$(".education_list_010 > span").css("background-color","#204687");
		});		
		$(".education_list_016").click(function(){
			$(this).addClass("on");
			$(".education_list_011 > span").css("background-color","#204687");
		});			
		$(".education_list_017").click(function(){
			$(this).addClass("on");
			$(".education_list_016").css("border-right-width","0");
			$(".education_list_012 > span").css("background-color","#204687");
		});		
		$(".education_list_018").click(function(){
			$(this).addClass("on");
			$(".education_list_017").css("border-right-width","0");
			$(".education_list_013 > span").css("background-color","#204687");
		});		
		$(".education_list_019").click(function(){
			$(this).addClass("on");
			$(".education_list_018").css("border-right-width","0");
			$(".education_list_020").css("border-left-width","0");
			$(".education_list_014 > span").css("background-color","#204687");
		});			
		$(".education_list_020").click(function(){
			$(this).addClass("on");
			$(".education_list_019").css("border-right-width","0");
			$(".education_list_015 > span").css("background-color","#204687");
		});	
});

function setTabFocus(num){
	$(".education_list li a").removeClass("on");
	if (num>0){
		$(".education_list_0"+ num).click();
	}else{
		$(".education_list li:first-child a").click();
	}
}
</script>
<% If board=3 And (title="사진 자료실" Or title="사진자료실" Or title="이미지 자료실" Or title="이미지자료실" Or title="지역학습" Or title="지역 학습") Then %>
<script type="text/javascript" src="/js/etc/arrMediaCate.js"></script>
<script>
var title="<%=title %>";
var cate_code;

if(title=="사진 자료실" || title=="사진 자료실" || title=="이미지 자료실" || title=="이미지자료실"){
	cate_code="photo"; //이미지 자료실
}else if(title=="지역학습" || title=="지역학습"){
	cate_code="area"; //지역 학습
}
var dftCateB="soc";// 대분류 기본값...
var dftCateS="kor";// 소분류 기본값...
if(cate_code=="area"){
	dftCateB="강원도";// 대분류 기본값...
	dftCateS="강릉시";// 소분류 기본값...	
}
<% If cateB<>"" Then %>
	dftCateB="<%=cateB %>";
<% End If %>
<% If cateS<>"" Then %>
	dftCateS="<%=cateS %>";
<% End If %>
function appendSel(sel, arr, seled){
	//console.log("sel : "+sel);
	//console.log("arr : "+arr);
	//console.log("seled : "+seled);
	$("#"+ sel).empty();
	for (i=0; i<arr.length; i++){
		$("#"+ sel).append("<option value='"+ arr[i][0] +"'>"+ arr[i][1] +"</option>");
	}
	if (typeof(seled)!="undefined"){
		$("#"+ sel).val(seled);
	}
}
function getList(pg){
	if(cate_code=="photo"){
		$("#titleCateB").text($("#selCateBig option:selected").text());
		$("#titleCateS").text($("#selCateSmall option:selected").text());
	}else{
		$("#titleCateB").text($("#selCateAreaBig option:selected").text());
		$("#titleCateS").text($("#selCateAreaSmall option:selected").text());
	}

	if (typeof(pg)!="number") pg=1;
	//var xUrl="getList.asp?seq=<%=seq %>&page="+ pg +"&cateB="+ $("#selCateBig option:selected").val() +"&cateS="+ $("#selCateSmall option:selected").val();
	//var xUrl="getEtcPhotoList.asp?page="+ pg +"&cateB="+ $("#selCateBig option:selected").val() +"&cateS="+ $("#selCateSmall option:selected").val() +"&selectNum="+ $("#selectNum option:selected").val();
	if(cate_code=="photo"){
		var xUrl="getEtcPhotoList.asp?page="+ pg +"&cateB="+ $("#selCateBig option:selected").val() +"&cateS="+ $("#selCateSmall option:selected").val() +"&selectNum="+ $("#selectNum option:selected").val()+"&getup_seq=<%=getup_seq %>&seq=<%=seq %>&geteq=<%=geteq %>&getsubeq=<%=getsubeq %>&cate_code="+cate_code;
	}else{
		var xUrl="getEtcPhotoList.asp?page="+ pg +"&cateB="+ encodeURIComponent($("#selCateAreaBig option:selected").val()) +"&cateS="+ encodeURIComponent($("#selCateAreaSmall option:selected").val()) +"&selectNum="+ $("#selectNum option:selected").val()+"&getup_seq=<%=getup_seq %>&seq=<%=seq %>&geteq=<%=geteq %>&getsubeq=<%=getsubeq %>&cate_code="+cate_code;
	}
	//alert(xUrl);
	var srchTxt=$.trim($("#srchTxt").val());
	if (srchTxt!="") xUrl+="&srchTxt="+ encodeURIComponent(srchTxt);
	//document.write(xUrl);
	//alert(xUrl);
	$("#innerList").load(xUrl);
	$("#divPageNavi").load(xUrl +"&mode=paging");
	$("#chkAll").attr("checked", false);
}
function selCate(obj){
	var idx;
	if (typeof(obj)!="object"){
		if(cate_code=="photo"){
			appendSel("selCateBig", arrCateBig, dftCateB);
			idx=$("#selCateBig option").index($("#selCateBig option:selected"));
			appendSel("selCateSmall", arrCateSmall[idx], dftCateS);
		}else{
			appendSel("selCateAreaBig", arrCateAreaBig, dftCateB);
			idx=$("#selCateAreaBig option").index($("#selCateAreaBig option:selected"));
			appendSel("selCateAreaSmall", arrCateAreaSmall[idx], dftCateS);
		}
	}else{
		if(cate_code=="photo"){
			idx=$("#selCateBig option").index($("#selCateBig option:selected"));
			appendSel("selCateSmall", arrCateSmall[idx]);
		}else{
			idx=$("#selCateAreaBig option").index($("#selCateAreaBig option:selected"));
			appendSel("selCateAreaSmall", arrCateAreaSmall[idx]);
		}
	}
}
function selectNum(pa){
	if (typeof(pg)!="number") pg=1;
	if(cate_code=="photo"){
		$("#titleCateB").text($("#selCateBig option:selected").text());
		$("#titleCateS").text($("#selCateSmall option:selected").text());

		//var xUrl="getList.asp?seq=<%=seq %>&page="+ pg +"&cateB="+ $("#selCateBig option:selected").val() +"&cateS="+ $("#selCateSmall option:selected").val();
		var xUrl="getEtcPhotoList.asp?page="+ pg +"&cateB="+ $("#selCateBig option:selected").val() +"&cateS="+ $("#selCateSmall option:selected").val() +"&selectNum="+ $("#selectNum option:selected").val()+"&getup_seq=<%=getup_seq %>&seq=<%=seq %>&geteq=<%=geteq %>&getsubeq=<%=getsubeq %>&cate_code="+cate_code;
	}else{
		$("#titleCateB").text($("#selCateAreaBig option:selected").text());
		$("#titleCateS").text($("#selCateAreaSmall option:selected").text());

		var xUrl="getEtcPhotoList.asp?page="+ pg +"&cateB="+ encodeURIComponent($("#selCateAreaBig option:selected").val()) +"&cateS="+ encodeURIComponent($("#selCateAreaSmall option:selected").val()) +"&selectNum="+ $("#selectNum option:selected").val()+"&getup_seq=<%=getup_seq %>&seq=<%=seq %>&geteq=<%=geteq %>&getsubeq=<%=getsubeq %>&cate_code="+cate_code;	
	}
	$("#innerList").load(xUrl);
	$("#chkAll").attr("checked", false);
	
}
$(document).ready(function(){
	selCate();
	getList(<%=page %>);

	for(var i=0; i<$(".accordion_first").length; i++){//사진자료실 하위 카테고리 삭제
		if($("#lnbTitle"+i).text()=="사진자료실" || $("#lnbTitle"+i).text()=="사진 자료실"){
			$("#liItbDnSbj"+i).remove();
		}
	}
	
	var list_accordion_sub=$(".list_accordion_sub li a");
	
	for(var i=0; i<list_accordion_sub.length; i++){
		if(list_accordion_sub.eq(i).text()=="지역학습" || list_accordion_sub.eq(i).text()=="지역 학습"){
			$("#areaTab").attr("href", list_accordion_sub.eq(i).attr("href"));
		}
		if(list_accordion_sub.eq(i).text()=="이미지 자료실" || list_accordion_sub.eq(i).text()=="이미지자료실" || list_accordion_sub.eq(i).text()=="사진자료실" || list_accordion_sub.eq(i).text()=="사진 자료실"){
			$("#photoTab").attr("href", list_accordion_sub.eq(i).attr("href"));
		}
	}


	/*list_photo_tab */
	/*
	$(".list_photo_tab li a").click(function(){
		$(".list_photo_tab li a").removeClass("on");
		$(this).addClass("on");
	});

	$(".photo_data_wrap li:nth-child(4n+4)").css("padding","30px 17px 0 17px");
	$(".photo_data_wrap li:nth-child(4n+4) div:first-child").css("padding-bottom","12px");
	$(".photo_data_wrap li:last-child").css("margin-bottom","12px");
	
	$(".list_photo_tab li a").click(function(){
		$(".photo_data_type.area_study").css("display","block");
		$(".photo_data_type.img_data").css("display","none");
	});
	$(".list_photo_tab li+li a").click(function(){
		$(".photo_data_type.area_study").css("display","none");
		$(".photo_data_type.img_data").css("display","block");
	});
	*/

		$(".photo_data_wrap li:nth-child(4n+1)").css("clear","both");
		$(".photo_data_type.img_data").css("display","block");
});
</script>
<% End If %>
	<% If board=3 And (title="사진 자료실" Or title="사진자료실" Or title="이미지 자료실" Or title="이미지자료실" Or title="지역학습" Or title="지역 학습") Then %>
	<!-- 지역학습, 이미지 자료실 -->
				<div class="inner">
					<div class="title_creativity ml2" style="margin-bottom:14px;">사진 자료실</div>		
					<div class="photo_data_type_wrap">
						<ul class="list_photo_tab">
							<li><a class="<%If title="지역학습" Or title="지역 학습" Then%>on<% End If %>" id="areaTab" href="#">지역학습<span></span></a></li>
							<li><a class="<%If title="사진 자료실" Or title="사진자료실" Or title="이미지 자료실" Or title="이미지자료실" Then%>on<% End If %>" id="photoTab" href="#">이미지 자료실<span></span></a></li>				
						</ul>
		<form name="fmMediaSrch" method="post" onSubmit="getList(1);return false;" />
		<!--지역학습-->
		<% If title="지역학습" Or title="지역 학습" Then %>
						<ul class="photo_data_type area_study">
							<li>
								<span>* 지역선택</span>
								<div class="styled-select type02">
									<select name="selCateAreaBig" id="selCateAreaBig" class="styled-select" onChange="selCate(this);">							
									</select>
								</div>		
								<div class="styled-select type02 ml10">
									<select name="selCateAreaSmall" id="selCateAreaSmall" class="styled-select">						
									</select>	
								</div>								
							</li>	
							<li>
								<span>* 검색어</span>
								<input type="text" name="srchTxt" id="srchTxt" value="" />
								<input type="submit" value="검색" onClick="getList(1);" />
							</li>
						</ul>
		
		<% ElseIf title="사진 자료실" Or title="사진자료실" Or title="이미지 자료실" Or title="이미지자료실" Then %>
		<!--이미지 자료실-->
						<ul class="photo_data_type area_study">
							<li>
								<span>* 지역선택</span>
								<div class="styled-select type02">
									<select name="selCateBig" id="selCateBig" class="styled-select" onChange="selCate(this);">							
									</select>	
								</div>		
								<div class="styled-select type02 ml10">
									<select name="selCateSmall" id="selCateSmall" class="styled-select">						
									</select>	
								</div>
							</li>
							<li>
								<span>* 검색어</span>
								<input type="text" name="srchTxt" id="srchTxt" value="" />
								<input type="submit" value="검색" onClick="getList(1);" />
							</li>
						</ul>
		<% End If %>
		</form>					
					</div>
					<div class="num_watch_select">	
						<div class="styled-select type03">
							<select id="selectNum" name="selectNum" class="styled-select" onChange="selectNum(this);">
								<option class="select_defalut" value="12">12개씩 보기</option>
								<option value="20">20개씩 보기</option>
								<option value="50">50개씩 보기</option>
								<option value="100">100개씩 보기</option>								
							</select>	
						</div>	
						<div style="float:right;margin-top: 22px;margin-right: 3px;">
							<span>전체 자료수</span><span style="margin:0px 3px;">:</span><span class="data_value" id="totCnt"></span><span>건</span>
						</div>
					</div>
					<ul id="innerList" class="photo_data_wrap">
					</ul>
					<div class="box_table_num" id="divPageNavi"></div>
	<!-- //지역학습, 이미지 자료실 -->
	<% Else %>
				<div class="inner">
					<% If typeSeq=3 Then %>
					<div class="title_creativity">
						<span class="ml2"><%=lnbTitle %></span>
						<!--<span class="title_info"><%=lnbcoment %></span>-->
					</div>
					<ul class="education_list">
	
<%
'Response.write up_seq
'Response.End
Dim tab0Sel:tab0Sel=False 
If up_seq>0 Then 'title
	If selSeq=depthSeqStudent Then
		sql = "SELECT COUNT(*) AS cnt FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (typeSeq+1) &" AND up_seq="& seq
	Else 
		sql = "SELECT COUNT(*) AS cnt FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="&typeSeq&" AND up_seq="& up_seq
	End If 
'	If g_Mem.uid="kdmtdev" Then
'		Response.write sql
'	End If 
	Set oRS=g_oDB.Execute(sql)
		cnt=oRS(0)
	Call oRS.close()
	Set oRS = Nothing
	If cnt>0 Then
		If selSeq=depthSeqStudent Then
			sql="SELECT title, seq"&_
				" FROM CP_category AS cate WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (typeSeq+1) &" AND up_seq="& seq			
		Else 
			sql="SELECT title, seq"&_
				" FROM CP_category AS cate WITH(NOLOCK) WHERE isDisplay=1 AND depth="&typeSeq&" AND up_seq="& up_seq
		End If 
		sql=sql &" ORDER BY orderNo, regDate"
		Set oRS=g_oDB.Execute(sql)
			ii=0
			iii=0
			Do While Not (oRS.BOF Or oRS.EOF)
				cnt_seq=oRS("seq")
				If depth4=0 And ii=0 And selSeq=depthSeqStudent Then
					depth4=cnt_seq
				End If 
				'Response.write cnt_seq
				'sql="SELECT COUNT(*) AS cnt FROM CP_contents AS con"&_
				'	" INNER JOIN CP_categoryList AS cate ON con.depth"&typeSeq&"=cate.depth"&typeSeq&"_seq"&_
				'	" WHERE con.isDisplay=1 AND cate.isDisplay=1 AND isDelete<>'Y' AND depth"&typeSeq&"="& cnt_seq
				sql="SELECT COUNT(*) AS cnt FROM CP_contents AS con WITH(NOLOCK)"&_
					" WHERE con.isDisplay=1 AND isDelete<>'Y' AND depth"&typeSeq&"="& cnt_seq
				'Response.write sql
				'Response.End
'				Set oRS2=g_oDB.Execute(sql)
'					cnt2=oRS2(0)
'				Call oRS2.close()
'				Set oRS2 = Nothing

				If selSeq=depthSeqStudent Then
%>
					<% If ii=0 Then %>
						<li><a id="tabTitle<%=ii %>" name="tabTitle" href="/activity/?selSeq=<%=selSeq%>&typeSeq=<%=typeSeq%>&getup_seq=<%=getup_seq  %>&geteq=<%=geteq  %>&seq=<%=seq %>&getsubeq=<%=getsubeq %>&depth4=<%=cnt_seq %>" class="<% If ii<cellLimit Then %>bd_top<% End if %><% If depth4=cnt_seq Then %> on<% End If %>" onMouseOver="setTitle(this);"><%=Trim(oRS("title")) %><!--div style="display: inline-block;">(<%'=cnt2 %>)</div--><span></span></a></li>
<% If depth4=cnt_seq Then 
	tab0Sel=True %>
<script>
setTabFocus(0);
//$(".education_list li:first-child a").click();
</script>
<% End If %>
					<% Else %>
						<li><a id="tabTitle<%=ii %>" name="tabTitle" href="/activity/?selSeq=<%=selSeq%>&typeSeq=<%=typeSeq%>&getup_seq=<%=getup_seq  %>&geteq=<%=geteq  %>&seq=<%=seq %>&getsubeq=<%=getsubeq %>&depth4=<%=cnt_seq %>" class="education_list_0<%=ii+1 %><% If ii<cellLimit Then %> bd_top<% End if %><% If depth4=cnt_seq Then %> on<% End If %>" onMouseOver="setTitle(this);"><%=Trim(oRS("title")) %><!--div style="display: inline-block;">(<%'=cnt2 %>)</div--><span></span></a></li>
<% If Not tab0Sel Then 
	If selSeq=depthSeqStudent And depth4=cnt_seq Then %>
<script>
setTabFocus(<%=(ii+1) %>);
//$(".education_list_0<%=(ii+1) %>").click();
</script>
<%	End If
   End If %>
					<% End If %>
<%				Else %>
					<% If ii=0 Then %>
						<li><a id="tabTitle<%=ii %>" name="tabTitle" href="/activity/?selSeq=<%=selSeq%>&typeSeq=<%=typeSeq%>&getup_seq=<%=getup_seq  %>&geteq=<%=geteq  %>&seq=<%=cnt_seq %>&getsubeq=<%=ii %>" class="<% If getsubeq=ii Then %>on<% End If %><% If ii<cellLimit Then %> bd_top<% End if %>"><%=Trim(oRS("title")) %><!--div style="display: inline-block;">(<%'=cnt2 %>)</div--><span></span></a></li>
					<% Else %>
						<li><a id="tabTitle<%=ii %>" name="tabTitle" href="/activity/?selSeq=<%=selSeq%>&typeSeq=<%=typeSeq%>&getup_seq=<%=getup_seq  %>&geteq=<%=geteq  %>&seq=<%=cnt_seq %>&getsubeq=<%=ii %>" class="education_list_0<%=ii+1 %><% If ii<cellLimit Then %> bd_top<% End if %><% If getsubeq=ii Then %> on<% End If %>"><%=Trim(oRS("title")) %><!--div style="display: inline-block;">(<%'=cnt2 %>)</div--><span></span></a></li>
					<% End If %>
<%
				End If 
			ii=ii+1
			oRS.movenext
		Loop
		Call oRS.close()
		Set oRS = Nothing

		For ii=ii To (-(int(-(cnt/cellLimit)))-1)*cellLimit+(cellLimit-1) 
%>				
						<li><a href="#" class="education_list_0<%=ii+1 %><% If ii<cellLimit Then %> bd_top<% End if %>" style="cursor:default;"><span></span></a></li>
<%
		Next 
	End If
End If
%>
					</ul>
					<% End If %>
				<% If typeSeq=2 And cnt=0 Then %>
					<div class="title_creativity"><%=title %><span class="title_info"><%=coment %></span></div>
				<% Else %>
					<div class="education_data_title"><%=title %><span style="font-size:13px;color:#747474;margin-left:15px;display: inline-block;"><%=coment %></span></div>
				<% End If %>
	<% End If %>
<% 
Dim previewer, fileExt, fileExtTitle
Dim isFreeDoc:isFreeDoc=False ' 자유학기제 문서자료 여부...
If selSeq=2 And geteq=1 Then
''	isFreeDoc=True
End If 

	dbt="CP_contents"
	If typeSeq=2 Then
		wquery="WHERE isDelete<>'Y' AND c.isDisplay=1 AND cl.isDisplay=1 AND depth"&typeSeq&"="&seq
	ElseIf  typeSeq=3 Then
		wquery="WHERE isDelete<>'Y' AND c.isDisplay=1 AND depth"&typeSeq&"="&seq
	End If
	If depth4>0 Then
		wquery=wquery &" AND depth4="& depth4
	End If
'	If g_Mem.uid="kdmtdev" then 
'	Response.write wquery &"<br />"
'	End If
	orderBy="ORDER BY orderNo, c.seq DESC"

	If school<>"" Then wquery = wquery &" AND school like '%"& school &"%'"
	If content_title<>"" Then wquery = wquery &" AND title like '%"& content_title &"%'"

	If typeSeq=2 Then
		sql = "SELECT count(*) as cnt FROM (SELECT ROW_NUMBER() OVER("&orderBy&") AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
			  " FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
			  " INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&")"&_
			  " AS list"
	ElseIf  typeSeq=3 Then
		sql = "SELECT count(*) as cnt FROM (SELECT ROW_NUMBER() OVER("&orderBy&") AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
			  " FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
			  " "&wquery&seqQuery&")"&_
			  " AS list"
	End If
'	If g_Mem.uid="kdmtdev" then 
'	Response.write sql &"<br />"
'	End If
	'Response.write sql
	Set oRS=g_oDB.Execute(sql)
		count=oRS(0)
	Call oRS.close()
	Set oRS = Nothing
%>
<% If board=1 Then %> <!--텍스트형 -->
					<div class="education_data_type">
					<% If search=1 Then %>
					<!--
						<div class="styled-select type03">
							<select name="school" class="styled-select" id="school">
								<option class="select_defalut" value="">학교급</option>
								<option value="E"<% If school="E" Then %> selected<% End If %>>초등</option>
								<option value="M"<% If school="M" Then %> selected<% End If %>>중등</option>								
								<option value="H"<% If school="H" Then %> selected<% End If %>>고등</option>								
							</select>	
						</div>
					-->
						<input type="text" name="content_title" id="content_title" value="<%=content_title %>" />
						<input type="submit" value="검색" onClick="srchList()" />
					<% End If %>
						<div style="float:right;margin-top: 22px;margin-right: 3px;">
							<span>전체 자료수</span><span style="margin:0px 3px;">:</span><span class="data_value"><%=count %></span><span>건</span>
						</div>
					</div>
					<table class="data_catagory_wrap">
						<colgroup>
							<col width="63" />
							<col width="161" />
						<% If isFreeDoc Then %>
							<col width="541" />
						<% Else %>
							<col width="431" />
							<col width="110" />
						<% End If %>
						</colgroup>
						<thead id="customer_data_top">
							<tr>
								<th>번호</th>
								<input type="hidden" name="orderBy1" id="orderBy1" value="<%=orderBy1 %>" />
								<th>출처<button style="outline:none;margin-top:2px;margin-top:0;background:none;cursor:pointer;" onClick="orderBy1();"><img src="/images/renew/sub/btn_align_up.jpg" style="position: relative;top: -1px;" /></button></th>
						<% If isFreeDoc Then %>
								<th style="padding-right: 37px;" colspan=2>제목</th>
						<% Else %>
								<th style="padding-right: 37px;">제목</th>
								<!--th>등록일</th-->
								<th>스크랩</th>
						<% End If %>
							</tr>
						</thead>
						<tbody id="freesem_data">						
<%
	If count>0 Then
		totpage=int((count-1)/pagesize)+1
		blockpg=pagesize*(page-1)
		If page<1 Then
			page=1
		ElseIf page>totpage Then
			page=totpage
		End If
		If orderBy1="" Then
			orderby="ORDER BY publicYN DESC, orderNo ASC, c.seq DESC"
		Else
			orderby="ORDER BY publicYN DESC, cp_title "&orderBy1&", orderNo ASC, c.seq DESC"
		End If

		If typeSeq=2 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER("&orderby&") AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		ElseIf typeSeq=3 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER("&orderby&") AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		End If
			'Response.write SQL
		Set oRS=g_oDB.Execute(SQL)
		ii=1
		Do While Not(oRS.EOF Or oRS.BOF)
			content_seq=oRS("seq")
			school=oRS("school")
			If school="E" Then
				school="초등"
			ElseIf school="M" Then
				school="중등"
			ElseIf school="H" Then
				school="고등"
			Else	
				school="전체"
			End If
			content_title=oRS("title")
			thumbnail=Trim(oRS("thumbnail"))
			cp_title=oRS("cp_cp_title")
			coment=oRS("coment")
			isDisplay=oRS("isDisplay")
			isNew=oRS("isNew")
			publicYN=oRS("publicYN")
			regDate=Trim(oRS("regDate"))
			
			content=Trim(oRS("content"))
			content_type=Trim(oRS("content_type"))
			video=Trim(oRS("video"))
			image=Trim(oRS("image"))
			document=Trim(oRS("document"))
			link=Trim(oRS("link"))
%>
							<tr<% If publicYN=1 Then %> class="notice"<% ElseIf isNew=1 Then %> class="bold_new"<% End If %>>
								<td><% If publicYN=1 Then %><div>중요</div><% Else %><%=ii+blockpg %><%'=count-blockpg-ii+1 %><% End If %></td>
								<td><%=cp_title %></td>
								<td<% If isFreeDoc Then %> colspan=2<% End If %>>
									<a href="#" onClick="goEtcDetail('<%=selSeq%>', '<%=typeSeq %>', '<%=getup_seq  %>', '<%=geteq  %>', '<%=seq%>', '<%=getsubeq %>', '<%=content_seq %>', '<%=page %>');"><%=content_title %></a>
									<% If isNew=1 Then %><img src="/images/renew/sub/icon_notice_new.png"/><% End If %>
								</td>
								<!--<% If Not isFreeDoc Then %><td><%=Left(regDate, 10)%></td><% End If %>-->
								<td><button type="button" onClick="goScrap(<%=content_seq %>);" class="create_scrap"><p>스크랩</p></button></td>
							</tr>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
	Else
%>
							<tr class="listView">
								<td colspan="3"> 데이터가 없습니다.</td>
							</tr>
<%
	End If 
%>
						</tbody>						
					</table>
					<div class="box_table_num"><%Call new_pageNavi_ul("goList", page, totpage, 10)%></div>
<% ElseIf board=2 Then %> <!--웹진형 -->
					<div class="education_data_type">
					<% If search=1 Then %>
					<% If selSeq<>2 Then %>
						<div class="styled-select type03">
							<select name="school" class="styled-select" id="school">
								<option class="select_defalut" value="">학교급</option>
								<option value="E"<% If school="E" Then %> selected<% End If %>>초등</option>
								<option value="M"<% If school="M" Then %> selected<% End If %>>중등</option>								
								<option value="H"<% If school="H" Then %> selected<% End If %>>고등</option>								
							</select>	
						</div>
					<% End If %>
						<input type="text" name="content_title" id="content_title" value="<%=content_title %>" />
						<input type="submit" value="검색" onClick="srchList()" />
					<% End If %>
						<div style="float:right;margin-top: 22px;margin-right: 3px;">
							<span>전체 자료수</span><span style="margin:0px 3px;">:</span><span class="data_value"><%=count %></span><span>건</span>
						</div>
					</div>	
					<table class="data_catagory_wrap">
						<colgroup>
							<col width="44" />
							<% If selSeq=2 Then %>
							<col width="30" />
							<col width="32" />
							<col width="580" />
							<% Else %>
							<col width="60" />
							<col width="62" />
							<col width="520" />
							<% End If %>
							<col width="79" />
						</colgroup>
						<tbody id="education_data">
							<tr class="data_catagory_top">
								<td><input type="checkbox" name="chkAll" id="chkAll" onClick="checkAll(this);" /></td>
								<% If selSeq=2 Then %>
								<td colspan="2">번호</td>
								<% Else %>
								<td>번호</td>
								<td>학교급</td>
								<% End If %>
								<td style="padding-right: 29px;">상세 정보</td>
								<td style="padding-right: 15px;">스크랩</td>
							</tr>
							
<%
	If count>0 Then
		pagesize=7
		totpage=int((count-1)/pagesize)+1
		blockpg=pagesize*(page-1)
		If page<1 Then
			page=1
		ElseIf page>totpage Then
			page=totpage
		End If

		If typeSeq=2 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		ElseIf typeSeq=3 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		End If
		'Response.write SQL
		Set oRS=g_oDB.Execute(SQL)
		ii=1
		Do While Not(oRS.EOF Or oRS.BOF)
			content_seq=oRS("seq")
			school=oRS("school")
			If school="E" Then
				school="초등"
			ElseIf school="M" Then
				school="중등"
			ElseIf school="H" Then
				school="고등"
			Else	
				school="전체"
			End If
			content_title=oRS("title")
			thumbnail=Trim(oRS("thumbnail"))
			
			cp_title=oRS("cp_cp_title")
			coment=oRS("coment")
			isDisplay=oRS("isDisplay")
			isNew=oRS("isNew")
			regDate=Trim(oRS("regDate"))

			content_type=Trim(oRS("content_type"))
			video=Trim(oRS("video"))
			image=Trim(oRS("image"))
			document=Trim(oRS("document"))
			link=Trim(oRS("link"))

			If content_type="video" Then
				fileExt=LCase(Mid(video, InStrRev(video,".")+1))
				fileExtTitle=LCase(Mid(video, InStrRev(video,"/")+1))
			ElseIf content_type="image" Then
				fileExt=LCase(Mid(image, InStrRev(image,".")+1))
				fileExtTitle=LCase(Mid(image, InStrRev(image,"/")+1))
			ElseIf content_type="document" Then
				fileExt=LCase(Mid(document, InStrRev(document,".")+1))
				fileExtTitle=LCase(Mid(document, InStrRev(document,"/")+1))
			Else
				fileExt=""
			End If

			If fileExt="swf" Or fileExt="flv" Then
				fileExt="flash"
			ElseIf fileExt="jpg" Or fileExt="jpge" Or fileExt="png" Or fileExt="gif" Then
				fileExt="img"
			ElseIf fileExt="avi" Or fileExt="mp4" Or fileExt="wmv" Then
				fileExt="vod"
			Else
				fileExt=""
			End If
%>
							<tr>
								<td><input type="checkbox" name="chkSingle" value="<%=content_seq %>" onClick="chkSingle(this);" /></td>
								<% If selSeq=2 Then %>
								<td colspan="2"><%=ii+blockpg %><%'=count-blockpg-ii+1 %></td>
								<% Else %>
								<td><%=ii+blockpg %><%'=count-blockpg-ii+1 %></td>
								<td><%=school %></td>
								<% End If %>
								<td class="data_name">
									<a href="javascript:goEtcDetail('<%=selSeq%>', '<%=typeSeq %>', '<%=getup_seq  %>', '<%=geteq  %>', '<%=seq%>', '<%=getsubeq %>', '<%=content_seq %>', '<%=page %>');">
										<% If thumbnail<>"" Then %>
											<img src="<%=thumbnail %>" />
										<% Else %>
											<img src="/images/renew/noimage.gif" />
										<% End If %>
										<% If fileExt<>"" Then %>
										<img src="/images/renew/sub/icon_multi_<%=fileExt %>.jpg" class="data_flash_icon"/>
										<% End If %>
									</a>
									<ul class="left">
										<li class="info_data_title mb3"><a href="javascript:goEtcDetail('<%=selSeq%>', '<%=typeSeq %>', '<%=getup_seq  %>', '<%=geteq  %>', '<%=seq%>', '<%=getsubeq %>', '<%=content_seq %>', '<%=page %>');"><%=content_title %></a></li>
										<li class="info_data_con"><%=coment %></li>
										<li class="info_data_group" style="display:inline-block;margin:4px 23px 0 0;"><div>분류</div><p><%=title %></p></li>
										<li class="info_data_origin"style="display:inline-block;"><div>출처</div><p><%=cp_title %></p></li>
									</ul>
								</td>
								<td><button type="button" onClick="goScrap(<%=content_seq %>);" class="create_scrap"><p>스크랩</p></button></td>
							</tr>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
	Else
%>
							<tr class="listView">
								<td colspan="5"> 데이터가 없습니다.</td>
							</tr>
<%
	End If 
%>
							<tr class="data_catagory_bottom">
								<td colspan="6">
									<%Call printScrap()%>
								</td>
							</tr>	
						</tbody>						
					</table>
					<div class="box_table_num"><%Call new_pageNavi_ul("goList", page, totpage, 10)%></div>
<% ElseIf board=3 Then %> <!--앨범형 -->
	<% If title="사진 자료실" Or title="사진자료실" Or title="이미지 자료실" Or title="이미지자료실" Or title="지역학습" Or title="지역 학습" Then %>


	<% Else %>
<script>
function goDnSingle(path){
	//alert("http:://"+window.location.hostname+path);
//	if(mem_o.gotoLogin()) return;
<% If g_Mem.uid<>"" Then %>
<% If chkIsCerti() Then %>
	ifrProc.location.href="http://"+window.location.hostname+path;
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
	return;
<% End If %>
<% Else %>
	mem_o.gotoLogin();
<% End If %>
}
</script>
					<div class="education_data_type">
						<% If search=1 Then %>
						<!--
						<div class="styled-select type03">
							<select name="school" class="styled-select" id="school">
								<option class="select_defalut" value="">학교급</option>
								<option value="E"<% If school="E" Then %> selected<% End If %>>초등</option>
								<option value="M"<% If school="M" Then %> selected<% End If %>>중등</option>								
								<option value="H"<% If school="H" Then %> selected<% End If %>>고등</option>								
							</select>	
						</div>
						-->
						<input type="text" name="content_title" id="content_title" value="<%=content_title %>" />
						<input type="submit" value="검색" onClick="srchList()" />
						<% End If %>
						<div style="float:right;margin-top: 22px;margin-right: 3px;">
							<span>전체 자료수</span><span style="margin:0px 3px;">:</span><span class="data_value"><%=count %></span><span>건</span>
						</div>
					</div>	
					<ul class="data_form_wrap">
							
<%
	pagesize=6
	If count>0 Then
		totpage=int((count-1)/pagesize)+1
		blockpg=pagesize*(page-1)
		If page<1 Then
			page=1
		ElseIf page>totpage Then
			page=totpage
		End If

		If typeSeq=2 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		ElseIf typeSeq=3 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		End If
			'Response.write SQL

		Set oRS=g_oDB.Execute(SQL)
		ii=1
		Do While Not(oRS.EOF Or oRS.BOF)
			content_seq=oRS("seq")
			school=oRS("school")
			If school="E" Then
				school="초등"
			ElseIf school="M" Then
				school="중등"
			ElseIf school="H" Then
				school="고등"
			Else	
				school="전체"
			End If
			content_title=oRS("title")
			thumbnail=Trim(oRS("thumbnail"))
			
			cp_title=oRS("cp_cp_title")
			coment=oRS("coment")
			isDisplay=oRS("isDisplay")
			isNew=oRS("isNew")
			regDate=Trim(oRS("regDate"))

			content_type=Trim(oRS("content_type"))
			video=Trim(oRS("video"))
			image=Trim(oRS("image"))
			document=Trim(oRS("document"))
			link=Trim(oRS("link"))

			If content_type="video" Then
				fileExt=LCase(Mid(video, InStrRev(video,".")+1))
				fileExtTitle=LCase(Mid(video, InStrRev(video,"/")+1))
			ElseIf content_type="image" Then
				fileExt=LCase(Mid(image, InStrRev(image,".")+1))
				fileExtTitle=LCase(Mid(image, InStrRev(image,"/")+1))
			ElseIf content_type="document" Then
				fileExt=LCase(Mid(document, InStrRev(document,".")+1))
				fileExtTitle=LCase(Mid(document, InStrRev(document,"/")+1))
			Else
				fileExt=""
			End If

			If fileExt="pdf" Then
				fileExt="pdf"
			ElseIf fileExt="hwp" Then
				fileExt="hancom"
			ElseIf fileExt="ppt" Then
				fileExt="ppt"
			ElseIf fileExt="xlsx" Or fileExt="xls" Then
				fileExt="excel"
			ElseIf fileExt="zip" Then
				fileExt="zip"
			ElseIf fileExt="txt" Or fileExt="text" Then
				fileExt="papers"
			Else
				fileExt=""
			End If
%>
<% If ii>0 And (ii mod 4)=0 Then %>
						<li style="clear:both">
<% Else %>
						<li>
<% End If %>
							<div class="data_form_thum">
								<a href="javascript:void(0);" title="<%=fileExtTitle %>" onClick="goDnSingle('<%=document %>');">
								<% If thumbnail<>"" Then %>
									<img src="<%=thumbnail %>" />
								<% Else %>
									<img src="/images/renew/noimage.gif" />
								<% End If %>
									<!--<a href="#"><img src="/images/renew/thum/creative/form_thum_01.jpg" /></a>-->
									<div class="down"></div>
									<div class="border"></div>
								</a>
							</div>
							<% If fileExt<>"" Then %>
							<span>
								<img src="/images/renew/sub/<%=fileExt %>_icon.png" /><%=content_title %>
							</span>
							<% End If %>
						</li>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
	Else
%>
							<li>
								<span>
								데이터가 없습니다.
								</span>
							</li>
<%
	End If 
%>
					</ul>
					<div class="box_table_num"><%Call new_pageNavi_ul("goList", page, totpage, 10)%></div>

	<% End If %>
<% ElseIf board=4 Then %> <!--폴다운형 -->
	<script type="text/javascript">
		$(document).ready(function(){
			$(".title_creativity").css("display","none");
			$("#siteTitle").css("display","");
			$(".education_data_title").css("display","none");
			$(".education_list").css("display","none");

			$(".FAQ_subject li::last-child").css("padding-right", "0").css("border", "0");

			if($(".FAQ_subject li").length==0){
				$(".FAQ_subject").css("display", "none");
			}
		});
		function showAns(id){
			$("#ans"+ id).toggle();
			if($("#qns"+ id).hasClass("on")){
				$("#qns"+ id).removeClass("on")
			}else{
				$("#qns"+ id).addClass("on")
			}
		}
	</script>
				<div class="inner">
					<div class="title_freesem type05">
						<span class="ml2"><%=title %></span>
						<span class="title_info" style="margin-top:0;display:inline;font-size:13px;"><%=coment %></span>
					</div>
					<div class="FAQ_subject_wrap">
					<ul class="FAQ_subject">
						<input type="hidden" name="reqQnaTab" id="reqQnaTab" value="<%=reqQnaTab %>" />
						<% 
							Dim tabQna
							SQL="SELECT DISTINCT coment, MAX(orderNo) FROM CP_contents WITH(NOLOCK)"&_
								" WHERE isDelete<>'Y' AND isDisplay=1 AND depth"&typeSeq&"="&seq&_
								" GROUP BY coment ORDER BY MAX(orderNo) ASC"
							Set oRS=g_oDB.Execute(SQL)
							ii=1
							Do While Not(oRS.EOF Or oRS.BOF)
								If reqQnaTab<>"" Then
									tabQna=reqQnaTab
								Else
									If ii=1 Then
										tabQna=Trim(oRS("coment"))
									End If
								End If
						%>
								<li>
									<a href="javascript:showQnATab(<%=selSeq%>, <%=typeSeq %>, <%=getup_seq  %>, <%=geteq  %>, '<%=Trim(oRS("coment")) %>');"<% If (reqQnaTab=Trim(oRS("coment"))) Or (reqQnaTab="" And ii=1) Then%> class="on"<% End If %>><%=Trim(oRS("coment")) %></a>
								</li>
						<%
								ii=ii+1
								oRS.MoveNext
							Loop
							oRS.Close()
						%>
					</ul>
					</div>
					<div class="FAQ_top">
						<div class="faq_classify">구분</div>
						<div class="faq_title">제목</div>					
					</div>
					<ul class="FAQ">
<%
	If count>0 Then
		Dim qnaCnt

		If typeSeq=2 Then
			SQL = "SELECT count(*) as cnt FROM (SELECT ROW_NUMBER() OVER("&orderBy&") AS ROWNUM, c.*,  cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				  " FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&" AND coment='"&tabQna&"')"&_
				" AS list"
		ElseIf typeSeq=3 Then
			SQL = "SELECT count(*) as cnt FROM (SELECT ROW_NUMBER() OVER("&orderBy&") AS ROWNUM, c.*,  cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				  " FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&" AND coment='"&tabQna&"')"&_
				" AS list"
		End If
		'Response.write sql

		Set oRS=g_oDB.Execute(sql)
			qnaCnt=oRS(0)
		Call oRS.close()
		Set oRS = Nothing

		pagesize=10
		totpage=int((qnaCnt-1)/pagesize)+1
		blockpg=pagesize*(page-1)
		If page<1 Then
			page=1
		ElseIf page>totpage Then
			page=totpage
		End If

		If typeSeq=2 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&" AND coment='"&tabQna&"')"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		ElseIf typeSeq=3 Then
			SQL="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&" AND coment='"&tabQna&"')"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		End If
			'Response.write SQL
		Set oRS=g_oDB.Execute(SQL)
		ii=1
		Do While Not(oRS.EOF Or oRS.BOF)
			content_seq=oRS("seq")
			content_title=oRS("title")
			content=Trim(oRS("content"))
			thumbnail=Trim(oRS("thumbnail"))
			coment=Trim(oRS("coment"))
			isDisplay=oRS("isDisplay")
			regDate=Trim(oRS("regDate"))

%>
						<li class="FAQ_con">
							<div class="faq_classify">Q</div>
							<div class="faq_title" id="qns<%=content_seq %>" onClick="javascript:showAns(<%=content_seq %>);"><%=content_title %></div>
							<li class="FAQ_reply" id="ans<%=content_seq %>" style="display:none;">
								<div class="faq_A">A</div>
								<div class="faq_con"><%=content %></div>				
							</li>
						</li>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
	Else
%>
							<li class="FAQ_con">
								<div class="faq_classify"></div>
								<div class="faq_title">데이터가 없습니다.</div>
							</li>
<%
	End If 
%>
					</ul>
					<div class="box_table_num" style="margin-bottom:0;"><%Call new_pageNavi_ul("goList", page, totpage, 10)%></div>
				</div>
<% ElseIf board=5 Then %> <!--Html편집 -->
	<script type="text/javascript">
		$(document).ready(function(){
			$(".title_creativity").css("display","none");
			$("#siteTitle").css("display","");
			$(".education_data_title").css("display","none");
			$(".education_list").css("display","none");
		});
	</script>
<%
	If count>0 Then
		If typeSeq=2 Then
			SQL="SELECT TOP 1 * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" INNER JOIN CP_categoryList AS cl WITH(NOLOCK) ON cl.cp_seq=c.cp_seq AND cl.depth"&typeSeq&"_seq=c.depth"&typeSeq&" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		ElseIf typeSeq=3 Then
			SQL="SELECT TOP 1 * FROM (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, c.seq DESC) AS ROWNUM, c.*, cp.cp_seq AS cp_cp_seq, cp.cp_title AS cp_cp_title"&_
				" FROM "&dbt&" AS c WITH(NOLOCK) INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq"&_
				" "&wquery&seqQuery&")"&_
				" AS list WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		End If
		'Response.write SQL
		Set oRS=g_oDB.Execute(SQL)
		If Not(oRS.EOF Or oRS.BOF) Then 
			content=Trim(oRS("content"))
			'content=Replace(content, "&lt;","<")
			'content=Replace(content, "&gt;",">")
		End If
%>
		<div><%=content %></div>
	<% Else%>
		<div>데이터가 없습니다.</div>
	<% End If%>
<% Else %> <!--0 미선택 -->
	<div style="font-weight:bold;">
		게시판 형태가 미선택된 상태입니다.
	</div>
<% End If %>
				</div>
<% If selSeq=depthSeqStudent Then ' 상단탭 넘침 방지... %>
<script>
//$(".education_list li a").css("box-sizing","border-box");
//$(".education_list li a").css("overflow","hidden");
</script>
<% End If %>
<!--#include virtual='/inc/inc_footer_attention.inc'-->
<!--#include virtual='/inc/end.inc' -->