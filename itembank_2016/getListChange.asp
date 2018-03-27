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
<!--#include file="inc_func.inc"-->
<%
Dim sql, oRS, wquery, msg, dql, jql:jql=""
Dim sitecode:sitecode=qsitecode ' config.inc
Dim classtype, grade, term, subject, curriculum, author, units, servicetarget
Dim isAll, cntTot, cntH, cntM, cntL, unitcode, ii, jj, item, tmp, tmp1, tmp2, tmp3, tmp4, isQ
Dim arrCnt0, arrCnt1, limit, cntMax:cntMax=50 ' 최대 문제수
Dim qRatio0, qRatio1, cntH0, cntH1, cntM0, cntM1, cntL0, cntL1 ' 지문無-->변수명0, 지문有-->변수명1
Dim tgtCntH0, tgtCntH1, tgtCntM0, tgtCntM1, tgtCntL0, tgtCntL1 ' 예상(목표) 문항 수...
Dim cntDiff1, cntDiff2, cntDiff3, q_desc_id, q_desc_ids, q_desc_file, arrTmp, arrRnd, strQid, strRnd
Dim htmlstr_chg, qStrChg, isChap

htmlstr_chg=util_nte(Trim(request("htmlstr_chg")), "", "string") ' 선택된 문제
qStrChg=util_nte(Trim(request("qStrChg")), "", "string") ' 교체 문제

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

isChap=util_nte(request("isChap"), "y", "string") ' 20170303 중등영어... ----> "영역별 출처" 추가...
If isChap<>"y" And isChap<>"n" Then
	isChap="y" ' 단원별
End If 

servicetarget=util_nte(request("servicetarget"), "", "string") ' 문항출처 T:교사용, R:참고서
isAll=util_nte(request("isAll"), "y", "string") ' 기출제문항 포함여부 y/n
cntH=Abs(util_nte(request("cntH"), 0, "int")) ' 선택된 난이도 상 문항수 ( --> difficulty:1 )
cntM=Abs(util_nte(request("cntM"), 0, "int")) ' 선택된 난이도 중 문항수 ( --> difficulty:2 )
cntL=Abs(util_nte(request("cntL"), 0, "int")) ' 선택된 난이도 하 문항수 ( --> difficulty:3 )
cntTot=cntH + cntM + cntL ' 선택된 총 문항수

If subject<>"" And cntTot>0 And units<>"" Then 

	wquery=" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y'"

	unitcode=classtype & grade & term & subject & curriculum & author
'	Response.write "unitcode : "& unitcode &"<br />"
'	unitcode="MI10MA09WJH"'030104" "MI10EN09LBM"
'	Response.write "units : "& units &"<br />"
If False Then ' 20170529 동일 단원정보만 필요...
	units=Replace(units, "all", "")
	tmp=Split(units, ",")
	tmp1=""
	For ii=0 To UBound(tmp)
		If tmp1<>"" And Trim(tmp(ii))<>"" Then
			tmp1=tmp1 &" OR "
		End If 
		If Trim(tmp(ii))<>"" Then
			tmp1=tmp1 & "r.unitcode LIKE '"& Trim(tmp(ii)) &"%'"
		End If 
	Next 
	Erase tmp
	wquery=wquery &" AND ("& tmp1 &")"
End If 

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
'	Response.write "wquery : "& wquery &"<br />"

	If isAll<>"y" Then ' 기존 문항 제외... g_MEM.uno
		jql=" AND q.id NOT IN ("&_
			"SELECT DISTINCT l.questionpool_id"&_
			" FROM BuildProblem b"&_
			" INNER JOIN BuildProblemList l ON b.member_id=l.member_id AND b.id=l.buildproblem_id AND b.sitecode=l.sitecode"&_
			" WHERE b.member_id="& g_MEM.uno &_
			" AND b.`subject`=(SELECT name FROM CodeInfo WHERE `type`='SUBJECT' AND code='"& subject &"' LIMIT 1)"&_
			" AND b.sitecode='"& sitecode &"'"&_
			" AND b.classtype='"& classtype &"')"
'		Response.write "jql : "& jql &"<br />"
	End If 

	dql=" FROM QuestionPool q"&_
		" INNER JOIN QuestionPoolUnitInfoRelation r ON q.id=r.questionpool_id"
		
	If jql<>"" Then	
'		dql=dql & jql
		wquery=wquery & jql
	End If 

	tmp="":tmp3="":tmp4=""
	If htmlstr_chg<>"" And qStrChg<>"" Then 		
		tmp1=Split(htmlstr_chg, ",")
		For Each item In tmp1
			tmp2=Split(item, "|")
			If tmp2(0)="q" Then
				If tmp3<>"" Then
					tmp3=tmp3 &","
				End If 
				tmp3=tmp3 & tmp2(1)
			Else 
				If tmp4<>"" Then
					tmp4=tmp4 &","
				End If 
				tmp4=tmp4 & tmp2(1)
			End If 
			Erase tmp2
		Next
		Erase tmp1

		tmp1=Split(qStrChg, "|")
		isQ=True
		If tmp1(0)="q" Then ' 일반문항에서 찾기
			If tmp3<>"" Then
				tmp3=tmp3 &","
			End If 
			tmp3=tmp3 & tmp1(1)
		Else ' "d" 세트문항에서 찾기
			isQ=False 
			If tmp4<>"" Then
				tmp4=tmp4 &","
			End If 
			tmp4=tmp4 & tmp1(1)
		End If 
		If tmp3<>"" Then
			tmp=tmp &" AND q.id NOT IN ("& tmp3 &")"
			If isQ Then 
				tmp=tmp &" AND (q.difficulty="&_
					"(SELECT difficulty FROM QuestionPool WHERE id="& tmp1(1) &_
					" AND fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' LIMIT 1))" ' 난이도 정보
				If isChap="y" Then 
					tmp=tmp &" AND r.unitcode LIKE '"& Left(tmp1(5), 15) &"%'" ' 단원정보
				Else ' 영역정보
					tmp=tmp &" AND (q.fieldcode="&_
						"(SELECT fieldcode FROM QuestionPool WHERE id="& tmp1(1) &_
						" AND fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' LIMIT 1))"
				End If 
			End If 
		End If 
		If tmp4<>"" Then
			tmp=tmp &" AND q.descriptionpool_id NOT IN ("& tmp4 &")"
			strRnd="" ' 변수 재사용...
			If Not isQ Then 
				If isChap="y" Then ' 단원정보
					strRnd=" AND (LEFT(r.unitcode, 15)=(SELECT LEFT(r1.unitcode, 15)"&_
						" FROM QuestionPool q1 INNER JOIN QuestionPoolUnitInfoRelation r1 ON q1.id=r1.questionpool_id"&_
						" WHERE q1.descriptionpool_id="& tmp1(1) &" AND r1.unitcode LIKE '"& unitcode &"%'"&_
						" AND q1.fghwpconfirm='Y' AND q1.fgattributeconfirm='Y' AND q1.fgview='Y' LIMIT 1))"
				Else ' 영역정보
					strRnd=" AND (q.fieldcode="&_
						"(SELECT fieldcode FROM QuestionPool WHERE descriptionpool_id="& tmp1(1) &_
						" AND fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' LIMIT 1))"
				End If 
			End If
		End If 
		Erase tmp1
	End If 
'	Response.write "qStrChg : "& qStrChg &"<br />"
'	Response.write "tmp : "& tmp &"<br />"
'	Response.write "isChap : "& isChap &"<br />"

' --------------------------------------------------------------------------------------------------------------------------------------
Call g_oExamBank.Open(CFG_MYSQL_DSExamBankMid)

'	Response.write "cntH : "& cntH &", cntM : "& cntM &", cntL : "& cntL &"<br />"	
	tgtCntH0=CInt(cntH*qRatio0/100)
	tgtCntM0=CInt(cntM*qRatio0/100)
	tgtCntL0=CInt(cntM*qRatio0/100)
'	Response.write "a - tgtCntH0 : "& tgtCntH0 &", tgtCntM0 : "& tgtCntM0 &", tgtCntL0 : "& tgtCntL0 &"<br />"
'	Response.write "a - tgtCntH1 : "& cntH-tgtCntH0 &", tgtCntM1 : "& cntM-tgtCntM0 &", tgtCntL1 : "& cntM-tgtCntM0 &"<br />"

	strQid="" ' data없음...
	If isQ Then ' 일반문항에서 찾기
		sql="SELECT CONCAT('q|', q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|', q.difficulty, '|', questionfilename,"&_
			"'|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id"&_
			dql & wquery & tmp &_
			" AND q.descriptionpool_id=0 ORDER BY RAND() LIMIT 1"
'		Response.write "sql : "& sql &"<br />"
		Set oRS=g_oExamBank.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then 
			strQid=oRS("q_id")
		End If 
		Call oRS.close
	Else ' 세트 문항 구하기...
		sql="SELECT DISTINCT q.descriptionpool_id"& dql & wquery & tmp & strRnd &" AND q.descriptionpool_id>0 ORDER BY RAND() LIMIT 1"
'		Response.write "sql : "& sql &"<br />"
		Set oRS=g_oExamBank.execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			q_desc_id=oRS(0)
		End If 
		Call oRS.close
	If False Then 
		If q_desc_id=0 Then
			sql="SELECT DISTINCT q.descriptionpool_id"& dql & wquery & tmp &" AND q.descriptionpool_id>0 ORDER BY RAND() LIMIT 1"
'			Response.write "sql-1 : "& sql &"<br />"
			Set oRS=g_oExamBank.execute(sql)
			If Not (oRS.BOF Or oRS.EOF) Then
				q_desc_id=oRS(0)
			End If 
			Call oRS.close
		End If 
	End If 

		If q_desc_id>0 Then 
			sql="SELECT CONCAT(q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|', q.difficulty, '|', questionfilename,"&_
				"'|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id"&_
				", d.descriptionfilename AS d_file"&_
				dql &" INNER JOIN DescriptionPool d ON q.descriptionpool_id=d.id"&_ 
				wquery &" AND q.descriptionpool_id="& q_desc_id
'			Response.write "sql : "& sql &"<br />"
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
				strQid="{""dCnt"":"& jj-1 &",""desc_id"":"& q_desc_id &",""desc_file"":"""& q_desc_file &""","& strQid &"}"
			End If 
			Call oRS.close
		End If 
	End If 	
	Response.write strQid
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