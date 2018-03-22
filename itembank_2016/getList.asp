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
<!--#include file="inc_vars.asp"-->
<%
'Response.Write "<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">"
Dim sql, oRS, wquery, msg, dql, uquery, jql:jql=""
Dim sitecode:sitecode=qsitecode ' config.inc
Dim classtype, grade, term, subject, curriculum, author, units, servicetarget
Dim isAll, cntTot, cntH, cntM, cntL, unitcode, ii, jj, tmp
Dim arrCnt0, arrCnt1, limit, cntMax:cntMax=50 ' 최대 문제수
Dim qRatio0, qRatio1, cntH0, cntH1, cntM0, cntM1, cntL0, cntL1 ' 지문無-->변수명0, 지문有-->변수명1
Dim tgtCntH0, tgtCntH1, tgtCntM0, tgtCntM1, tgtCntL0, tgtCntL1 ' 예상(목표) 문항 수...
Dim cntDiff1, cntDiff2, cntDiff3, q_desc_id, q_desc_ids, q_desc_file, arrTmp, arrRnd, strQid, strRnd
Dim testStr, field1s, questiontypes, isChap, useField:useField=False 

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
isAll=util_nte(request("isAll"), "n", "string") ' 기출제문항 포함여부 y/n
cntH=Abs(util_nte(request("cntH"), 0, "int")) ' 난이도 상 문항수 ( --> difficulty:1 )
cntM=Abs(util_nte(request("cntM"), 0, "int")) ' 난이도 중 문항수 ( --> difficulty:2 )
cntL=Abs(util_nte(request("cntL"), 0, "int")) ' 난이도 하 문항수 ( --> difficulty:3 )
cntTot=cntH + cntM + cntL ' 총 문항수

isChap=util_nte(request("isChap"), "y", "string") ' 20170303 중등영어... ----> "영역별 출처" 추가...
If isChap<>"y" And isChap<>"n" Then
	isChap="y" ' 단원별
End If 

questiontypes=util_nte(Trim(request("questiontypes")), "", "string") ' '1',~,'4'
If classtype="EL" And (subject="KO" Or subject="MA") Then ' 초등 국/수가 아니면 문항유형 사용...
	If curriculum="09" And subject="KO" And term<>"2" Then 
		If grade<>"3" And grade<>"4" Then ' 3-1, 4-1 사용...
			questiontypes=""
		End If 
	End If 
	If curriculum="09" And subject="MA" Then 
		questiontypes=""
	End If
End If 
'If classtype="MI" Then
'	questiontypes=util_nte(Trim(request("questiontypes")), "", "string") ' '1',~,'4'
'Else
'	questiontypes=""
'End If 

field1s=""
If classtype="MI" And subject="EN" Then ' 중등 영어 --> 내용영역 사용...
	If isChap<>"n" Then ' 20170303 "영역별 출처" 아니면...
		field1s=util_nte(Trim(request("field1s")), "", "string") ' '01',~,'06'
	Else 
		useField=True 
	End If 
End If 

'testStr="classtype="& classtype &"&grade="& grade &"&term="& term &"&subject="& subject &"&curriculum="& curriculum &"&author="& author &"&units="& units &"&servicetarget="& servicetarget &"&isAll="& isAll &"&cntH="& cntH &"&cntM="& cntM &"&cntL="& cntL &"&questiontypes="& questiontypes &"&field1s="& field1s

If subject<>"" And cntTot>0 And units<>"" Then 
	If cntTot>cntMax Then
		msg="최대 "& cntMax &"문항 출제 가능합니다.("& cntTot &")"
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

	If classtype="EL" And subject<>"MA" And subject<>"SO" And subject<>"SC" Then ' 초등 수학/사회/과학 이외의 과목 난이도 조정 전 한시적 조건...
		If subject<>"KO" And questiontypes<>"" Then ' 20170223 국어 난이도 추가...
			cntM=cntTot
			cntH=0
			cntL=0
		End If 
	End If 

'http://dndev.douclass.com/itembank_2016/getList.asp?classtype=EL&grade=1&term=1&subject=KO&curriculum=09&author=TOT&units=EL11KO09TOT05all&servicetarget=TR&isAll=y&cntH=10&cntM=25&cntL=15 
'http://dndev.douclass.com/itembank_2016/getList.asp?classtype=MI&grade=1&term=0&subject=MA&curriculum=09&author=KOK&units=MI10MA09KOK03all&servicetarget=TR&isAll=n&cntH=5&cntM=13&cntL=7
'http://dndev.douclass.com/itembank_2016/getList.asp?classtype=EL&grade=3&term=1&subject=MA&curriculum=09&author=TOT&units=EL31MA09TOT01all, EL31MA09TOT02all, EL31MA09TOT03all, EL31MA09TOT04all, EL31MA09TOT05all, EL31MA09TOT06all&servicetarget=TR&isAll=y&cntH=4&cntM=10&cntL=6
	If useField Then ' 20170303 중등영어... ----> "영역별 출처" 추가...
		unitcode=classtype & subject
	Else
		unitcode=classtype & grade & term & subject & curriculum & author
	End If 
'	Response.write "unitcode : "& unitcode &"<br />"
'	unitcode="MI10MA09WJH"'030104" "MI10EN09LBM"
'	Response.write "units : "& units &"<br />"
	units=Replace(units, "all", "")
	tmp=Split(units, ",")
	wquery="":uquery=""
	For ii=0 To UBound(tmp)
		If uquery<>"" And Trim(tmp(ii))<>"" Then
			uquery=uquery &" OR "
		End If 
		If Trim(tmp(ii))<>"" Then
			If isChap="y" Then 
				uquery=uquery & "r.unitcode LIKE '"& Trim(tmp(ii)) &"%'"
			Else 
				uquery=uquery & "q.fieldcode LIKE '"& Trim(tmp(ii)) &"%'"
			End If 
		End If 
	Next 
	Erase tmp
	wquery=" AND ("& uquery &")"

	If classtype="EL" And subject="MA" And curriculum="15" Then ' 20170216 초등 수학 15개정... 
		If grade="1" And term="1" Then
			wquery=wquery &" AND q.productinfo_id IN ("& prdEL11MA15 &")"
			questiontypes=util_nte(Trim(request("questiontypes")), "", "string") ' '1',~,'4' --> 문항유형 사용
		ElseIf grade="2" And term="1" Then
			wquery=wquery &" AND q.productinfo_id IN ("& prdEL21MA15 &")"
			questiontypes=util_nte(Trim(request("questiontypes")), "", "string") ' '1',~,'4' --> 문항유형 사용
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
	If questiontypes<>"" Then
'		Response.write questiontypes &"<br />"
		wquery=wquery &" AND q.questiontype IN ("& questiontypes &")"
	End If
	If field1s<>"" Then ' 중등 영어...
		tmp=Split(field1s, ",")
		If isArray(tmp) Then
			field1s=""
			For ii=0 To UBound(tmp)
				If field1s<>"" Then
					field1s=field1s &" OR "
				End If 
				field1s=field1s &"q.fieldcode LIKE '"& classtype & subject & Replace(tmp(ii), "'", "") &"%'"
			Next 

			field1s=" AND ("& field1s &")"

			Erase tmp
		End If
'		Response.write field1s &"<br />"
		wquery=wquery & field1s
	End If
'	Response.write "wquery : "& wquery &"<br />"

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

'	Response.write "cntH : "& cntH &", cntM : "& cntM &", cntL : "& cntL &"<br />"	
	tgtCntH0=CInt(cntH*qRatio0/100)
	tgtCntM0=CInt(cntM*qRatio0/100)
	tgtCntL0=CInt(cntL*qRatio0/100)
'	Response.write "a - tgtCntH0 : "& tgtCntH0 &", tgtCntM0 : "& tgtCntM0 &", tgtCntL0 : "& tgtCntL0 &"<br />"
'	Response.write "a - tgtCntH1 : "& cntH-tgtCntH0 &", tgtCntM1 : "& cntM-tgtCntM0 &", tgtCntL1 : "& cntL-tgtCntL0 &"<br />"


'	Response.write "<br />지문無<br />"
	sql="SELECT q.difficulty, COUNT(*)"& dql &" AND q.descriptionpool_id=0 GROUP BY q.difficulty ORDER BY q.difficulty"
'	Response.write "sql1 : "& sql &"<br /><br />"
	Set oRS=g_oExamBank.execute(sql)
	If Not oRS.EOF Then 
		arrCnt0=oRS.GetRows()
	End If 
	Call oRS.close

	cntH0=0:cntM0=0:cntL0=0
	If isArray(arrCnt0) Then
		For ii=LBound(arrCnt0, 2) To UBound(arrCnt0, 2)
			tmp=CInt(arrCnt0(1, ii))
			If arrCnt0(0, ii)=1 Then ' 상
				cntH0=tmp
			ElseIf arrCnt0(0, ii)=2 Then ' 중
				cntM0=tmp
			Else ' 하
				cntL0=tmp
			End If 
		Next 
		Erase arrCnt0
	End If 
'	Response.write "b - cntH0 : "& cntH0 &", cntM0 : "& cntM0 &", cntL0 : "& cntL0 &"<br />"
	If tgtCntH0>cntH0 Then ' 지문無 문항 목표수 보다 적으면 지문有 문항 목표수 변경...
		tgtCntH0=cntH0
	End If 
	If tgtCntM0>cntM0 Then
		tgtCntM0=cntM0
	End If 
	If tgtCntL0>cntL0 Then
		tgtCntL0=cntL0
	End If 
	If classtype="EL" Then 
		If cntH0=0 Then ' [상] 문제가 없으면 [중]문제 증가...
			tgtCntM0=tgtCntM0 + tgtCntH0
		End If 
		If cntL0=0 Then ' [하] 문제가 없으면 [중]문제 증가...
			tgtCntM0=tgtCntM0 + tgtCntL0
		End If 
	End If 
	tgtCntH1=cntH-tgtCntH0
	tgtCntM1=cntM-tgtCntM0
	tgtCntL1=cntL-tgtCntL0
'	Response.write "c - tgtCntH0 : "& tgtCntH0 &", tgtCntM0 : "& tgtCntM0 &", tgtCntL0 : "& tgtCntL0 &"<br />"
'	Response.write "c - tgtCntH1 : "& tgtCntH1 &", tgtCntM1 : "& tgtCntM1 &", tgtCntL1 : "& tgtCntL1 &"<br />"

'	Response.write "<br />지문有<br />"
	sql="SELECT q.descriptionpool_id"&_
		", (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND descriptionpool_id=q.descriptionpool_id AND difficulty=1) AS cntDiff1"&_
		", (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND descriptionpool_id=q.descriptionpool_id AND difficulty=2) AS cntDiff2"&_
		", (SELECT COUNT(*) FROM QuestionPool WHERE fghwpconfirm='Y' AND fgattributeconfirm='Y' AND fgview='Y' AND descriptionpool_id=q.descriptionpool_id AND difficulty=3) AS cntDiff3"
'	sql=sql & dql &" AND q.descriptionpool_id>0 GROUP BY q.descriptionpool_id ORDER BY RAND() LIMIT 200"
	sql=sql & dql &" AND q.descriptionpool_id>0 GROUP BY q.descriptionpool_id ORDER BY q.regdatetime DESC LIMIT 0,200" ' 170317 최신문항으로 검색 정렬...
	sql="SELECT * FROM ("& sql &") AS tmp11 ORDER BY RAND() LIMIT 0,200"
'	Response.write "sql2 : "& sql &"<br /><br />"
	Set oRS=g_oExamBank.execute(sql)
	If Not oRS.EOF Then 
		arrCnt1=oRS.GetRows()
	End If 
	Call oRS.close

	cntH1=0:cntM1=0:cntL1=0:q_desc_ids=""
	If isArray(arrCnt1) Then
		For ii=LBound(arrCnt1, 2) To UBound(arrCnt1, 2)
			q_desc_id=arrCnt1(0, ii)
'			Response.write "q_desc_id : "& q_desc_id &"<br />"
			cntDiff1=CInt(arrCnt1(1, ii))
			cntDiff2=CInt(arrCnt1(2, ii))
			cntDiff3=CInt(arrCnt1(3, ii))

			If (tgtCntH1>cntH1 And cntDiff1>0) Or (tgtCntM1>cntM1 And cntDiff2>0) Or (tgtCntL1>cntL1 And cntDiff3>0) Then
				cntH1=cntH1 + cntDiff1
				cntM1=cntM1 + cntDiff2
				cntL1=cntL1 + cntDiff3

				q_desc_ids=q_desc_ids &",-"& q_desc_id ' descriptionpool_id 표시를 위해 (-)를 붙인다...
'				Response.write "<br />q_desc_id : "& q_desc_id &"<br />"
'				Response.write "tgtCntH1 : "& tgtCntH1 &", cntH1 : "& cntH1 &", cntDiff1 : "& cntDiff1 &"<br />"
'				Response.write "tgtCntM1 : "& tgtCntM1 &", cntM1 : "& cntM1 &", cntDiff2 : "& cntDiff2 &"<br />"
'				Response.write "tgtCntL1 : "& tgtCntL1 &", cntL1 : "& cntL1 &", cntDiff3 : "& cntDiff3 &"<br />"
			Else
				Exit For 
			End If 
		Next 
		Erase arrCnt1
	End If 
'	Response.write "q_desc_ids : "& q_desc_ids &"<br /><br />"
'	Response.write "d - tgtCntH0 : "& tgtCntH0 &", tgtCntM0 : "& tgtCntM0 &", tgtCntL0 : "& tgtCntL0 &"<br />"
'	Response.write "d - tgtCntH1 : "& tgtCntH1 &", tgtCntM1 : "& tgtCntM1 &", tgtCntL1 : "& tgtCntL1 &"<br />"
'	Response.write "f - cntH0 : "& cntH0 &", cntM0 : "& cntM0 &", cntL0 : "& cntL0 &"<br />"
'	Response.write "f - cntH1 : "& cntH1 &", cntM1 : "& cntM1 &", cntL1 : "& cntL1 &"<br />"

	If cntH0+cntH1+cntM0+cntM1+cntL0+cntL1=0 Then
'		Response.write sql
		msg="조건에 맞는 문항이 없습니다!"
		Response.write msg
'		Call util_alert(msg, "parent.prevStep();")
		Response.End 
	End If 

	If classtype="EL" Then 
		If cntH1=0 Then ' [상] 문제가 없으면 [중]문제 증가...
			tgtCntM0=tgtCntM0 + tgtCntH1
		End If 
'		Response.write "tgtCntM0 : "& tgtCntM0 &"<br />"
		If cntL1=0 Then ' [하] 문제가 없으면 [중]문제 증가...
			tgtCntM0=tgtCntM0 + tgtCntL1
		End If
'		Response.write "tgtCntM0 : "& tgtCntM0 &"<br />"
	End If 

	' 지문無 목표 문제수 재계산...
	tgtCntH0=getQcnt(cntH, cntH0, cntH1, tgtCntH0, tgtCntH1)
	tgtCntM0=getQcnt(cntM, cntM0, cntM1, tgtCntM0, tgtCntM1)
	tgtCntL0=getQcnt(cntL, cntL0, cntL1, tgtCntL0, tgtCntL1)

	tgtCntH1=cntH-tgtCntH0
	tgtCntM1=cntM-tgtCntM0
	tgtCntL1=cntL-tgtCntL0

'	Response.write "e - tgtCntH0 : "& tgtCntH0 &", tgtCntM0 : "& tgtCntM0 &", tgtCntL0 : "& tgtCntL0 &"<br />"
'	Response.write "e - tgtCntH1 : "& tgtCntH1 &", tgtCntM1 : "& tgtCntM1 &", tgtCntL1 : "& tgtCntL1 &"<br />"

	' 지문無 --> 목표 수
	arrTmp=Array(0, tgtCntH0, tgtCntM0, tgtCntL0):strQid=""
	For ii=1 To 3
		If arrTmp(ii)>0 Then 
			' q_id | questiontype | difficulty | q_filename | unitcode | a_filename 형식...
'			sql="SELECT CONCAT(q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|"& ii &"|', REPLACE(questionfilename, CONCAT(q.id, '\\'), ''), '|', r.unitcode, '|', REPLACE(explainfilename, CONCAT(q.id, '\\'), '')) AS q_id"&_
			sql="SELECT CONCAT(q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|"& ii &"|', questionfilename, '|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id"
'			sql=sql & dql &" AND q.descriptionpool_id=0 AND q.difficulty="& ii &" ORDER BY RAND() LIMIT "& arrTmp(ii)
			sql=sql & dql &" AND q.descriptionpool_id=0 AND q.difficulty="& ii &" ORDER BY q.regdatetime DESC LIMIT 0,200" ' 170317 최신문항으로 검색 정렬...
			sql="SELECT * FROM ("& sql &") AS tmp11 ORDER BY RAND() LIMIT 0,"& arrTmp(ii)
'			Response.write "<br />sql3 : "& sql &"<br /><br />"
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
		End If 
	Next 
	Erase arrTmp
'	Response.write "strQid : "& strQid &"<br />"

	' 지문有 --> 실제 수(q_desc_ids fix됨...)
	If q_desc_ids<>"" Then
		strQid=strQid & q_desc_ids
	End If 
	If Left(strQid, 1)="," Then ' 지문無 0개...
		strQid=Right(strQid, Len(strQid)-1)
	End If 
%>
<script language='jscript' runat='server'>
function getRnd(strRnd){ // q_id와 desc_id를 random하게 섞어줌...
	var arr=strRnd.split(",");
	for (var i=arr.length-1; i>=0; i--){
		var rndIdx=Math.floor(Math.random()*(i+1));
		var itmIdx=arr[rndIdx];

		arr[rndIdx]=arr[i];
		arr[i]=itmIdx;
	}
	var tmpStr="";
	for (i=0; i<arr.length; i++){
		if (i>0) tmpStr+=",";
		tmpStr+=arr[i];
	}
	return tmpStr;
}
</script>
<%
	strRnd=","& getRnd(strQid) &","
'	strRnd=",-632248,-632243,627738|1|2|627738_Q.hwp,-627740,27260|4|1|627260_Q.hwp,627739|1|2|627739_Q.hwp,"
'	Response.write "<br />strRnd : "& strRnd &"<br /><br />"
	arrRnd=Split(strRnd, ",") ' random하게 섞은 결과를 배열로...
'	Response.write "UBound(arrRnd) : "& UBound(arrRnd) &"<br />"
	If isArray(arrRnd) Then 
		cntTot=UBound(arrRnd)
		For ii=1 To cntTot-1 ' because 맨 앞/뒤에 "," 추가...
			arrTmp=Split(arrRnd(ii), "|") ' q_id | questiontype | difficulty | q_filename | unitcode | a_filename 형식...
'			Response.write "arrTmp(0) : "& arrTmp(0) &"<br />"
			If UBound(arrTmp)>-1 Then 
			If arrTmp(0)>0 Then ' 지문無
'				Response.write "qid : "& arrRnd(ii) &"<br />"
'				Response.write Replace(strRnd, ","& arrRnd(ii) &",", ","& ii &":"""& arrRnd(ii) &""",") &"<br />"
				strRnd=Replace(strRnd,_
								","& arrRnd(ii) &",",_
								",""q"& ii &""":"""& arrRnd(ii) &""",")
			Else ' 지문有
				strQid=""
				tmp=Abs(arrTmp(0))
'				sql="SELECT CONCAT(q.id, '|', IF (ASCII(q.questiontype) BETWEEN 49 AND 52, q.questiontype, '0'), '|', q.difficulty,"&_
'					"'|', REPLACE(q.questionfilename, CONCAT(q.id, '\\'), ''), '|', r.unitcode, '|', REPLACE(explainfilename, CONCAT(q.id, '\\'), '')) AS q_id, REPLACE(d.descriptionfilename, '"& tmp &"\\', '') AS d_file"&_
'					" FROM QuestionPool q INNER JOIN DescriptionPool d ON q.descriptionpool_id=d.id"&_
'					" INNER JOIN QuestionPoolUnitInfoRelation r ON q.id=r.questionpool_id AND r.unitcode LIKE '"& unitcode &"%'"&_
'					" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y' AND q.descriptionpool_id="& tmp
				sql="SELECT CONCAT(q.id, '|', IF (ASCII(q.questiontype) BETWEEN 49 AND 52, q.questiontype, '0'), '|', q.difficulty,"&_
					"'|', q.questionfilename, '|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id, d.descriptionfilename AS d_file"&_
					" FROM QuestionPool q INNER JOIN DescriptionPool d ON q.descriptionpool_id=d.id"&_
					" INNER JOIN QuestionPoolUnitInfoRelation r ON q.id=r.questionpool_id"&_
					" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y' AND q.descriptionpool_id="& tmp
				If isChap="y" And uquery<>"" Then 
					sql=sql & " AND ("& uquery &")"
				End If 
'				Response.write "sql4 : "& sql &"<br /><br />"
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

				If strQid="" Then ' 161107 지문파일이 없어서 에러가 발생...
					strQid="""d1"":"""""
				End If 
'				Response.write "strQid : "& strQid &"<br />"

'				strRnd=Replace(strRnd, ","& arrTmp(0) &",", ","& ii &":"& arrTmp(0) &"["& strQid &"]")
				strRnd=Replace(strRnd,_
								","& arrTmp(0) &",",_
								",""q"& ii &""":{""dCnt"":"& jj-1 &",""desc_id"":"& tmp &",""desc_file"":"""& q_desc_file &""","& strQid &"},")
			End If 
			End If 
			Erase arrTmp
		Next 
		Erase arrRnd
	End If 
'	strRnd=Mid(strRnd, 2, Len(strRnd)-2) ' 맨 앞/뒤 "," 제거...
	strRnd="{"&_
			"""qCnt"":"& cntTot-1 &_
			Replace(strRnd, "\", "/") &_
			"""cntH"":"& tgtCntH0+cntH1 &_
			",""cntM"":"& tgtCntM0+cntM1 &_
			",""cntL"":"& tgtCntL0+cntL1 &_
			"}"
'			",""testStr"":"""& testStr &""""&_
'	Response.write "strRnded : "& strRnd &"<br />"
	Response.write strRnd

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