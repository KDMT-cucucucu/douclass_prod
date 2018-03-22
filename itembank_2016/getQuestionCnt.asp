<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<object id="g_oExamBank" runat="server" progid="ADODB.Connection"></object>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="itembank"
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include file="inc_vars.asp"-->
<%
Dim sql, oRS, wquery, msg, jql:jql=""
Dim sbj, itbId
Dim sitecode:sitecode=qsitecode ' config.inc
Dim classtype, grade, term, subject, curriculum, author, units, servicetarget
Dim unit1, unit1name, unit2, unit2name, unit3, unit3name
Dim old_unit1, old_unit1name, old_unit2, old_unit2name, old_unit3, old_unit3name
Dim cnt, ii
Dim unitcode, unitcode1, unitcode2, unitcode3
Dim cntDiff1, cntDiff2, cntDiff3, isAll
Dim tmp, arrCnt1
Dim dql
Dim cntH1, cntM1, cntL1, isChap

classtype=util_nte(request("classtype"), "EL", "string") ' char(2) 학교급 - EL:초등, MI:중등, HI:고등
grade=util_nte(request("grade"), "0", "string") ' char(1) 학년 - 0:무관, 1~6
term=util_nte(request("term"), "0", "string") ' char(1) 학기 - 0:무관, 1,2학기, 3:여름방학, 4:겨울방학
subject=util_nte(request("subject"), "", "string") ' char(2) 과목 - KO:국어, EN:영어, MA:수학, SC:과학, SO:사회, HI:국사, ET:도덕
curriculum=util_nte(request("curriculum"), "09", "string") ' char(2) 교육과정
author=util_nte(request("author"), "TOT", "string") ' varchar(20) 저자
'unit1=util_nte(request("unit1"), "", "string") ' char(2) 대단원
'unit2=util_nte(request("unit2"), "", "string") ' char(2) 중단원
'unit3=util_nte(request("unit3"), "", "string") ' char(2) 소단원
units=util_nte(request("units"), "", "string") ' 대단원 + 중단원 + 소단원

servicetarget=util_nte(request("servicetarget"), "", "string") ' 문항출처 T:교사용, R:참고서
isAll=util_nte(request("isAll"), "y", "string") ' 기출제문항 포함여부 y/n

isChap=util_nte(request("isChap"), "y", "string") ' 20170303 중등영어... ----> "영역별 출처" 추가...
If isChap<>"y" And isChap<>"n" Then
	isChap="y" ' 단원별
End If 

'Response.write "classtype : "&classtype&"<br />"
'Response.write "grade : "&grade&"<br />"
'Response.write "term : "&term&"<br />"
'Response.write "subject : "&subject&"<br />"
'Response.write "author : "&author&"<br />"
'Response.write "units : "&units&"<br />"
'Response.write "servicetarget : "&servicetarget&"<br />"
'Response.write "isAll : "&isAll&"<br />"
'Response.write "isChap : "&isChap&"<br />"

units=Replace(units, "all", "")
tmp=Split(units, ",")
For ii=0 To UBound(tmp)
	If wquery<>"" And Trim(tmp(ii))<>"" Then
		wquery=wquery &" OR "
	End If 
	If Trim(tmp(ii))<>"" Then
		If isChap="y" Then 
			wquery=wquery & "r.unitcode LIKE '"& unitcode & Trim(tmp(ii)) &"%'"
		Else ' "n"
			wquery=wquery & "q.fieldcode LIKE '"& unitcode & Trim(tmp(ii)) &"%'"
		End If 
	End If 
Next 
Erase tmp
wquery=" AND ("& wquery &")"

If classtype="EL" And subject="MA" And curriculum="15" Then ' 20170216 초등 수학 15개정...
	If grade="1" And term="1" Then
		wquery=wquery &" AND q.productinfo_id IN ("& prdEL11MA15 &")"
	ElseIf grade="2" And term="1" Then
		wquery=wquery &" AND q.productinfo_id IN ("& prdEL21MA15 &")"
	End If 
	wquery=wquery &" AND q.productinfo_id NOT IN ("& except_prdELMA15 &")"
End If 
If classtype="MI" Or (classtype="HI" And subject="MA") Then ' 중등 or 고등수학(170828추가). 문항출처... 교사용/참고서
	If servicetarget="T" Then
		servicetarget="servicetarget='TEACHER'"
	ElseIf servicetarget="R" Then
		servicetarget="servicetarget='COMMON'"
	ElseIf servicetarget="TR" Then
		servicetarget="servicetarget='TEACHER' OR servicetarget='COMMON'"
	Else 
		servicetarget="servicetarget<>'TEACHER' AND servicetarget<>'COMMON'"
	End If 
	' 20180322  AND curriculum='"& curriculum &"' 제거...
	wquery=wquery &" AND q.productinfo_id IN ("&_
		"SELECT id FROM ProductInfo"&_
		" WHERE classtype='"& classtype &"' AND grade='"& grade &"' AND term='"& term &"' AND `subject`='"& subject &"' AND ("& servicetarget &"))"
End If 

	If isAll<>"y" Then ' 기존 문항 제외... g_MEM.uno
		jql=" AND q.id NOT IN ("&_
			"SELECT DISTINCT l.questionpool_id"&_
			" FROM BuildProblem b"&_
			" INNER JOIN BuildProblemList l ON b.member_id=l.member_id AND b.id=l.buildproblem_id AND b.sitecode=l.sitecode"&_
			" WHERE b.member_id="& g_MEM.uno &" AND b.fgview='Y'"&_
			" AND b.`subject`=(SELECT name FROM CodeInfo WHERE `type`='SUBJECT' AND code='"& subject &"' LIMIT 1)"&_
			" AND b.sitecode='"& sitecode &"'"&_
			" AND b.classtype='"& classtype &"')"
'		Response.write "jql : "& jql &"<br />"
	End If  

dql=" FROM QuestionPoolUnitInfoRelation r"&_
	" INNER JOIN QuestionPool q ON r.questionpool_id=q.id"&_
	" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y'"&_
	wquery
If jql<>"" Then	
	dql=dql & jql
End If

' --------------------------------------------------------------------------------------------------------------------------------------
Call g_oExamBank.Open(CFG_MYSQL_DSExamBankMid)
Call g_oExamBank.execute("set names euckr")

cntDiff1=0:cntDiff2=0:cntDiff3=0

If units<>"" Then
	sql="SELECT IFNULL(SUM(cntDiff1), 0) AS cntDiff1, IFNULL(SUM(cntDiff2), 0) AS cntDiff2, IFNULL(SUM(cntDiff3), 0) AS cntDiff3 FROM"&_
		" (SELECT"&_
		"  (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND id=q.id AND difficulty=1) AS cntDiff1"&_
		", (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND id=q.id AND difficulty=2) AS cntDiff2"&_
		", (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND id=q.id AND difficulty=3) AS cntDiff3"&_
		dql &_
		") AS tmp"
	'Response.write "sql : "& sql &"<br />"
	Set oRS=g_oExamBank.execute(sql)
	If Not (oRS.EOF Or oRS.BOF) Then
		cntDiff1=CInt(oRS("cntDiff1"))
		cntDiff2=CInt(oRS("cntDiff2"))
		cntDiff3=CInt(oRS("cntDiff3"))
	End If
	oRS.Close()
End If

Response.write ""& cntDiff1 &", "& cntDiff2 &", "& cntDiff3
%>

<%
'Response.write "sql : "& sql &"<br />"
Call g_oExamBank.Close
' --------------------------------------------------------------------------------------------------------------------------------------
%>
<!--#include virtual='/inc/end.inc' -->