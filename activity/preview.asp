<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_preview"
%>
<!--#include virtual='/inc/start.inc' -->
<%
Dim uc_idx: uc_idx = util_nte(Request("uc_idx"), 0, "int")
Dim filemp4

Dim SQL, oRS, title, files, filetype, flag_LF, isIntro:isIntro=util_nte(Trim(request("isIntro")), "", "string")
Dim domainChk, pWidth, pHeight

files=util_nte(request("files"), "", "string")

	domainChk=Instr(files,"http://hdvod.douclass.com")
%>
<%	If domainChk Then %>
	<!--#include virtual = '/zonePlayer/ZWMSTicket.asp' -->
	<%
	'	ZonePlayer Ticket
		Dim szENC         : szENC         = "S"
		Dim szVOD         : szVOD         = files
		Dim szSite        : szSite        = "DONGA"
		Dim szID          : szID          = ""
		Dim szIP          : szIP          = Request.serverVariables("REMOTE_ADDR")
		Dim szPlayer      : szPlayer      = "IPHONE"    ' IPHONE / Android 구분
		
		Dim g_szTicket    : g_szTicket    = RequestTicket(szENC, szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)

		g_szTicket = Replace(g_szTicket,"hdvod.douclass.com", "mvod.douclass.com")

	%>
<%	End If %>
<%
'Response.write "files : "&files&"<br />"
If files<>"" Then
	filetype=Mid(files, InStrRev(files,".")+1)
End If

If filetype<>"" And Not IsNull( filetype ) Then
	filetype=Trim(filetype)
End If
If title="" Then
	title="&nbsp;"
End If
'Call oRS.Close()
If InStr(".hwp.ppt.zip", filetype)>0 Then
	Call util_alert("미리보기를 할 수 없는 파일 입니다.", "")
	Response.End
End If

Dim UserAgent: UserAgent = Request.ServerVariables("HTTP_USER_AGENT")
Dim UserAgentType
'Response.write UserAgent&"<br />"
If InStr(UserAgent, "MSIE") Or InStr(UserAgent, "Trident/7.0") > 0 then
	UserAgentType = "msie"
ELSEIf InStr(UserAgent, "Android") > 0 then
	UserAgentType = "Android"
ELSEIf InStr(UserAgent, "iPhone") > 0 then
	UserAgentType = "iphone"
ELSEIf InStr(UserAgent, "iPad") > 0 then
	UserAgentType = "ipad"
ELSEIf InStr(UserAgent, "Safari") > 0 then
	UserAgentType = "safari"
ELSE 
	UserAgentType = "etc"
END If
'Response.write UserAgentType
'If Not g_oFS.FileExists(files) Then Response.write files

If (uc_idx>=5856 And uc_idx=<5860) And InStr(" Android, iphone, ipad", UserAgentType)>0  Then ' 메인 활용 동영상. 모바일에선 flv 안보여서...
	filetype="mp4"
	files=Replace(files, "flv", filetype)
End If

pWidth=768
pHeight=432
if filetype = "flv" then 
	files = "/dbook/swf/multiplayer.swf?isVideo=true" &_
			"&viewControl=true" &_
			"&closebtn=false" &_
			"&width="& pWidth &"px" &_
			"&height="& pHeight &"px" &_
			"&autoplay=true" &_
			"&initime=1" &_
			"&url="&files&"" &_
			"&isEmbed=false" 
End if
%>
<script language="javascript" runat="server">
    function decodeUTF8(str){
        return encodeURIComponent(str);
    }
    function encodeUTF8(str){
        return encodeURIComponent(str);
    }
</script>
<% If isIntro<>"Y" Then %>
<div style="width:<%=pWidth %>px;height:<%=pHeight %>px;text-align:center;border:0;border-style:none;margin:0 auto;">
<% End If %>
	<% if filetype = "swf" or filetype = "flv" then %>
		<% if UserAgentType = "msie" then %>
			<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" 
				codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" 
				width="<%=pWidth %>px" height="<%=pHeight %>px" id="link_player_movie" name="link_player_movie" align="middle">
			<param name="allowScriptAccess" value="sameDomain" />
			<param name="allowFullScreen" value="true" />
			<param name="movie" value="<%=files%>" />
			<param name="quality" value="high" />
			<param name="wmode" value="transparent" />
			</object>
		<% else %>
			<embed src="<%=files%>" quality="high" width="<%=pWidth %>px" height="<%=pHeight %>px"
			id="link_player_movie" name="link_player_movie" align="middle" 
			allowScriptAccess="sameDomain" allowFullScreen="true" wmode="transparent" 
			type="application/x-shockwave-flash" 
			pluginspage="http://www.macromedia.com/go/getflashplayer" />
		<% end if %>
	<%elseif filetype = "wmv" Or filetype="mp4" Or filetype="asf" Or filetype="avi" then%>
		<% If domainChk And g_szTicket<>"" Then %>
				<% if UserAgentType = "msie" Then
						Dim ieVerLast:ieVerLast=False
						If InStr(UserAgent, "rv:11.0")>0 Then
							ieVerLast=True 
						Else 
							UserAgent=Split(UserAgent, "MSIE ")
							Dim uaVer:uaVer=Split(UserAgent(1), ";")
							If CInt(uaVer(0))>9 Then 
								ieVerLast=True
							End If 
						End If 

					If filetype="mp4" Then 
						If ieVerLast Then 
%>
	<video id="videoId" width="<%=pWidth %>px" height="<%=pHeight %>px" style="display: block;" controls autoplay controlsList="nodownload">
		<source src="<%=g_szTicket %>" type="video/mp4">
	</video>
<%						Else %>
					<embed id="link_player_movie" name="link_player_movie" type="application/x-mplayer2" style="text-align:center;"
						src="<%=g_szTicket%>" <%' If isIntro="Y" Then %>width="<%=pWidth %>px" height="<%=pHeight %>px"<%' Else %><%' End If %> 
						enablejavascript="1" autostart="1" autosize="1" displaysize="4" autoplay="1"  
						Volume="20" enabletracker="1" enablepositioncontrols="1" showcontrols="1" ShowStatusBar="1" 
						showtracker="1"  showpositioncontrols="1" controller="1" WindowlessVideo="1" wmode="transparent"></embed>
<%						End If %>
<%					Else %>
<%					End If %>
				<% Else ' <>"msie" %>
<% If isIntro="Y" Then %>
	<video id="videoId" width="<%=pWidth %>px" height="<%=pHeight %>px" style="display: block;" controls autoplay controlsList="nodownload">
		<source src="<%=g_szTicket %>" type="video/mp4">
	</video>
<% Else %>
					<video width="<%=pWidth %>px" height="<%=pHeight %>px" controls autoplay controlsList="nodownload">
					  <source src="<%=g_szTicket%>" type="video/mp4">
					</video>
<% End If %>
				<% End If %>
		<% Else %>
			<% If filetype="mp4" Then 
				If Left(files, 1)="/" Then 
					filemp4 = "http://"&Request.ServerVariables("SERVER_NAME")&files
					filemp4 = encodeUTF8(filemp4)
				Else
					filemp4=files
				End If 
			%>
				  <!--object type="application/x-shockwave-flash" data="/js/flashfox.swf" width="640px" height="360px" style="text-align:center;">
					<param name="movie" value="/js/flashfox.swf" />
					<param name="allowFullScreen" value="true" />
					<param name="autoplay" value="true">
					<param name="flashVars" value="autoplay=true&amp;controls=true&amp;src=<%=filemp4%>" />
				  </object--> 
<% If isIntro="Y" Then %>
				<video width="<%=pWidth %>px" height="<%=pHeight %>px" controls autoplay controlsList="nodownload">
					<source src="<%=filemp4 %>" type="video/mp4">
				</video>
<% Else %>
				<video width="<%=pWidth %>px" height="<%=pHeight %>px" controls autoplay controlsList="nodownload">
					<source src="<%=filemp4 %>" type="video/mp4">
				</video>
<% End If %>
			<% Else %>
				<embed id="link_player_movie" name="link_player_movie" type="application/x-mplayer2" style="text-align:center;"
					src="<%=files%>" width="<%=pWidth %>px" height="<%=pHeight %>px" 
					enablejavascript="1" autostart="1" autosize="1" displaysize="4" autoplay="1"  
					Volume="20" enabletracker="1" enablepositioncontrols="1" showcontrols="1" ShowStatusBar="1" 
					showtracker="1"  showpositioncontrols="1" controller="1" WindowlessVideo="1" wmode="transparent"></embed>
			<% End If %>
		<% End If %>
	<% End if %>
<% If isIntro<>"Y" Then %>
</div>
<% End If %>
<!--#include virtual='/inc/end.inc' -->