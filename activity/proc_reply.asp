<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=0
g_pageDiv="activity_proc_reply"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual="/customer/inc_renew_web_admin.asp"-->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

<%
Dim sql, oRS, cnt
Dim rp_seq, content_seq, grp_num, reply, mode, isSecret, secretUserId
Dim replyUrl, sendMailBody

rp_seq=util_nte(request("rp_seq"), 0, "int")
content_seq=util_nte(request("content_seq"), 0, "int")
grp_num=util_nte(request("grp_num"), 0, "int")
reply=util_nte(request("reply"), "", "string")
If reply<>"" Then reply=Replace(reply, "'", "''")
mode=util_nte(request("mode"), "add", "string")

replyUrl = "http://" & request.servervariables("HTTP_HOST")  & "/activity/getDetailActivity.asp?seq=" & content_seq

If content_seq>0 Then
	If mode="add" Then
		isSecret=util_nte(request("isSecret"), "n", "string") ' 비밀댓글 여부...
		isSecret=Replace(isSecret, "'", "''")
		secretUserId="''"
		If isSecret="Y" Then secretUserId="SELECT UserId FROM CP_reply WHERE content_seq="& content_seq &" AND grp_num="& grp_num &" AND grp_ord=0"

		If grp_num=0 Then ' 1depth 새글 등록...

			sql="INSERT INTO CP_reply (content_seq, grp_num, UserId, reply, isSecret)"&_
				" SELECT "& content_seq &", ISNULL(MAX(grp_num), 0)+1, '"& g_Mem.uid &"', '"& reply &"', '"& isSecret &"' FROM CP_reply WHERE content_seq="& content_seq
			'Response.write sql
			Call g_oDB.execute(sql)

			If isAdmin=False Then
				sendMailBody = "URL : " & replyUrl & "<br /><br />등록자 : " & g_Mem.uid & "<br /><br />내용 : " & reply
				Call util_sendMail(replyAdmMailFrom, replyAdmMailTo, "[두클래스]새 댓글이 등록되었습니다.", sendMailBody)
			End If	

		Else ' 2depth...
			sql="INSERT INTO CP_reply (content_seq, grp_num, grp_ord, UserId, reply, isSecret, secretUserId)"&_
				" SELECT "& content_seq &", "& grp_num &", ISNULL(MAX(grp_ord), 0)+1, '"& g_Mem.uid &"', '"& reply &"', '"& isSecret &"', ("& secretUserId &") FROM CP_reply WHERE content_seq="& content_seq &" AND grp_num="& grp_num
'			Response.write sql &"<br>"
			Call g_oDB.execute(sql)

			sql="UPDATE CP_reply SET sub_rpCnt=sub_rpCnt+1 WHERE content_seq="& content_seq &" AND grp_num="& grp_num &" AND grp_ord=0"
'			Response.write sql
			Call g_oDB.execute(sql)

			If isAdmin=False Then
				sendMailBody = "URL : " & replyUrl & "<br /><br />등록자 : " & g_Mem.uid & "<br /><br />내용 : " & reply
				Call util_sendMail(replyAdmMailFrom, replyAdmMailTo, "[두클래스]답글이 등록되었습니다.", sendMailBody)
			End If 
			
		End If		
		
	ElseIf mode="edit" And rp_seq>0 Then
		
		sql="UPDATE CP_reply SET reply='"& reply &"' WHERE rp_seq="& rp_seq &" AND UserId='"& g_Mem.uid &"'"
'		Response.write sql
		Call g_oDB.execute(sql)

	ElseIf mode="del" Then
%>
<%
'		sql="SELECT sub_rpCnt FROM CP_reply WHERE rp_seq="& rp_seq
		sql="SELECT grp_ord FROM CP_reply WHERE rp_seq="& rp_seq
		Set oRS=g_oDB.execute(sql)
			cnt=oRS(0)
		Call oRS.close()

		If cnt=0 Then ' 1depth 삭제면 하위도 삭제...
			sql="UPDATE CP_reply SET is_delete='Y' WHERE grp_num=(SELECT grp_num FROM CP_reply WHERE rp_seq="& rp_seq &") AND grp_ord>0"
		Else
			' 2depth 삭제면 count-1 ...
			sql="UPDATE CP_reply SET sub_rpCnt=sub_rpCnt-1 WHERE content_seq="& content_seq &" AND grp_num="& grp_num &" AND grp_ord=0"&_
				" AND (1=(SELECT COUNT(*) FROM CP_reply WHERE rp_seq="& rp_seq &" AND UserId='"& g_Mem.uid &"' AND grp_ord>0 AND is_delete='n'))"
		End If
'			Response.write sql &"<br>"
			Call g_oDB.execute(sql)

			If isAdmin Then
				sql="UPDATE CP_reply SET is_delete='Y' WHERE rp_seq="& rp_seq
			Else
				sql="UPDATE CP_reply SET is_delete='Y' WHERE rp_seq="& rp_seq &" AND UserId='"& g_Mem.uid &"'"
			End If
''			If g_Mem.grade=100 Then sql="UPDATE CP_reply is_delete='Y' WHERE rp_seq="& rp_seq ' 관리자 삭제...?
'			Response.write sql
			Call g_oDB.execute(sql)
			Call util_alert("삭제 했습니다.", "")
'		Else
'			Call util_alert("댓글이 있으면 삭제 하실수 없습니다.", "")
'		End If
	End If
End If
%>
<script>
parent.getReply(1);
</script>

<!--#include virtual='/inc/end.inc' -->