<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="scrap"
%>
<!--#include virtual='/inc/start.inc' -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%
Dim UserID:UserID=g_mem.uid
Dim sPosition:sPosition=util_nte( request("sPosition"), 0, "int" )
Dim selSeq:selSeq=util_nte( request("selSeq"), 1, "int" )
Dim scIdxs:scIdxs=util_nte( request("scIdxs"), "", "string" )
Dim content_type:content_type="C"
Dim mode:mode=util_nte( request("mode"), "", "string" )
Dim src_tbl, tar_tbl, toMyLab
Dim compMsg, dupMsg
Dim lab

'Response.write "sPosition : "&sPosition&"<br />"

If sPosition = 3 Then
	src_Tbl = "TP_questions"
	tar_tbl = "TP_myItemBank"
	toMyLab=4 	' 나의 문제지로 이동
	compMsg = "나의 문제지에 저장되었습니다.\n나의 문제지로 이동하시겠습니까?"
	dupMsg = "이미 저장 하셨습니다."
ElseIf sPosition = 8 Then
	src_Tbl = "TP_unitContents"
	tar_tbl = "TP_myScrap"
	toMyLab=4 	' 나의 문제지로 이동
	compMsg = "나의 문제지에 저장되었습니다.\n나의 문제지로 이동하시겠습니까?"
	dupMsg = "이미 저장 하셨습니다."
Else 
	src_Tbl = "CP_contents"
	tar_tbl = "CP_myScrap"
	toMyLab=2 	' 나의 스크랩으로 이동
	compMsg = "스크랩이 완료되었습니다."
	dupMsg = "이미 스크랩 하셨습니다."
End If 

If sPosition=9 Or sPosition=4 Then
	lab=4
Else
	lab=2
End If

Dim BrowserType:BrowserType=util_BrowserType()

If UserID<>"" And scIdxs<>"" Then
	
	Dim sql, oRS, ii, arrRows, isNum:isNum = True
	Dim notExistIdxs:notExistIdxs=""

	If mode="del" Then
'		Call g_oDB.BeginTrans()

		If sPosition<>9 Then ' 사진자료실 아니면...
			sql = "UPDATE tu SET tu.scrapCnt=tu.scrapCnt-1 FROM "&src_Tbl&" tu"&_
				  " INNER JOIN "&tar_tbl&" sc ON tu.seq=sc.idx_contents"&_
				  " WHERE sc.idx_contents IN ("& scIdxs &") AND sc.UserID='"& UserID &"'"
			'Response.write sql
			'If src_Tbl = "TP_unitContents" Then sql = sql & " AND tu.UserGrade<100"
			Call g_oDB.Execute(sql)
			If Err.Number <>0 then
'				Call g_oDB.RollbackTrans()
				Call util_log("Error", Err.Description)
				Call util_alert("변경에러","")
			end If
		End If
		
		If sPosition<>9 Then ' 사진자료실 아니면...
			sql = "DELETE "&tar_tbl&" WHERE idx_contents IN ("& scIdxs &") AND UserID='"& UserID &"'"
		Else
			tar_tbl="TP_myScrap"
			sql = "DELETE "&tar_tbl&" WHERE idx IN ("& scIdxs &") AND UserID='"& UserID &"'"
		End If
		'Response.write sql
		Call g_oDB.Execute(sql)
		If Err.Number <>0 then
'			Call g_oDB.RollbackTrans()
			Call util_log("Error", Err.Description)
			Call util_alert("변경에러","")
		end If

'		Call g_oDB.CommitTrans()
%>
<script type="text/javascript">
//<![CDATA[
//	alert("삭제 했습니다.");
	var sPosition=<%=sPosition %>;
	var selSeq=<%=selSeq %>;
	var sc2pageHref="";
	if(sPosition==2){
		sc2pageHref="sc2pageHref2";
	}else if(sPosition==4){
		sc2pageHref="sc2pageHref4";
	}else if(sPosition==9){
		sc2pageHref="sc2pageHref9";
	}else{
		sc2pageHref="sc2pageHref";
	}

	parent.sc2pageHref.value="/myLab/?lab=2&labMenu=11&selSeq="+selSeq;
	parent.mypop_Sc.view("delScDone",function(){});
//	top.location.reload(true);
//]]>
</script>
<%
	Else ' mode<>"del"
		If sPosition<>9 Then ' 사진자료실 아니면...------------------------------------------------
			sql="SELECT seq from "&src_Tbl&" WHERE seq IN ("& scIdxs &") AND isDelete<>'Y'"&_
				" EXCEPT"&_
				" SELECT idx_contents FROM "&tar_tbl&" WHERE userid='"& UserID &"' AND idx_contents IN ("& scIdxs &") AND is_delete<>'Y'"
			Response.write "sql : "&sql&"<br />" 
		Else
			src_Tbl="TP_CMS_MEDIA_MAIN"
			tar_tbl="TP_myScrap"

			sql="SELECT tp_seq from "& src_Tbl &" WHERE tp_seq IN ("& scIdxs &") AND isDisplay='y'"&_
				" EXCEPT"&_
				" SELECT idx_unit FROM "& tar_tbl &" WHERE userid='"& UserID &"' AND idx_unit IN ("& scIdxs &") AND is_delete<>'Y' AND sPosition = " & sPosition
			Response.write "sql : "&sql&"<br />" 
		End If
		arrRows = get_oRs( sql )

		If IsArray( arrRows ) Then
			For ii=LBound( arrRows, 2 ) To UBound( arrRows, 2 )
				If (ii>0) Then notExistIdxs = notExistIdxs &","
				notExistIdxs = notExistIdxs & arrRows( 0, ii )
			Next
		End If
		If sPosition = 3 Then ' 문제은행...
			sql = "SELECT idx_paper FROM TP_myItemBankPaper WHERE idx_paper = 0 AND UserID = '" & UserID & "'"
			Set oRS=g_oDB.Execute(sql)
			If (oRS.EOF Or oRS.BOF) Then
				sql = "INSERT INTO TP_myItemBankPaper (UserID) VALUES ('" & UserID & "')"
				response.write sql 
				g_oDB.Execute(sql)
			End If
			oRS.Close()
		End If
		
		If notExistIdxs<>"" Then
			
'			Call g_oDB.BeginTrans()
			If sPosition<>9 Then ' 사진자료실 아니면...------------------------------------------------
				sql = "INSERT INTO "&tar_tbl&" (UserID, idx_contents, is_delete)"&_
					  " SELECT '"& UserID &"', seq, 'n' FROM "&src_Tbl&""&_
					  " WHERE seq IN ("& notExistIdxs &")"
					  Response.write "sql : "&sql&"<br />" 
				Call g_oDB.Execute(sql)
				If Err.Number <>0 then
'					Call g_oDB.RollbackTrans()
					Call util_log("Error", Err.Description)
					Call util_alert("변경에러","")
				end If

				If src_Tbl  = "TP_unitContents" Then	'단원별 문제는 저장하지 않는다.
					sql = "INSERT INTO TP_unitContents (DBook_seq, idx_TP, idx_icon, UserID, title, flag_LF, link, files, file_type, thumb, scrapCnt, icon_filename, descript, content_type, SE_type, subSE_type, videoSource, videoPlaytime, idx_AddData, UserGrade)"&_
						  " SELECT DBook_seq, idx_TP, idx_icon, '"& UserID &"', title, flag_LF, link, files, file_type, thumb, scrapCnt, icon_filename, descript, '"& content_type &"', SE_type, subSE_type, videoSource, videoPlaytime, idx_AddData, "& g_MEM.grade &" FROM TP_unitContents"&_
						  " WHERE idx IN ("& notExistIdxs &")"
					''Call g_oDB.Execute(sql)
					If Err.Number <>0 then
'						Call g_oDB.RollbackTrans()
						Call util_log("Error", Err.Description)
						Call util_alert("변경에러","")
					end If
				End If
				
				sql = "UPDATE "&src_Tbl&" SET scrapCnt=scrapCnt+1 WHERE seq IN ("& notExistIdxs &")"
				Response.write "sql : "&sql&"<br />" 
				Call g_oDB.Execute(sql)
				If Err.Number <>0 then
'					Call g_oDB.RollbackTrans()
					Call util_log("Error", Err.Description)
					Call util_alert("변경에러","")
				end If
			ElseIf sPosition=9 Then ' 사진자료실 이면...------------------------------------------------
				sql = "INSERT INTO "& tar_tbl &" (UserID, idx_unit, sPosition)"&_
					  " SELECT '"& UserID &"', tp_seq, "& sPosition &" FROM "& src_Tbl &""&_
					  " WHERE tp_seq IN ("& notExistIdxs &")"
'				Response.write sql
				Call g_oDB.Execute(sql)
				If Err.Number <>0 then
'					Call g_oDB.RollbackTrans()
					Call util_log("Error", Err.Description)
					Call util_alert("변경에러","")
				end If
			End If

'			Call g_oDB.CommitTrans()

%>
<script type="text/javascript">
//<![CDATA[
//if (confirm("<%=compMsg%>")){
//	top.location.href="/myLab/?labMenu=<%=toMyLab %>&scFromPaper=<%=sPosition %>";
//}
//top.popScrap();
//]]>
</script>
<%
		Else ' If notExistIdxs="" Then
%>
<script type="text/javascript">
//<![CDATA[
//alert("<%=dupMsg%>");
//parent.mypop_Sc.view("addScExist",function(){});
//]]>
</script>
<%
		End If ' If notExistIdxs
%>
<script type="text/javascript">
//<![CDATA[

<% If BrowserType="msie" Or BrowserType="msie11" Then %>
	alert("스크랩이 완료되었습니다.")
<% Else %>
	var sPosition=<%=sPosition %>;
	var addScDone="";
	parent.sc2pageText.innerText="<%=compMsg %>";
	parent.sc2pageHref.value="/myLab/?lab=<%=lab %>&labMenu=<%=toMyLab %>&scFromPaper=<%=sPosition %>";
	if(sPosition==2){
		addScDone="addScDone2";
	}else if(sPosition==4){
		addScDone="addScDone4";
	}else if(sPosition==9){
		addScDone="addScDone9";
	}else{
		addScDone="addScDone";
	}

	parent.mypop_Sc.view(addScDone,function(){});
<% End If %>
//]]>
</script>
<%
	End If ' mode

End If
%>
<!--#include virtual='/inc/end.inc' -->