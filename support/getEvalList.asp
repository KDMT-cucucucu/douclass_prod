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
Dim sql, oRS, ii, curri, sch, sbj, grd
Dim author, part
Dim idx, chpL, itb_type
Dim page, pageSize, initPage, totCnt, totpage, wquery
Dim itb_seq, itb_title, itb_description, itb_hwp, itb_hwp_a, itb_hwp_c, itb_rcnts_seqs, isNew
Dim dbook_seq:dbook_seq=util_nte(request("dbook_seq"), 0, "int")
Dim isNewPaper:isNewPaper=util_nte(request("isNewPaper"), False, "boolean") ' 신규 문제은행 db 사용...

curri=util_nte(request("curri"), "", "string")
sbj=util_nte(request("subject"), "", "string")
author=util_nte(request("author"), "", "string")
grd=util_nte(request("grade"), "", "string")
part=util_nte(request("part"), "", "string")
chpL=util_nte(request("chapL"), "", "string")
itb_type=util_nte(request("itb_type"), "", "string")
If itb_type="0" Then
	itb_type=""
End If 
Dim data2:data2=itb_type
Dim chpQry

page=util_nte(request("page"), 1, "int")
pageSize=30
'Response.write "isNewPaper : "& isNewPaper &"<br />"
%>
<input type="hidden" name="isNewPaper" id="isNewPaper" value="<%=isNewPaper %>" />
<%
	If isNewPaper Then
		wquery=" WHERE ip.spt_idx="& dbook_seq &" AND ip.ipp_isDelete='n'"
	Else 
		wquery= " WHERE itb_UserGrade='admin' AND itb_status>0 AND itb_type<>'06'"&_
				" AND itb_curri='"& curri &"' AND itb_subject='"& sbj &"' AND itb_author='"& author &"' AND itb_grade='"& grd &"'"
		If part<>"" Then ' 국어의 경우...
			wquery=wquery &" AND itb_part='"& part &"'"
		End If 
		If chpL<>"" Then
			chpQry="itb_chapter1 LIKE '%"& chpL &"%' OR (LEFT(itb_chapter2, 2)='"& chpL &"' OR itb_chapter2 LIKE '%,"& chpL &"%') OR (LEFT(itb_chapter3, 2)='"& chpL &"' OR itb_chapter3 LIKE '%,"& chpL &"%')"
			chpQry=" AND ("& chpQry &")"
		End If 
		wquery= wquery & chpQry
	End If 
%>
					<ul class="list_learn_tab">
						<li class="con"><a href="javascript:setData2('');"<% If data2="" Then %> class="on"<% End If %>>전체</a></li>
<%
	If isNewPaper Then
		sql="SELECT pt.ipt_seq AS code, pt.ipt_title AS codeName, p.cnt"&_
			" FROM TP_paperType AS pt"&_
			" INNER JOIN ("&_
			"SELECT ip.ipt_seq, COUNT(ip.ipt_seq) AS cnt FROM TP_paper AS ip"&_
			" INNER JOIN TP_chapter AS sc ON ip.sptChp_idx=sc.idx AND ip.spt_idx=sc.DBook_seq AND sc.chapterL='"& chpL &"'"&_
			wquery &" GROUP BY ip.ipt_seq) AS p ON pt.ipt_seq=p.ipt_seq"&_
			" WHERE pt.ipt_isDelete='n' ORDER BY pt.ipt_orderNo"
		Set oRS=g_oDB.execute(sql)
	Else 
		sql="SELECT l.code, l.codeName, ip.cnt FROM ITB_DC_LIST AS l INNER JOIN"&_
			" (SELECT itb_type, COUNT(itb_type) AS cnt FROM ITB_PAPER"& wquery &_
			" GROUP BY itb_type) AS ip ON l.code=ip.itb_type"&_
			" WHERE l.gr_seq=3 AND l.is_used='y' and l.is_delete='n' ORDER BY l.orderNo"
		Set oRS=g_oItbDB.execute(sql)
	End If 
'	Response.write sql &"<br />"
	
	ii=0
	Do While Not (oRS.BOF Or oRS.EOF)
		Response.write "<li><a href=""javascript:setData2('"& Trim(oRS("code")) &"');"" name='itbType' id='itbType"& Trim(oRS("code")) &"'"
		If itb_type=Trim(oRS("code")) Then
			Response.write " class='on'"
		End If 
		Response.write ">"& Trim(oRS("codeName"))
'		Response.write "("& oRS("cnt") &")"
		Response.write "</a></li>"

		ii=ii+1
		oRS.movenext
	Loop 
	Call oRS.close()
%>
						<div style="border-top: 1px solid #d8d8d8;"></div>
						<div style="border-top: 1px solid #1f4787;margin-top: 48px;"></div>
					</ul>
					<table class="data_catagory_wrap">
						<colgroup>
							<col width="44" />
							<col width="54" />
							<col width="393" />
							<col width="82" />							
							<col width="59" />							
							<col width="58" />
							<col width="75" />
						</colgroup>
						<tbody>
							<tr class="data_catagory_top">
								<td><input type="checkbox" name="chkAll<%=data2 %>" onClick="chkAll(this, '<%=data2 %>');" /></td>
								<td>번호</td>
								<td>제목</td>
								<td>미리보기</td>
								<td colspan="2" style="padding-left:3px">다운로드</td>
								<td style="width: 56px;padding-right: 18px;">스크랩</td>
							</tr>
<%
	If isNewPaper Then
		If itb_type<>"" Then
			wquery=wquery &" AND ip.ipt_seq="& CInt(itb_type)
		End If 

		sql="SELECT COUNT(*) FROM TP_paper AS ip"&_
			" INNER JOIN TP_chapter AS sc ON ip.sptChp_idx=sc.idx AND ip.spt_idx=sc.DBook_seq AND sc.chapterL='"& chpL &"'"& wquery
		Set oRS=g_oDB.execute(sql)
			totCnt=oRS(0)
		Call oRS.close()
	Else 
		If itb_type<>"" Then
			wquery=wquery &" AND itb_type='"& itb_type &"'"
		End If 

		sql="SELECT COUNT(*) FROM ITB_PAPER"& wquery
		Set oRS=g_oItbDB.execute(sql)
			totCnt=oRS(0)
		Call oRS.close()
	End If 
'	Response.write sql &"<br /><br />"
	totpage=int((totCnt-1)/pagesize)+1

	Dim pvPath, pvCnt
	If totCnt>0 Then
		If isNewPaper Then
			sql="WITH VLogs AS("&_
				"SELECT ROW_NUMBER() OVER(ORDER BY ipp_regDate) AS rownum"&_
				", ipp_seq AS itb_seq, ipp_title AS itb_title, '' AS itb_description, ipp_hwp AS itb_hwp, ipp_hwp_a AS itb_hwp_a, '' AS itb_hwp_c, '' AS itb_rcnts_seqs, 'n' AS itb_isNew, '' AS itb_isNewDate, ISNULL(pv.pv_path, '') AS pvPath, ISNULL(pv.pv_cnt, 0) AS pvCnt"&_
				" FROM TP_paper AS ip INNER JOIN TP_chapter AS sc ON ip.sptChp_idx=sc.idx AND ip.spt_idx=sc.DBook_seq AND sc.chapterL='"& chpL &"'"&_
				" LEFT JOIN PreView_data AS pv ON pv.dataFrom='paper' AND ip.ipp_seq=pv.dataSeq AND pv.pv_status=99"&_
				 wquery &")"&_
				"SELECT * FROM VLogs WHERE rownum BETWEEN " & ((page-1)*pagesize+1) &" AND " & (page*pagesize) & " ORDER BY rownum"
			Set oRS=g_oDB.execute(sql)
		Else 
			sql="WITH VLogs AS("&_
				"SELECT ROW_NUMBER() OVER(ORDER BY itb_title , itb_updDate DESC) AS rownum, itb_seq, itb_title, itb_description, itb_hwp, itb_hwp_a, itb_hwp_c, itb_rcnts_seqs, itb_isNew, itb_isNewDate, ISNULL(pv.pv_path, '') AS pvPath, ISNULL(pv.pv_cnt, 0) AS pvCnt"&_
				" FROM "& itbDBstr &"ITB_PAPER"&_
				" LEFT JOIN PreView_data AS pv ON pv.dataFrom='itb' AND itb_seq=pv.dataSeq AND pv.pv_status=99"&_
				wquery &")"&_
				"SELECT * FROM VLogs WHERE rownum BETWEEN " & ((page-1)*pagesize+1) &" AND " & (page*pagesize) & " ORDER BY rownum"
'			Set oRS=g_oItbDB.execute(sql)
			Set oRS=g_oDB.execute(sql)
		End If 
'		Response.write sql &"<br />"

		ii=0
		Do While Not (oRS.BOF Or oRS.EOF)
			itb_seq=oRS("itb_seq")
			itb_title=Trim(oRS("itb_title"))
			itb_description=Trim(oRS("itb_description"))
			itb_hwp=Trim(oRS("itb_hwp"))
			itb_hwp_a=Trim(oRS("itb_hwp_a"))
			itb_hwp_c=Trim(oRS("itb_hwp_c"))
			'itb_rcnts_seqs

			If Trim(oRS("itb_isNew"))="y" And CStr(Date())<=Trim(oRS("itb_isNewDate")) Then ' 신규icon
				isNew=True
			Else 
				isNew=False
			End If

			pvPath=Trim(oRS("pvPath"))
			pvCnt=oRS("pvCnt")
			If pvPath="" Or pvCnt<1 Then
				pvPath=""
			Else
'				pvPath="<button type=""button"" onClick=""javascript:initPreDoc("& pvCnt &", '"& pvPath &"', '"& itb_title &"');"" style=""margin-right: -6px;background:#455879;border:1px solid #3d4c61;""><p>미리보기</p></button>"
				pvPath="<button type=""button"" class=""btn_preview"" onClick=""javascript:initPreDoc("& pvCnt &", '"& pvPath &"', '"& Replace(itb_title, "'", "\'") &"');"" style=""float: left;""><img src=""/images/sub/icon_previewSearch.png"" style=""margin-right: 2px;position: relative;top: -1px;margin-left: 0;vertical-align:middle""/>미리보기</button>"
			End If

			ii=ii+1
%>
							<tr>
								<td><input type="checkbox" name="chkSingle<%=data2 %>" onClick="chkSingle(this);" value="<%=itb_seq %>" /></td>
								<td><%=(page-1)*pagesize+ii %></td>
								<td class="data_name"><%=itb_title %><% If isNew Then %>&nbsp;&nbsp;<img src="/images/sub/icon_exnew.png" /><% End If %></td>
								<td><%=pvPath %></td>
								<td colspan="2" class="tr">
									<button type="button" class="paper_btn" id="btnItb<%=itb_seq %>" <% If itb_hwp<>"" Then %>onClick="goDN(<%=itb_seq %>,'<%=itb_hwp%>', '', <%=isNewPaper %>);"<% End If %>><p>문제지</p></button>
									<button type="button" class="paper_btn02" id="btnItbA<%=itb_seq %>" <% If itb_hwp_a<>"" Then %>onClick="goDN(<%=itb_seq %>,'<%=itb_hwp_a%>', '_a', <%=isNewPaper %>);"<% End If %>><p>정답지</p></button>
								</td>
								<td class="tl">
									<button type="button" class="scrape_btn" onClick="gotoScrap(<%=itb_seq %>, <%=isNewPaper %>);"><p>스크랩</p></button>
								</td>
							</tr>
<%
			oRS.movenext
		Loop 
		Call oRS.close()
	Else
%>
							<tr><td colspan="6">해당 자료가 없습니다.</td></tr>
<%
		Call util_log("logSql", "/support/getEvalList.asp - id : "& g_MEM.uid &" | "& Request.ServerVariables("QUERY_STRING"))
		Call util_log("logSql", "/support/getEvalList.asp : "& sql)
	End If 
%>
							<tr class="data_catagory_bottom">
								<td colspan="10">
									<input type="checkbox" class="chkItb" name="chkAll<%=data2 %>" id="chkAll<%=data2 %>" onClick="chkAll(this, '<%=data2 %>');" />
									<span style="margin-top: 2px;"><label for="chkAll<%=data2 %>">전체 선택/해지</label></span>
									<% If InStr(util_BrowserType(), "msie") Then %>
										<button type="button" onClick="goDNMulti('<%=data2 %>');"><p>다운로드</p></button>
									<% Else %>
										<button type="button" onClick="goDNMultiChrom('<%=data2 %>');" title="nonIE"><p>다운로드</p></button>
									<% End If %>
									<button type="button" name="scr<%=data2 %>" style="margin-left: 5px;" onClick="scrapMulti('<%=data2 %>', <%=isNewPaper %>);"><p>스크랩</p></button>
									<button type="button" style="margin-left: -6px;float:right;margin-right: 11px;" onClick="<% If chkIsCerti() Then %>location.href='<%=urlMyLab %>?labMenu=2';<% Else %>menu_o.openAlertPop(null, null, null, 11);<% End If %>"><p style="width:141px;"><img src="/images/renew/sub/scrap_icon.png" style="padding-right:5px;margin-left: -3px;margin-bottom: 2px;"alt="star_icon"/>나의 스크랩 바로가기</p></button>
								</td>
							</tr>							
						</tbody>						
					</table>

<% If totCnt>0 Then %>
					<div class="box_table_num">
						<ul class="clearfix">
<% Call pageNaviRenew("setPage", page, totpage, 9) %>
						</ul>
					</div>
<% End If %>
<form name="fmItbList" method="post">
<input type="hidden" name="itb_seqs" value="" />
</form>
<!--#include virtual='/inc/end.inc' -->