<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<object id="g_oExamBank" runat="server" progid="ADODB.Connection"></object>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="itembank"

' 사용안함...? 삭제예정...?
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include file="inc_func.inc"-->
<%
Dim sql, oRS, wquery, msg, dql, jql:jql=""
Dim sitecode:sitecode=qsitecode ' config.inc
Dim classtype, grade, term, subject, curriculum, author, units, servicetarget
Dim isAll, cntTot, cntH, cntM, cntL, unitcode, ii, jj, tmp
Dim arrCnt0, arrCnt1, limit, cntMax:cntMax=50 ' 최대 문제수
Dim qRatio0, qRatio1, cntH0, cntH1, cntM0, cntM1, cntL0, cntL1 ' 지문無-->변수명0, 지문有-->변수명1
Dim tgtCntH0, tgtCntH1, tgtCntM0, tgtCntM1, tgtCntL0, tgtCntL1 ' 예상(목표) 문항 수...
Dim cntDiff1, cntDiff2, cntDiff3, q_desc_id, q_desc_ids, q_desc_file, arrTmp, arrRnd, strQid, strRnd

Dim htmlstr, chgSpos, chgEpos, chgStr, tmp1, tmp2, tmp3, tmp4, chql, chgDesc_id, chgCnt, chgDiff, arrDiff:arrDiff=Array(0, 0, 0, 0)
Dim arrChgDiff:arrChgDiff=Array(0, 0, 0, 0)
htmlstr=util_nte(Trim(request("htmlstr_fix")), "", "string")
chgSpos=util_nte(request("chgSpos"), -1, "int")
chgEpos=util_nte(request("chgEpos"), 0, "int")
chgStr=util_nte(Trim(request("chgStr")), "", "string")
Response.write htmlstr &Chr(13)&Chr(10)
Response.write chgSpos &Chr(13)&Chr(10)
Response.write chgEpos &Chr(13)&Chr(10)
Response.write chgStr &Chr(13)&Chr(10)
If htmlstr<>"" And chgSpos>-1 And chgEpos>0 Then ' 문항교체
	arrTmp=Split(htmlstr, ",")
	tmp1="":tmp2="":tmp3="":tmp4=""
	For ii=0 To UBound(arrTmp)
		tmp4=Split(arrTmp(ii), "|")

		If ii<chgSpos Then
			If tmp1<>"" Then
				tmp1=tmp1 &","
			End If 
			tmp1=tmp1 & arrTmp(ii)
			If tmp4(0)="q" Then 
				arrDiff(tmp4(3))=arrDiff(tmp4(3))+1
			End If 
		ElseIf ii>chgEpos Then
			If tmp2<>"" Then
				tmp2=tmp2 &","
			End If 
			tmp2=tmp2 & arrTmp(ii)
			If tmp4(0)="q" Then 
				arrDiff(tmp4(3))=arrDiff(tmp4(3))+1
			End If 
		Else
			If tmp4(0)="q" Then 
				arrChgDiff(tmp4(3))=arrChgDiff(tmp4(3))+1
			End If 
		End If 

		If tmp4(0)="q" Then 
			If tmp3<>"" Then
				tmp3=tmp3 &","
			End If 
			tmp3=tmp3 & tmp4(1)
			chgDiff=tmp4(3) ' 대표난이도??
		End If 

		Erase tmp4
	Next 
	Erase arrTmp

	If Left(chgStr, 1)="d" Then 
		tmp4=Split(chgStr, ",") ' tmp4(0):d, tmp4(1):q

		arrRnd=Split(tmp4(0), "|")
		chgDesc_id=arrRnd(1)
		chgCnt=arrRnd(3) ' dCnt..
		Erase arrRnd

		arrRnd=Split(tmp4(1), "|")
		chgDiff=arrRnd(3) ' 대표난이도??
		Erase arrRnd

		Erase tmp4
	Else
		chgDesc_id=0
	End If 

	chql=""
	If tmp3<>"" Then
		chql=" AND q.id NOT IN ("& tmp3 &")"
	End If 
End If 
Response.write "tmp1 : "& tmp1 &Chr(13)&Chr(10)
Response.write "tmp2 : "& tmp2 &Chr(13)&Chr(10)
Response.write "tmp3 : "& tmp3 &Chr(13)&Chr(10)
'Response.write "tmp4 : "& tmp4 &Chr(13)&Chr(10)
Response.write "chql : "& chql &Chr(13)&Chr(10)
Response.write "arrDiff(1) : "& arrDiff(1) &Chr(13)&Chr(10)
Response.write "arrDiff(2) : "& arrDiff(2) &Chr(13)&Chr(10)
Response.write "arrDiff(3) : "& arrDiff(3) &Chr(13)&Chr(10)
Response.write "arrChgDiff(1) : "& arrChgDiff(1) &Chr(13)&Chr(10)
Response.write "arrChgDiff(2) : "& arrChgDiff(2) &Chr(13)&Chr(10)
Response.write "arrChgDiff(3) : "& arrChgDiff(3) &Chr(13)&Chr(10)


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
cntH=Abs(util_nte(request("cntH"), 0, "int")) ' 난이도 상 문항수 ( --> difficulty:1 )
cntM=Abs(util_nte(request("cntM"), 0, "int")) ' 난이도 중 문항수 ( --> difficulty:2 )
cntL=Abs(util_nte(request("cntL"), 0, "int")) ' 난이도 하 문항수 ( --> difficulty:3 )
cntTot=cntH + cntM + cntL ' 총 문항수

If subject<>"" And cntTot>0 And units<>"" Then 
	If cntTot>cntMax Then
		msg="최대 "& cntMax &"문제까지 출제 가능합니다.("& cntTot &")"
		Response.write msg
'		Call util_alert(msg, "")
		Response.End 
	End If 

	' 지문 없는 문항 비율 : 지문 있는 문항 비율
	If subject="KO" Then ' 국어
		qRatio0=30:qRatio1=70
		' 중등(MI) author : JKW(전경원), LSH(이삼형)
	ElseIf subject="MA" Then ' 수학
		qRatio0=80:qRatio1=20
		' 중등(MI) author : KOK(강옥기), WJH(우정호)
	Else
		qRatio0=50:qRatio1=50
		' 중등(MI) 영어(EN) author : KSG(김성곤), LBM(이병민)
	End If 

	unitcode=classtype & grade & term & subject & curriculum & author
'	Response.write "unitcode : "& unitcode &Chr(13)&Chr(10)
'	unitcode="MI10MA09WJH"'030104" "MI10EN09LBM"
'	Response.write "units : "& units &Chr(13)&Chr(10)
	units=Replace(units, "all", "")
	tmp=Split(units, ",")
	For ii=0 To UBound(tmp)
		If wquery<>"" And Trim(tmp(ii))<>"" Then
			wquery=wquery &" OR "
		End If 
		If Trim(tmp(ii))<>"" Then
			wquery=wquery & "r.unitcode LIKE '"& Trim(tmp(ii)) &"%'"
		End If 
	Next 
	Erase tmp
	wquery=" AND ("& wquery &")"& chql

	If classtype="MI" And servicetarget<>"" Then ' 중등. 문항출처... 교사용/참고서
		If servicetarget="T" Then
			servicetarget="servicetarget='TEACHER'"
		ElseIf servicetarget="R" Then
			servicetarget="servicetarget='COMMON'"
		ElseIf servicetarget="TR" Then
			servicetarget="servicetarget='TEACHER' OR servicetarget='COMMON'"
		End If 
		' 20180322  AND curriculum='"& curriculum &"' 제거...
		wquery=wquery &" AND q.productinfo_id IN ("&_
			"SELECT id FROM ProductInfo"&_
			" WHERE classtype='"& classtype &"' AND grade='"& grade &"' AND term='"& term &"' AND `subject`='"& subject &"' AND ("& servicetarget &"))"
	End If 
'	Response.write "wquery : "& wquery &Chr(13)&Chr(10)

	If isAll<>"y" Then ' 기존 문항 제외... g_MEM.uno
		jql=" AND q.id NOT IN ("&_
			"SELECT DISTINCT l.questionpool_id"&_
			" FROM BuildProblem b"&_
			" INNER JOIN BuildProblemList l ON b.member_id=l.member_id AND b.id=l.buildproblem_id AND b.sitecode=l.sitecode"&_
			" WHERE b.member_id="& g_MEM.uno &_
			" AND b.`subject`=(SELECT name FROM CodeInfo WHERE `type`='SUBJECT' AND code='"& subject &"' LIMIT 1)"&_
			" AND b.sitecode='"& sitecode &"'"&_
			" AND b.classtype='"& classtype &"')"
'		Response.write "jql : "& jql &Chr(13)&Chr(10)
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

	Response.write "cntH : "& cntH &", cntM : "& cntM &", cntL : "& cntL &Chr(13)&Chr(10)	

	strQid=""
	If chgDesc_id=0 Then 
		' 지문無
		' q_id | questiontype | difficulty | q_filename | unitcode | a_filename 형식...
		sql="SELECT CONCAT(q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|"& ii &"|',"&_
			" REPLACE(questionfilename, CONCAT(q.id, '\\'), ''), '|', r.unitcode, '|', REPLACE(explainfilename, CONCAT(q.id, '\\'), '')) AS q_id"&_
			dql &" AND q.descriptionpool_id=0 AND q.difficulty="& chgDiff &" ORDER BY RAND() LIMIT 1"
		Response.write "<br />"& sql &Chr(13)&Chr(10)
		Set oRS=g_oExamBank.execute(sql)
		If Not oRS.EOF Then 
			Do While Not (oRS.BOF Or oRS.EOF)
				If strQid<>"" Then
					strQid=strQid &","
				End If 
				strQid=strQid & oRS("q_id")

				oRS.movenext
			Loop 
		End If 
		Call oRS.close
	Else
		' 지문有
		' q_id | questiontype | difficulty | q_filename | unitcode | a_filename 형식...
		sql="SELECT CONCAT(q.id, '|', IF (ASCII(q.questiontype) BETWEEN 49 AND 52, q.questiontype, '0'), '|', q.difficulty,"&_
			" '|', REPLACE(q.questionfilename, CONCAT(q.id, '\\'), ''), '|', r.unitcode,"&_
			" '|', REPLACE(explainfilename, CONCAT(q.id, '\\'), '')) AS q_id, REPLACE(d.descriptionfilename, 'd.id\\', '') AS d_file"&_
			" FROM QuestionPool q INNER JOIN DescriptionPool d ON q.descriptionpool_id=d.id"&_
			" INNER JOIN QuestionPoolUnitInfoRelation r ON q.id=r.questionpool_id"&_
			" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y' AND q.descriptionpool_id>0"& cql &" ORDER BY RAND() LIMIT "& chgCnt
		Response.write "sql : "& sql &Chr(13)&Chr(10)
		Set oRS=g_oExamBank.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			jj=1
			Do While Not (oRS.BOF Or oRS.EOF)
				If strQid<>"" Then
					strQid=strQid &","
				End If 						
				strQid=strQid &"""d"& jj &""":"""& oRS("q_id") &""""
				q_desc_file=Trim(oRS("d_file"))

				jj=jj+1
				oRS.movenext
			Loop 
		End If 
		Call oRS.close
	End If 

Call g_oExamBank.Close
' --------------------------------------------------------------------------------------------------------------------------------------
Else
	If subject="" Then
		msg="과목을 선택 하세요."
	ElseIf cntTot<=0 Then
		msg="문항수를 확인 하세요."
	ElseIf units="" Then 
		msg="단원을 선택 하세요."
	End If 

	Response.write msg
'	Call util_alert(msg, "")
'	Response.End
End If 
%>
<!--#include virtual='/inc/end.inc' -->