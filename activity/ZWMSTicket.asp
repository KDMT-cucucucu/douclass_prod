<%
'--------------------------------------------------------------------------------------
' Global 
'--------------------------------------------------------------------------------------
Dim g_szZWMSTicketServer
'g_szZWMSTicketServer  = "http://auth.nowcdn.co.kr/ZWMS/ZWMSTicketPublisher/ZWMSTicketPublisherServer.asp"
g_szZWMSTicketServer  = "http://guard.hscdn.com/ZWMS/ZWMSTicketPublisher/ZWMSTicketPublisherServer.asp"
'g_szZWMSTicketServer  = "http://222.122.150.23/ZWMS/ZWMSTicketPublisher/ZWMSTicketPublisherServer.asp"
'g_szZWMSTicketServer  = "http://iis.shinbnstar.com/ZWMS/ZWMSTicketPublisher/ZWMSTicketPublisherServer.asp"
'g_szZWMSTicketServer  = "http://drm.imgtech.co.kr/ZWMS/ZWMSTicketPublisher/ZWMSTicketPublisherServer.asp"

Dim g_szZWMSTicket
g_szZWMSTicket = ""

'--------------------------------------------------------------------------------------
Dim g_nSockTimeout
g_nSockTimeout = 1000 * 5

'--------------------------------------------------------------------------------------
Function ZWMSGetEmrgencyTicket(szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
    ZWMSGetEmrgencyTicket = szVOD
End Function 

'--------------------------------------------------------------------------------------
Function ZWMSGetTicket()
    ZWMSGetTicket = g_szZWMSTicket
End Function

'--------------------------------------------------------------------------------------
' Error Code 
' 0         :   ����
' 10000001  :   MSXML2.ServerXMLHTTP ��������
' 10000002  :   ��� Timeout
' ��Ÿ      :   HTTP Response Error
'--------------------------------------------------------------------------------------
Function ZWMSRequestTicketXML(szEnc, szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
    '----------------------------------------------------------------------------------
    on Error Resume Next
    
    Dim szQuery
    szQuery = "ENC=" + Server.URLEncode(szEnc) + "&VOD=" + escape(szVOD) + "&SITE=" + Server.URLEncode(szSite) + "&ID=" + Server.URLEncode(szID) + "&IP=" + Server.URLEncode(szIP) + "&NIC=" + Server.URLEncode(szNIC) + "&WMSPUBPOINT=" + Server.URLEncode(szWMSPubPoint) + "&PLAYER=" + Server.URLEncode(szPlayer)
    'szQuery = "ENC=" + Server.URLEncode(szEnc) + "&VOD=" + szVOD + "&SITE=" + Server.URLEncode(szSite) + "&ID=" + Server.URLEncode(szID) + "&IP=" + Server.URLEncode(szIP) + "&NIC=" + Server.URLEncode(szNIC) + "&WMSPUBPOINT=" + Server.URLEncode(szWMSPubPoint) + "&PLAYER=" + Server.URLEncode(szPlayer)
    
    '----------------------------------------------------------------------------------
    g_szZWMSTicket = ""
    
    '----------------------------------------------------------------------------------
    Set XmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP") 
    
    '----------------------------------------------------------------------------------
    ' MSXML2.ServerXMLHTTP ��������
    '----------------------------------------------------------------------------------
    If Err.number = -2147221005 Then 
        ZWMSRequestTicketXML = 10000001
        Set XmlHttp  = Nothing
        Exit Function
    End If
    
    '----------------------------------------------------------------------------------
    XmlHttp.setTimeouts g_nSockTimeout, g_nSockTimeout, g_nSockTimeout, g_nSockTimeout
    XmlHttp.Open "POST", g_szZWMSTicketServer, False
    'XmlHttp.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
    XmlHttp.setRequestHeader "Content-Type", "application/x-www-form-urlencoded; charset=utf-8"
    'XmlHttp.setRequestHeader "encoding","euc-kr"
 
    XmlHttp.Send szQuery

    '----------------------------------------------------------------------------------
    ' ��� Timeout
    '----------------------------------------------------------------------------------
    If Err.number = -2147012894 Then
        ZWMSRequestTicketXML = 10000002
        Set XmlHttp  = Nothing
        Exit Function 
    End If
    
    '----------------------------------------------------------------------------------
    ' HTTP Response Error
    '----------------------------------------------------------------------------------
    If XmlHttp.Status <> 200 Then
        ZWMSRequestTicketXML = XmlHttp.Status
        Set XmlHttp  = Nothing
        Exit Function 
    End If
        
    '-----------------------------------------------------------------------------------
    g_szZWMSTicket = XmlHttp.responseText
       
    '-----------------------------------------------------------------------------------
    ' ����
    '-----------------------------------------------------------------------------------
    ZWMSRequestTicketXML = 0
    
    '-----------------------------------------------------------------------------------
    Set XmlHttp  = Nothing 
End Function

'--------------------------------------------------------------------------------------
' Error Code 
' 0         :   ����
' 10000001  :   ActiveX �������� 
' -1        :   ���� ����
' -2        :   HTTP �޼ҵ�(Post, Get, MULTIPART)�� �ƴ�(����)
' -3        :   �۽� ����
' -4        :   ���� ����
' -5 ~ -9   :   �ļ� ���� 1 ~ 5
' ��Ÿ      :   HTTP Response Error
'--------------------------------------------------------------------------------------
Function ZWMSRequestTicketX(szEnc, szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
	'----------------------------------------------------------------------------------
    on Error Resume Next
    
    Dim szQuery
    szQuery = "ENC=" + Server.URLEncode(szEnc) + "&VOD=" + Server.URLEncode(szVOD) + "&SITE=" + Server.URLEncode(szSite) + "&ID=" + Server.URLEncode(szID) + "&IP=" + Server.URLEncode(szIP) + "&NIC=" + Server.URLEncode(szNIC) + "&WMSPUBPOINT=" + Server.URLEncode(szWMSPubPoint) + "&PLAYER=" + Server.URLEncode(szPlayer)
    
    '----------------------------------------------------------------------------------
    g_szZWMSTicket = ""
    
    '----------------------------------------------------------------------------------
	Dim objZWMSTicket
	Set objZWMSTicket  = Server.CreateObject("ZWMSTicketX.ZWMSTicketAgent.1")
	
	'----------------------------------------------------------------------------------
	' ActiveX �������� 
	'----------------------------------------------------------------------------------
	If Err.number = -2147221005 Then
	    ZWMSRequestTicketX = 10000001
	    Exit Function
	End If
	
	'----------------------------------------------------------------------------------
	g_szZWMSTicket     = objZWMSTicket.Ticket(szQuery, g_szZWMSTicketServer, g_nSockTimeout)
	
	'----------------------------------------------------------------------------------		
	ZWMSRequestTicketX = objZWMSTicket.TicketLastError
	Set objZWMSTicket  = Nothing
End Function

'--------------------------------------------------------------------------------------
Function RequestTicket(szENC, szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
    '----------------------------------------------------------------------------------
    Dim nRequestResult
    nRequestResult = ZWMSRequestTicketXML(szENC, szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
    
    Dim szTicket
    
    If nRequestResult = 0 Then
        szTicket = ZWMSGetTicket()
    Else 
        szTicket = ZWMSGetEmrgencyTicket(szVOD, szSite, szID, szIP, szNIC, szWMSPubPoint, szPlayer)
    End If    
    RequestTicket = szTicket
End Function
%>
