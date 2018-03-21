<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getLiList"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<%
Dim sql, sql2, oRS, oRS2, ii, ii2, depth3_seq
Dim depth, up_seq, seq, title, isDisplay
Dim sub_up_seq
Dim mode

depth=util_nte(request("depth"), 0, "int")
up_seq=util_nte(request("up_seq"), 0, "int")
mode=util_nte(request("mode"), "", "string") 

If up_seq>0 Or (depth=4 And up_seq=0) Then
	If mode="2depth" Then
		Response.write "["
		
		If depth=>2 Then
			isDisplay=" AND isDisplay=1" 
		End If
		sql="SELECT * FROM CP_category WITH(NOLOCK) WHERE depth="& depth &" AND seq="& up_seq & isDisplay &" ORDER BY orderNo, regDate"
		'Response.write sql
		Set oRS=g_oDB.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
		Do While Not (oRS.BOF Or oRS.EOF)
		If ii>0 Then
			Response.write ", "
		End If
			seq=oRS("seq")
			title=Trim(oRS("title")) 
			sub_up_seq=oRS("up_seq")
			If depth=2 Then
				sql2="SELECT * FROM CP_category WITH(NOLOCK) WHERE depth=3 AND up_seq="& seq & isDisplay &" ORDER BY orderNo, regDate"
				ii2=0
				depth3_seq=""
				Set oRS2=g_oDB.execute(sql2)
				If Not (oRS2.BOF Or oRS2.EOF) Then
				Do While Not (oRS2.BOF Or oRS2.EOF)
					If depth3_seq<>"" Then
						depth3_seq=depth3_seq&","&oRS2("seq")
					Else
						depth3_seq=oRS2("seq")
					End If
					oRS2.movenext
				ii2=ii2+1
				Loop
				Else
					depth3_seq=0
				End If
				Call oRS2.close()
			End If

			Response.write "['"& seq &"', '"& Replace(title, "'", "\'") &"', '"& up_seq &"', '"& depth3_seq &"']"

			oRS.movenext
		ii=ii+1
		Loop
		End If 
		Call oRS.close()

		Response.write "]"
	Else
		Response.write "["
		
		If depth=>2 Then
			isDisplay=" AND isDisplay=1" 
		End If
		sql="SELECT * FROM CP_category WITH(NOLOCK) WHERE depth="& depth &" AND up_seq="& up_seq & isDisplay &_
			" AND title<>N'과목별 추천사이트'"&_
			" ORDER BY orderNo, regDate" ' 161018 과목별 추천사이트 --> 교과자료실로 이동...
		'Response.write sql
		Set oRS=g_oDB.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
		Do While Not (oRS.BOF Or oRS.EOF)
		If ii>0 Then
			Response.write ", "
		End If
			seq=oRS("seq")
			title=Trim(oRS("title")) 
			sub_up_seq=oRS("up_seq")
			If depth=2 Then
				sql2="SELECT * FROM CP_category WITH(NOLOCK) WHERE depth=3 AND up_seq="& seq & isDisplay &" ORDER BY orderNo, regDate"
				ii2=0
				depth3_seq=""
				Set oRS2=g_oDB.execute(sql2)
				If Not (oRS2.BOF Or oRS2.EOF) Then
				Do While Not (oRS2.BOF Or oRS2.EOF)
					If depth3_seq<>"" Then
						depth3_seq=depth3_seq&","&oRS2("seq")
					Else
						depth3_seq=oRS2("seq")
					End If
					oRS2.movenext
				ii2=ii2+1
				Loop
				Else
					depth3_seq=0
				End If
				Call oRS2.close()
			End If

			Response.write "['"& seq &"', '"& Replace(title, "'", "\'") &"', '"& up_seq &"', '"& depth3_seq &"']"

			oRS.movenext
		ii=ii+1
		Loop
		End If 
		Call oRS.close()

		Response.write "]"
	End If
End If 
%>
<!--#include virtual='/inc/end.inc' -->