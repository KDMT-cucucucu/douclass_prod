<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="getSubEtcList"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<%
Dim sql, oRS
Dim page, pagesize:pagesize=4
Dim totpage, initPage
Dim title, thumbnail

Dim tp_seq:tp_seq=util_nte(Trim(request("tp_seq")), 0, "int")
Dim totCnt:totCnt=util_nte(Trim(request("totCnt")), 0, "int")
Dim kew_word:kew_word=util_nte(Trim(request("kew_word")), "", "string")
Dim cate_code:cate_code=util_nte(Trim(request("cate_code")), "", "string")
Dim cateB:cateB=util_nte(Trim(request("cateB")), "", "string")
Dim cateS:cateS=util_nte(Trim(request("cateS")), "", "string")
page=util_nte(Trim(request("page")), 1, "int")
totpage=int((totCnt-1)/pagesize)+1
initPage=(page-1)*pagesize
%>
						<img src="/images/renew/sub/arrow_left_<% If page>1 Then %>on<% Else %>off<% End If %>.png" class="photoData_screen_left_btn"<% If page>1 Then %> onClick="getSubList(<%=(page-1) %>);"<% End If %>>
						<img src="/images/renew/sub/arrow_right_<% If page<totpage Then %>on<% Else %>off<% End If %>.png" class="photoData_screen_right_btn"<% If page<totpage Then %> onClick="getSubList(<%=(page+1) %>);"<% End If %>>
						<ul class="box_photoData_screen clearfix">
<%
If tp_seq>0 Then
		sql="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY tp_seq DESC, reg_user_date DESC) AS ROWNUM,"&_
			" tp_seq, caption, file_mng_name, file_type, upload_path, copyright FROM TP_CMS_MEDIA_MAIN"&_
			" WHERE cate_code='"& cate_code &"' AND tp_seq<>"& tp_seq &" AND isDisplay='y' AND is_delete='N' AND key_word LIKE '"& kew_word &"%'"
		If cate_code="photo" Then 
			If cateB<>"" Then
				sql=sql &" AND cateL_code='"& util_sqlReplacer(cateB) &"'"
			End If 
			If cateS<>"" Then
				sql=sql &" AND cateS_code='"& util_sqlReplacer(cateS) &"'"
			End If 
		End If 
		sql=sql &") AS list"&_
			" WHERE ROWNUM BETWEEN "& initPage+1 &" AND "& initPage+pagesize
'	Response.write sql
	Set oRS=g_oDB.execute(sql)
	Do While Not (oRS.BOF Or oRS.EOF)
		title=Trim(oRS("caption"))
		thumbnail=urlDC & CFG_etcMediaPath &"/"& oRS("upload_path") &"/"& oRS("file_mng_name") &"_thumb."& oRS("file_type")
%>
							<li>
								<img src="<%=thumbnail %>" style="width:132px; height:100px;" onClick="etcPhotoDetailSub(<%=oRS("tp_seq") %>, '<%=thumbnail %>', '<%=title %>', '<%=Trim(oRS("copyright")) %>');">
								<span><%=title %></span>	
							</li>
<%
		Call oRS.moveNext()
	Loop 
	Call oRS.close()
End If 
%>
						</ul>
<!--#include virtual='/inc/end.inc' -->