<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getMediaList"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->

<%
Dim sql, oRS, ii, wquery, sortBy
Dim page, pagesize, initPage, totCnt, totpage
Dim cateB, cateS
Dim tp_seq, img_path, srchTxt, mode, selectNum

Dim getup_seq:getup_seq=util_nte(request("getup_seq"), 0, "int")
Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim geteq:geteq=util_nte(request("geteq"), 0, "int")
Dim getsubeq:getsubeq=util_nte(request("getsubeq"), 0, "int")
Dim cate_code:cate_code=util_nte(request("cate_code"), "", "string")

'Response.write "getup_seq : "&getup_seq&"<br />"
'Response.write "seq : "&seq&"<br />"
'Response.write "geteq : "&geteq&"<br />"
'Response.write "getsubeq : "&getsubeq&"<br />"
'Response.write "cate_code : "&cate_code&"<br />"

cateB=util_nte(request("cateB"), "", "string")
cateS=util_nte(request("cateS"), "", "string")
srchTxt=util_nte(request("srchTxt"), "", "string")
mode=util_nte(request("mode"), "", "string")

'Response.write "cateB : "&cateB&"<br />"
'Response.write "cateS : "&cateS&"<br />"

page=util_nte(request("page"), 1, "int")
selectNum=util_nte(request("selectNum"), 0, "int")
pagesize=12

If selectNum>0 Then pagesize=selectNum

initPage=(page-1)*pagesize

If cateB<>"" Then 'And cateS<>""
	wquery=" cate_code='"&cate_code&"' "
	If cate_code="photo" Then
		wquery=wquery&"AND cateL_code='"& cateB &"' AND cateS_code='"& cateS &"' AND isDisplay='y'"
	Else
		wquery=wquery&"AND key_word LIKE '%"&cateB&" "&cateS&"%' AND isDisplay='y'"
	End If
	If srchTxt<>"" Then wquery=wquery &" AND caption LIKE '%"& srchTxt &"%'"
	sql="SELECT COUNT(*) FROM TP_CMS_MEDIA_MAIN WITH (NOLOCK) WHERE"& wquery
'	Response.write sql &"<br>"
	Set oRS=g_oDB.Execute(sql)
		totCnt=oRS(0)
	Call oRS.close()
	totpage=int((totCnt-1)/pagesize)+1

	If mode="paging" Then
		Call renew_pageNavi_ul("getList", page, totpage, 9)
	End If

	If mode="" Then
		If totCnt>0 Then
	'		sortBy="large_cate_code+middle_cate_code+small_cate_code+detail_cate_code"
			sortBy="tp_seq DESC, reg_user_date DESC"

			sql="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY "& sortBy &") AS ROWNUM,"&_
				" tp_seq, media_seq, caption, file_mng_name, file_type, upload_path, key_word, copyright FROM TP_CMS_MEDIA_MAIN WITH (NOLOCK)"&_
				" WHERE"& wquery&_
				") AS tmp WHERE ROWNUM BETWEEN "& initPage+1 &" AND "& initPage+pagesize
			'Response.write sql &"<br>"
			ii=0
			Set oRS=g_oDB.execute(sql)
			Do While Not (oRS.BOF Or oRS.EOF)
				tp_seq=oRS("tp_seq")
				img_path=CFG_etcMediaPath &"/"& oRS("upload_path") &"/"& oRS("file_mng_name") &"_thumb."& oRS("file_type")
%>
<% If ii>0 And (ii mod 4)=0 Then %>
						<li style="clear:both">
<% Else %>
						<li>
<% End If %>
							<!--<div><a href="javascript:showExPic(<%=tp_seq %>);"><img id="pic<%=tp_seq %>" src="<%=img_path %>" /></a></div>-->
							<div><a href="javascript:etcPhotoDetail(1, <%=getup_seq  %>, <%=geteq  %>, <%=seq%>, <%=getsubeq %>, <%=tp_seq %>, '<%=img_path %>', '<%=Trim(oRS("caption")) %>', '<%=Trim(oRS("key_word")) %>', '<%=Trim(oRS("copyright")) %>', <%=page  %>);"><img id="pic<%=tp_seq %>" src="<%=img_path %>" /></a></div>
							
							<label for="chkSingle<%=tp_seq %>"><span><%=Trim(oRS("caption")) %></span></label>
							<div class="type02">
								<input type="checkbox" name="chkSingle" id="chkSingle<%=tp_seq %>" value="<%=tp_seq %>" onClick="chkSingle(this);" /><label for="chkSingle<%=tp_seq %>"></label>
								<button type="button" onClick="goDnMedia(<%=tp_seq %>);"><p>다운로드</p></button>
								<button type="button" class="type02" onClick="goScrap('<%=tp_seq %>');"><p>스크랩</p></button>
							</div>
						</li>
<%
				ii=ii+1
				oRS.movenext
			Loop
			Call oRS.close()
		Else
%>
						<li>해당 자료가 없습니다.</li>
<%
		End If
%>
						<div class="photo_data_bot">
							<input type="checkbox" name="chkAll" id="chkAll" onClick="checkAll(this);" />
							<label for="chkAll"><span>전체 선택/해지</span></label>
							<% If Left(util_BrowserType(), 4)="msie" Then %>
							<button type="button" onClick="goDnMedia();"><p>다운로드</p></button>
							<% End If %>
							<button type="button" class="type02" onClick="gotoScrap();"><p>스크랩</p></button>
							<button  type="button" class="type03" onClick="location.href='/myLab/?lab=4&labMenu=2&scFromPaper=9'"><p><img src="/images/renew/sub/scrap_icon.png" alt="star_icon">나의 스크랩 바로가기</p></button>
						</div>
<%
	End If ' mode=""
%>
<%
End If
%>
<script>
$(document).ready(function(){
	$("#totCnt").text(<%=totCnt %>);
});
</script>
<!--#include virtual='/inc/end.inc' -->