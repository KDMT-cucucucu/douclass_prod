<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=0
g_pageDiv="activity_DetailActivity"
%>
<!--#include virtual='/inc/start.inc' -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<%
Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim SQL, oRS, ii
Dim depth1, depth2, depth3
Dim cate_seq
Dim selSeq, content_seq, getup_seq, geteq, getsubseq, getsubeq, typeSeq
'Response.write "seq : "&seq&"<br />"
selSeq=0
content_seq=0
getup_seq=0
geteq=0
getsubseq=0
typeSeq=0

If seq>0 Then
	SQL="SELECT depth1, depth2, depth3 FROM CP_contents WHERE seq="&seq
	'Response.write "SQL : "&SQL&"<br />"
	Set oRS=g_oDB.Execute(SQL)
		If Not (oRS.BOF Or oRS.EOF) Then
			depth1=oRS("depth1")
			depth2=oRS("depth2")
			depth3=oRS("depth3")

			'Response.write "depth1 : "&depth1&"<br />"
			'Response.write "depth2 : "&depth2&"<br />"
			'Response.write "depth3 : "&depth3&"<br />"

			selSeq=depth1
			content_seq=seq
			getup_seq=depth2
			getsubseq=depth3
			If depth3=0 Then
				typeSeq=2
				getsubseq=depth2
			Else
				typeSeq=3
			End If
		End If
	Call oRS.Close()
	

	SQL="SELECT seq FROM CP_category WHERE isDisplay=1 AND up_seq="&depth1&" ORDER BY orderNo"
	ii=0
	Set oRS=g_oDB.execute(sql)
		Do While Not (oRS.BOF Or oRS.EOF)
			If depth2=oRS("seq") Then
				geteq=ii
			End If
		ii=ii+1
		oRS.movenext
	Loop
	Call oRS.close()

	'Response.write "geteq : "&geteq&"<br />"

	SQL="SELECT seq FROM CP_category WHERE isDisplay=1 AND up_seq="&depth2&" ORDER BY orderNo"
	ii=0
	Set oRS=g_oDB.execute(sql)
		Do While Not (oRS.BOF Or oRS.EOF)
			If depth3=oRS("seq") Then
				getsubeq=ii
			End If
		ii=ii+1
		oRS.movenext
	Loop
	Call oRS.close()


	'Response.write "content_seq : "&content_seq&"<br />"
	'Response.write "getup_seq : "&getup_seq&"<br />"
	'Response.write "geteq : "&geteq&"<br />"
	'Response.write "getsubseq : "&getsubseq&"<br />"
	'Response.write "getsubeq : "&getsubeq&"<br />"
	'Response.write "typeSeq : "&typeSeq&"<br />"
	Set oRS = Nothing

%>
<script>
	location.href="/activity/activity_detail.asp?selSeq=<%=selSeq %>&content_seq=<%=content_seq %>&getup_seq=<%=getup_seq %>&geteq=<%=geteq %>&seq=<%=getsubseq %>&getsubeq=<%=getsubeq %>&typeSeq=<%=typeSeq %>"
	//document.write("?selSeq=<%=selSeq %>&content_seq=<%=content_seq %>&getup_seq=<%=getup_seq %>&geteq=<%=geteq %>&seq=<%=getsubseq %>&getsubeq=<%=getsubeq %>&typeSeq=<%=typeSeq %>");
</script>
<%
Else
%>
<script>
	alert("올바른 접근이 아닙니다.");
	history.back();
</script>
<%
End If
%>
<!--#include virtual='/inc/end.inc' -->