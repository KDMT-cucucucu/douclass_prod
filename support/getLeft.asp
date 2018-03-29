<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="support_getLeft"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<%
Dim sql, oRS, ii
Dim sch, sbj, position:position="support"
Dim seq, title, book_seq, curri, old_curri

sch=util_nte(request("sch"), "M", "string")
sbj=util_nte(request("sbj"), "K", "string")
book_seq=util_nte(request("book_seq"), 0, "int")
%>
<div class="con">
	<ul class="list_accordion_sub">
<%
	If sbj="recommand" Then ' 161018 창체의 '과목별 추천사이트' 이동...
		title="과목별 추천사이트"
%>
<li><span></span><a href="javascript:goPage(0, '<%=sbj %>');"><%=title %></a></li>
<%
	Else 

	' chkSbjGrp 함수 start.inc에 있음...
	sql="SELECT db.seq, db.Title, db.writer, img.imgPath, db.base_turn AS curri, dp.orderNo FROM DBookServiceInfo AS db"&_
		" LEFT JOIN TP_dpList AS dp ON dp.dbook_seq=db.seq"&_
		" LEFT JOIN TP_imageList AS img ON db.seq=img.Dbook_seq"&_
		" WHERE db.is_delete<>'Y' AND dp.menu_position='"& position &"' AND dp.sch='"& sch &"' AND dp.sbj IN ('"& chkSbjGrp(sbj) &"') "&_
		" AND img.img_position='"& position &"'  AND img.sub_position IS NULL AND db.base_turn>='09'"
	sql=sql &" ORDER BY dp.orderNo, db.base_turn DESC"
'	Response.write sql
	Set oRS=g_oDB.execute(sql)
	ii=0
	Do While Not (oRS.BOF Or oRS.EOF)
		seq=Trim(oRS("seq"))
		title=Trim(oRS("title"))
		curri=Trim(oRS("curri"))
'		If seq=143 Or seq=144 Or seq=145 Or seq=146 Or seq=152 Or seq=158 Or seq=159 Or seq=161 Or seq=160 Or seq=162 Or seq=163 Then '(2007년 개정) 출력
'			title=title&" (2007년 개정)"
'		End If
		If curri<>old_curri Then
%>
			<li class="divi_tit_icon divi_20<%=curri %>"><img src="/images/renew/sub/icon_tit_<%=curri %>.png" /></li>
<%
		End If
%>
		<li><span></span><a href="javascript:goPage(<%=seq %>, '<%=sbj %>');"<% If book_seq=CInt(seq) Then %> class="on"<% End If %>><%=title %></a></li>
<%
		old_curri=curri
		ii=ii+1
		oRS.movenext
	Loop
	Call oRS.close()
	Set oRS=Nothing 

	End If 
%>
	</ul>
</div>
<!--#include virtual='/inc/end.inc' -->