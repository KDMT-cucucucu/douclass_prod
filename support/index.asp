<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="support_dataClass"
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual='/inc/topmenu_renewal.inc' -->
<!--<script language="JavaScript" type="text/javascript" src="/js/admin_itembank.js"></script>-->
<%
Dim sql, oRS, ii, wquery, ordBy, cols
Dim sch, sbj, data1, data2, unit, book_seq, schNo, grade, season, stepE, page, pageSize, initPage, totCnt, totpage
Dim classAsp:classAsp="index.asp" ' 수업자료
Dim evalAsp:evalAsp="dataEval.asp" ' 평가자료
Dim thisAsp:thisAsp=classAsp
Dim arrChp, divChpNum, arrLeft, arrData, arrList, files
Dim seq, title, isOn, jj, position:position="support"
Dim mmType:mmType=util_nte(Trim(request("mmType")), "", "string")
Dim curri, old_curri

sch=util_nte(request("sch"), "M", "string") ' 학교
sbj=util_nte(request("sbj"), "", "string") ' 과목
book_seq=util_nte(request("book_seq"), 0, "int") ' 교재
data1="S" ' util_nte(request("data1"), "S", "string") ' 자료 - 수업자료:S, 평가자료:T
data2=util_nte(request("data2"), "", "string") ' 수업자료 - 공통:Common, 단원별:Suppor, 멀티미디어:Multimedia, 평가자료 - 전체:"", 나머지 숫자 타입...
unit=util_nte(request("unit"), "01", "string") ' 단원
grade=util_nte(request("grade"), 1, "int") ' 학년
season=util_nte(request("season"), 1, "int") ' 학기

page=util_nte(request("page"), 1, "int")
pageSize=20
initPage=(page-1)*pagesize

If sch="E" Then 
	schNo=0
	If sbj="" Then
		sbj="K"
		If book_seq=0 Then 
			book_seq=378 ' /js/gnb/itbDnSbjListE.js 수학1-1 ...
		End If 
	End If 
ElseIf sch="M" Then
	schNo=1
	If sbj="" Then
		sbj="K"
	ElseIf sbj="C" Then ' 사회...
		sbj="O"
	ElseIf sbj="D" Then ' 도덕...
		sbj="R"
'	ElseIf (sbj="I" Or sbj="N") Then ' 선택...
'		sbj="0"
	End If 
ElseIf sch="H" Then 
	schNo=2
	If sbj="" Then
		sbj="K"
	End If
End If 

If data1="S" And data2="" Then ' 수업자료:단원별 수업자료 default
	data2="Support"
ElseIf data1="T" And data2<>"" And Not isNumeric(data2) Then ' 평가자료:전체 default 
	data2=""
End If 
%>
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
<input type="hidden" name="mmType" id="fm_mmType" value="<%=mmType %>" />
</form>

	<div class="sub_wrap">
		<div class="box_sub_con type04 clearfix">
			<div class="sub_left">				
				<ul class="list_smart_tab type03 clearfix">
					<li><a href="<%=thisAsp %>?sch=E" rel="slnb0"<% If sch="E" Then %> class="on"<% End If %>>초등</a></li>
					<li><a href="<%=thisAsp %>?sch=M" rel="slnb1" class="middle_line<% If sch="M" Then %> on<% End If %>">중등</a></li>
					<li><a href="<%=thisAsp %>?sch=H" rel="slnb2"<% If sch="H" Then %> class="on"<% End If %>>고등</a></li>
				</ul>
				<div style="width:213px;height:8px;border-left:1px solid #dddddd;border-right:1px solid #dddddd;"></div>
				<div id="slnb<%=schNo %>" class="box_smart_sub">
					<ul class="list_accordion">
<% 
If sch="E" Then ' 초등. js에서 관리...
	stepE=grade + season + (grade-3)
	If sbj="recommand" Then 
		stepE=-1
	End If 
%>
<script language="JavaScript" type="text/javascript" src="/js/gnb/itbDnSbjListE.js?unic=<%=util_unic() %>"></script>
<script>
try{
	var arrSch=gnbItbDnSbjListE0;
	for (var i=0; i<arrSch.length; i++){
		var j=0;
		var tmp='<li id="li_sbj'+ i +'">';
		var grd=parseInt(arrSch[i][0][3]); // 학년
		var ssn=parseInt(arrSch[i][0][4]); // 학기
		tmp+='<a onClick="showSbjTitleE('+ i +', '+ grd +', '+ ssn +');" class="title'; // 학년학기 클릭...
		if (i==<%=stepE %>){
			tmp+=' on';
		}
		tmp+='" style="cursor:pointer;">'+ grd +'학년 '+ ssn + '학기</a>';
		if (i==<%=stepE %>){
			tmp+=getSbjItemE(i, <%=book_seq %>);
		}
		tmp+='</li>';

		document.write(tmp);
	}
	// ' 161018 창체의 '과목별 추천사이트' 이동...
	var tmp='<li id="li_sbj'+ i +'">';
	tmp+='<a onClick="showSbjTitleE('+ i +', 0, 0);" class="title';
	if ("<%=sbj %>"=="recommand"){
		tmp+=' on';
	}
	tmp+='" style="cursor:pointer;">과목별 추천사이트</a>';
	if ("<%=sbj %>"=="recommand"){
		tmp+=getSbjItemE(i, 0);
	}
	tmp+='</li>';
	document.write(tmp);
}catch(e){}
</script>
<% 
Else ' 중등/고등. db에서 관리...
%>
<script>

</script>
<%
	sql="SELECT TOP 15 img.sbj FROM TP_sortingSubject AS srt INNER JOIN TP_imageList AS img ON srt.sch=img.sch AND srt.sbj=img.sbj"&_
		" WHERE srt.sch='"& sch &"' AND img.img_position='"& position &"' AND img.Dbook_seq=0 AND img.sub_position IS NULL AND ISNUMERIC(srt.sbj)=0"&_
		" ORDER BY srt.orderNo"
'	Response.write sql
	Set oRS=g_oDB.execute(sql)
	If Not (oRS.BOF Or oRS.EOF) Then
		arrLeft=oRS.GetRows()
	End If 
	Call oRS.close()

	Dim reSbj
	If isArray(arrLeft) Then
		For ii=0 To UBound(arrLeft, 2)
%>
						<li id="li_sbj<%=ii %>">
							<a href="javascript:showSbjTitle(<%=ii %>, '<%=arrLeft(0, ii) %>')" class="title<% If sbj=arrLeft(0, ii) Then %> on<% End If %>"><script>document.write(getSbjTitle("<%=arrLeft(0, ii) %>"));</script></a>
<%			If sbj=arrLeft(0, ii) Then 
				' chkSbjGrp 함수 start.inc에 있음...
''				reSbj=chkSbjGrp(sbj)
				reSbj=sbj
				sql="SELECT db.seq, db.Title, db.writer, img.imgPath, db.base_turn AS curri, dp.orderNo FROM DBookServiceInfo AS db"&_
					" LEFT JOIN TP_dpList AS dp ON dp.dbook_seq=db.seq"&_
					" LEFT JOIN TP_imageList AS img ON db.seq=img.Dbook_seq"&_
					" WHERE db.is_delete<>'Y' AND dp.menu_position='"& position &"' AND dp.sch='"& sch &"' AND dp.sbj IN ('"& reSbj &"') "&_
					" AND img.img_position='"& position &"'  AND img.sub_position IS NULL AND db.base_turn>='09'"
				sql=sql &" ORDER BY dp.orderNo, db.base_turn DESC"
'				Response.write sql
				Set oRS=g_oDB.execute(sql)
				jj=0
				If Not (oRS.BOF Or oRS.EOF) Then
%>
<div class="con">
	<ul class="list_accordion_sub">
<%
				old_curri=""
				Do While Not (oRS.BOF Or oRS.EOF)
					seq=Trim(oRS("seq"))
					title=Trim(oRS("title"))
					isOn=""
					If (book_seq=0 And jj=0) Or (book_seq=CInt(seq)) Then
						isOn=" class='on'"
					End If 

					curri=Trim(oRS("curri"))
					If curri<>old_curri Then
%>
		<li class="divi_tit_icon divi_20<%=curri %>"><img src="/images/renew/sub/icon_tit_<%=curri %>.png" /></li>
<%
					End If 
%>
		<li><span></span><a href="javascript:goPage(<%=seq %>, '<%=sbj %>');"<%=isOn %>><%=title %></a></li>
<%
					If book_seq=0 And jj=0 Then ' 기본값 세팅...
						book_seq=seq %>
						<script>setParam("book_seq", <%=book_seq %>)</script>
<%					End If 

					old_curri=curri
					jj=jj+1
					oRS.movenext
				Loop 
%>
	</ul>
</div>
<%
				End If 
				Call oRS.close()
			End If %>
						</li>
<%
		Next 
		Erase arrLeft
	End If 

	' 161018 창체의 '과목별 추천사이트' 이동...
	title="과목별 추천사이트"
	reSbj="recommand"
%>
						<li id="li_sbj<%=ii %>">
							<a href="javascript:showSbjTitle(<%=ii %>, '<%=reSbj %>')" class="title<% If sbj=reSbj Then %> on<% End If %>"><%=title %></a>
<%	If sbj=reSbj Then %>
<div id="LNB_<%=reSbj %>" class="con">
	<ul class="list_accordion_sub">
<li><span></span><a href="javascript:goPage(0, '<%=reSbj %>');" class='on'><%=title %></a></li>
	</ul>
</div>
<%	End If %>
						</li>
<%
End If ' left 끝...
%>
					</ul>
				</div>
				<!-- <a href="<%=urlCd %>"><img src="/images/renew/sub/LNB_box_bn.jpg" /></a> -->
<!--#include virtual="/inc/inc_lnb_banner.asp"-->
			</div>
<%
Dim book_title, base_turn, idxChapter
Dim ucIdx, isNew, icons, isNewDate ' 수업자료...

Dim isEval:isEval=True ' 평가자료 노출 여부...
If sch="E" And (book_seq=38 Or (book_seq>=25 And book_seq<=29)) Then ' 창체...
	isEval=False 
ElseIf sch="M" And (book_seq=215 Or book_seq=216) Then ' 진로와직업...
	isEval=False 
ElseIf sch="H" And (book_seq=212 Or book_seq=37) Then ' 교양, 창체
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

If base_turn="15" Then ' 180110 15개정 추가분 평가자료 미준비... -> 버튼 노출 안되게...
	isEval=False 

	If sch="M" And InStr("|393|402|403|400|401|392|407|399|396|408|404|405|397|398|394|", "|"& CStr(book_seq) &"|") Then 
		isEval=True
	ElseIf sch="H" And InStr("|409|411|422|415|416|412|418|414|413|410|417|423|", "|"& CStr(book_seq) &"|") Then 
		isEval=True
	ElseIf sch="E" And InStr("|386|387|", "|"& CStr(book_seq) &"|") Then 
		isEval=True
	End If 
End If 
%>
			<div class="sub_right">
<%
If sbj="recommand" Then ' 161018 창체의 '과목별 추천사이트' 이동...
%>
<iframe src="/html/getRecommendSite.html" style="width:800px;height:1200px;"></iframe>
<%
Else ' 161018 창체의 '과목별 추천사이트' 이동...
%>
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
							<li style="margin-right:5px"><a href="javascript:setData1('S');"<% If data1="S" Then %> class="on"<% End If %>>수업자료</a></li>
							<li><% If isEval Then %><a href="javascript:setData1('T');"<% If data1="T" Then %> class="on"<% End If %>>평가자료</a><% End If %></li>
						</ul>
					</div>
					<!-- 자료 -->
					<div class="learn_data_con">
						<ul>
<%
sql="SELECT idx, chapterL, title FROM TP_chapter WITH(NOLOCK)"&_
	" WHERE DBook_seq="& book_seq &" AND is_delete='n' AND chapterL<>'' AND (chapterM='' OR chapterM='00') AND (chapterS='' OR chapterS='00')"&_
	" ORDER BY chapterL, pages"
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
						
<%
If data1="S" Then ' num icon
	sql="SELECT idx_unit, pk_title, pk_files FROM TP_PopularKeyword WHERE pk_delete='n' AND DBook_seq="& book_seq &" ORDER BY pk_order"
'	Response.write sql &"<br />"
	Set oRS=g_oDB.execute(sql)
	If Not (oRS.BOF Or oRS.EOF) Then
		arrData=oRS.GetRows()
	End If 
	Call oRS.close()

	If isArray(arrData) Then 
%>
						<div id="dnCmnContent" class="leaning_data">  
							<div><img src="/images/sub/learning_search.png" style="margin-right:5px;"/>많이 찾는 자료</div>
							<ul class="list">
<%		For ii=0 To UBound(arrData, 2) %>
								<li<% if ii=UBound(arrData, 2) Then %> class="last"<% End If %>><img src="/images/sub/text_<%=ii+ 1%>.png" /> <% If arrData(0, ii)>0 Then %><a href="javascript:goDN('<%=arrData(0, ii) %>', '<%=arrData(2, ii) %>');"><% Else %><a href="<%=arrData(2, ii) %>"><% End If %><%=arrData(1, ii) %></a></li>
<%
		Next
		Erase arrData
%>
							</ul>
						</div>
<%
	End If 
End If
%>
					</div>

<%
If data1="S" Then ' num icon
%>
					<ul class="list_learn_tab">
						<li class="con"><a href="javascript:setData2('Common');"<% If data2="Common" Then %> class="on"<% End If %>>공통자료</a></li>
						<li class="con"><a href="javascript:setData2('Support');" class="learn_tab_second<% If data2="Support" Then %> on<% End If %>">단원별 수업자료</a></li>
						<li class="con"><a href="javascript:setData2('Multimedia');" class="learn_tab_third<% If data2="Multimedia" Then %> on<% End If %>">단원별 멀티미디어 자료 </a></li>
						<div style="border-top: 1px solid #d8d8d8;"></div>
						<div style="border-top: 1px solid #1f4787;margin-top: 48px;"></div>
					</ul>
					<table class="data_catagory_wrap">
						<colgroup>
							<col width="44" />
							<col width="54" />
							<col width="48" />
							<col width="388" />
							<col width="76" />
							<col width="79" />
							<col width="76" />
						</colgroup>
						<tbody>
							<tr class="data_catagory_top">
								<td><input type="checkbox" name="chkAll<%=data2 %>" onClick="chkAll(this, '<%=data2 %>');" /></td>
								<td>번호</td>
								<td>분류</td>
							<% If data2="Multimedia" Then %>
								<td>제목
								<% If data2="Multimedia" Then %>
								<select name="mmSel" id="mmSel" class="styled-select" style="width:74px;height:20px;padding-right:0px;" onChange="setData2('Multimedia');">
									<option value="">전체</option>
									<option value="video"<% If mmType="video" Then %> selected<% End If %>>동영상</option>
									<option value="swf"<% If mmType="swf" Then %> selected<% End If %>>플래시</option>
									<option value="img"<% If mmType="img" Then %> selected<% End If %>>이미지</option>
								</select>
								<% End If %>
								</td>
								<td>미리보기</td>
							<% Else %>
								<td colspan="2">제목</td>
							<% End If %>
								<td>다운로드</td>
								<td style="width: 56px;padding-right: 18px;">스크랩</td>
							</tr>
<%
	wquery=" WHERE DBook_seq="& book_seq &" AND content_type='S' AND UserGrade>=100 AND is_delete='n'"
	ordBy="ORDER BY orderNo, subSE_type, idx"
	cols="idx, title, files, file_type, isNew, isNewDate, '' AS pvPath, 0 AS pvCnt"

	sql="SELECT 0 AS ROWNUM, "& cols &" FROM TP_unitContents"

	If data2="Multimedia" Then
		wquery=wquery &" AND idx_chapter="& idxChapter &" AND SE_type=1"
		If mmType="video" Then
			wquery=wquery &" AND file_type IN ('avi', 'flv', 'mp4', 'wmv')"
		ElseIf mmType="swf" Then
			wquery=wquery &" AND file_type='swf'"
		ElseIf mmType="img" Then
			wquery=wquery &" AND file_type IN ('jpg', 'png')"
		End If 
		sql="SELECT COUNT(*) FROM TP_unitContents"& wquery
'		Response.write sql &"<br />"
		Set oRS=g_oDB.execute(sql)
			totCnt=oRS(0)
		Call oRS.close()
		totpage=int((totCnt-1)/pagesize)+1

		If totCnt>0 Then 
			sql="SELECT * FROM ("&_
				"SELECT ROW_NUMBER() OVER("& ordBy &") AS ROWNUM, "& cols &" FROM TP_unitContents"& wquery &_ 
				") AS tmp "&_
				" WHERE ROWNUM BETWEEN "& initPage+1 &" AND "& initPage+pagesize
		Else
			sql=""
		End If 
	Else
		sql=replace(sql, "'' AS pvPath", "ISNULL(pv.pv_path, '') AS pvPath")
		sql=replace(sql, "0 AS pvCnt", "ISNULL(pv.pv_cnt, 0) AS pvCnt")
		sql=sql &_
			" LEFT JOIN PreView_data AS pv ON pv.dataFrom='support' AND idx=pv.dataSeq AND pv.pv_status=99" ' 미리보기 경로...

		If data2="Common" Then
			sql=sql & wquery &_
				" AND idx_chapter IS NULL AND SE_type=0 AND subSE_type IS NULL "& ordBy
		ElseIf data2="Support" Then
			sql=sql & wquery &_
				" AND idx_chapter="& idxChapter &" AND SE_type=0 "& ordBy
		Else
			sql=""
		End If 
	End If 	
'	Response.write sql &"<br />"
	If sql<>"" Then
		Set oRS=g_oDB.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			arrList=oRS.GetRows()
		End If 
		Call oRS.close()
	End If 

	Dim pvPath, pvCnt ' 미리보기...
	If isArray(arrList) Then
		For ii=0 To UBound(arrList, 2)
			ucIdx=arrList(1, ii)
			title=Trim(arrList(2, ii))
			files=Trim(arrList(3, ii))
			icons="<img src='"& printIconRenew(arrList(4, ii)) &"' style='width:21px;height:20px;' />"
			isNew=arrList(5, ii)
			isNewDate=arrList(6, ii)
			pvPath=arrList(7, ii)

			If data2="Multimedia" Then ' mp3 : /images/navi/main/icon_active_play.png ?
				If InStr("|avi|flv|mp3|mp4|swf|wmv|", arrList(4, ii))=0 Then
					pvPath=""
				Else 
					pvPath="<button class=""btn_preview"" type=""button"" onClick=""fncPreview("& ucIdx &", 'media');""><img src=""/images/sub/icon_previewSearch.png"">미리보기</button>"
				End If 
			Else
				pvCnt=arrList(8, ii)
				If pvPath="" Or pvCnt<1 Then
					pvPath=""
				Else
'					pvPath="<button type=""button"" onClick=""javascript:initPreDoc("& pvCnt &", '"& pvPath &"', '"& title &"');"" style=""margin-right: -6px;background:#455879;border:1px solid #3d4c61;""><p>미리보기</p></button>"
					pvPath="<button type=""button"" onClick=""javascript:initPreDoc("& pvCnt &", '"& pvPath &"', '"& Replace(title, "'", "\'") &"');"" style=""padding: 0 0 1px;width: 77px;margin-right: 0;background:#838383;border:1px solid #767676;""><img src=""/images/sub/icon_previewSearch.png"" style=""margin-right: 2px;position: relative;top: -1px;margin-left: 0;vertical-align:middle""/>미리보기</button>"
				End If
			End If 
%>
							<tr>
								<td><input type="checkbox" name="chkSingle<%=data2 %>" value="<%=ucIdx %>" onClick="chkSingle(this);" /></td>
								<td><%=ii + 1 + initPage %></td>
								<td><%=icons %></td>
								<td class="data_name">
									<span><%=title %></span><% If chkIsNew(isNew, isNewDate) Then %>&nbsp;&nbsp;<img src="/images/renew/sub/icon_exnew.png" /><% End If %>
								</td>
								<td><%=pvPath %></td>
								<td><button type="button" onClick="goDN(<%=ucIdx %>, '<%=files %>');"><p>다운로드</p></button></td>
								<td><button type="button" class="edu_scrap" onClick="goScrap(<%=ucIdx %>);"><p>스크랩</p></button></td>
							</tr>
<%
		Next 
		Erase arrList
	Else
%>
							<tr><td colspan="10">해당 자료가 없습니다.</td></tr>
<%
	End If 
%>
							<tr class="data_catagory_bottom">
								<td colspan="10">
									<input type="checkbox" name="chkAll<%=data2 %>" id="chkAll<%=data2 %>" onClick="chkAll(this, '<%=data2 %>');" />
									<span style="margin-top: 2px;"><label for="chkAll<%=data2 %>">전체 선택/해지</label></span>
									<% If InStr(util_BrowserType(), "msie") Then %>
										<button type="button" onClick="goDNMulti('<%=data2 %>');"><p>다운로드</p></button>
									<% Else %>
										<button type="button" onClick="goDNMultiChrom('<%=data2 %>');" title="nonIE"><p>다운로드</p></button>
									<% End If %>
									<button type="button" name="scr<%=data2 %>" style="margin-left: 5px;" onClick="scrapMulti('<%=data2 %>');"><p>스크랩</p></button>
									<button type="button" style="margin-left: -6px;float:right;margin-right: 11px;" onClick="<% If chkIsCerti() Then %>location.href='<%=urlMyLab %>?labMenu=2';<% Else %>menu_o.openAlertPop(null, null, null, 11);<% End If %>"><p style="width:141px;"><img src="/images/renew/sub/scrap_icon.png" style="padding-right:5px;margin-left: -3px;margin-bottom: 2px;"alt="star_icon"/>나의 스크랩 바로가기</p></button>
								</td>
							</tr>							
						</tbody>						
					</table>
<%
End If
%>
<% If totCnt>0 Then %>
					<div class="box_table_num">
						<ul class="clearfix">
<% Call pageNaviRenew("setPage", page, totpage, 9) %>
						</ul>
					</div>
<% End If %>

				</div>
<%
End If ' 161018 창체의 '과목별 추천사이트' 이동...
%>
<!--#include virtual='/inc/inc_footer_attention.inc'-->
			</div>
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