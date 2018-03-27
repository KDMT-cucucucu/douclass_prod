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
Response.Buffer = True
'Response.Write "<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8"">"
Dim sql, oRS, wquery, msg, dql, jql:jql=""
Dim htmlstr, tmp1, tmp2, tmp3, tmp4, item, ii, jj, kk
Dim qid, fileUrlQ, units, fileUrlA
Dim examUrl:examUrl=CFG_examDataUrl ' 문제지 서비스 url
Dim src, srcHtml, isChgBtn, dCnt, did, d_ids1, d_ids2

Dim sitecode:sitecode=qsitecode ' config.inc
Dim classtype, grade, term, subject, curriculum, author, servicetarget
Dim isAll, cntTot, cntH, cntM, cntL, unitcode, tmp, unitStr
Dim pql1, pql2, limitCnt:limitCnt=10 ' pagesize...
Dim field1s, questiontypes, q_id, arrAdded, strQid, q_desc_file
Dim isChap, useField:useField=False 

classtype=util_nte(request("classtype"), "EL", "string") ' char(2) 학교급 - EL:초등, MI:중등, HI:고등
grade=util_nte(request("grade"), "0", "string") ' char(1) 학년 - 0:무관, 1~6
term=util_nte(request("term"), "0", "string") ' char(1) 학기 - 0:무관, 1,2학기, 3:여름방학, 4:겨울방학
subject=util_nte(request("subject"), "", "string") ' char(2) 과목 - KO:국어, EN:영어, MA:수학, SC:과학, SO:사회, HI:국사, ET:도덕
curriculum=util_nte(request("curriculum"), "09", "string") ' char(2) 교육과정
author=util_nte(request("author"), "TOT", "string") ' varchar(20) 저자
units=util_nte(request("units"), "", "string") ' 대단원 + 중단원 + 소단원
servicetarget=util_nte(request("servicetarget"), "", "string") ' 문항출처 T:교사용, R:참고서
isAll=util_nte(request("isAll"), "y", "string") ' 기출제문항 포함여부 y/n
cntH=util_nte(request("cntH"), False, "boolean")
cntM=util_nte(request("cntM"), False, "boolean")
cntL=util_nte(request("cntL"), False, "boolean")

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
		limitCnt=30
	End If 
End If 

	If useField Then ' 20170303 중등영어... ----> "영역별 출처" 추가...
		unitcode=classtype & subject
	Else
		unitcode=classtype & grade & term & subject & curriculum & author
	End If 
	units=Replace(units, "all", "")
'	Response.write "units : "& units &"<br />"
	tmp=Split(units, ",")
	For ii=0 To UBound(tmp)
		If wquery<>"" And Trim(tmp(ii))<>"" Then
			wquery=wquery &" OR "
		End If 
		If Trim(tmp(ii))<>"" Then
			If isChap="y" Then 
				wquery=wquery & "r.unitcode LIKE '"& Trim(tmp(ii)) &"%'"
			Else 
				wquery=wquery & "q.fieldcode LIKE '"& Trim(tmp(ii)) &"%'"
			End If 
		End If 
	Next 
	Erase tmp
	If wquery="" Then
		wquery="1=1"
	End If 
	wquery=" AND ("& wquery &")"

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
	If field1s<>"" Then
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
'		Response.write "jql : "& jql &"<br />"
	End If 

	dql=" FROM QuestionPoolUnitInfoRelation r"&_
		" INNER JOIN QuestionPool q ON r.questionpool_id=q.id"&_
		" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y'"&_
		wquery
	If jql<>"" Then	
		dql=dql & jql
	End If 

	htmlstr=util_nte(Trim(request("htmlstr_pop")), "", "string")
	tmp=""
	tmp1=Split(htmlstr, ",")
	If isArray(tmp1) Then
		jj=0
		For ii=0 To UBound(tmp1)
	'		Response.write tmp1(ii) &Chr(13)&Chr(10)
			tmp2=Split(tmp1(ii), "|")
			If tmp2(0)="q" And jj<1 Then
				If jj<0 Then
					jj=jj+1
				Else 
					If tmp<>"" Then
						tmp=tmp &" AND"
					End If 
					tmp=tmp &" q.id<>"& tmp2(1)
				End If 
			Else '"d"
				If tmp<>"" Then
					tmp=tmp &" AND"
				End If 
				tmp=tmp &" q.descriptionpool_id<>"& tmp2(1)
				jj=-CInt(tmp2(3))
	'			Response.write "jj ; "& jj &Chr(13)&Chr(10)
			End If 
		Next 
		Erase tmp1
		If tmp<>"" Then
			dql=dql &" AND ("& tmp &")"
		End If 
	End If 

	tmp=""
	If cntH Then
		tmp="q.difficulty=1"
	End If 
	If cntM Then
		If tmp<>"" Then
			tmp=tmp &" OR "
		End If 
		tmp=tmp &"q.difficulty=2"
	End If 
	If cntL Then
		If tmp<>"" Then
			tmp=tmp &" OR "
		End If
		tmp=tmp &"q.difficulty=3"
	End If 
	If tmp<>"" Then
	'	Response.write tmp
		dql=dql &" AND ("& tmp &")"
	End If

	pql1="SELECT r.unitcode, LEFT(q.fieldcode, 6) AS field1, CONCAT('q|', q.id, '|', IF (ASCII(questiontype) BETWEEN 49 AND 52, questiontype, '0'), '|', q.difficulty, '|', questionfilename,"&_
		"'|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id"
	pql2="SELECT DISTINCT r.unitcode, LEFT(q.fieldcode, 6) AS field1, q.descriptionpool_id AS q_id"

'---------------------------------------------------------------------------------------------------------------------------------------------------------------

Dim qHtml, qChgBtn, qChgBtnHtml
qHtml="<div class='question_wrap mb40'>"&_
		"<input type='checkbox' style='margin-top:5px;' value='$qStr$' name='chkAddQ'>"&_
		"<div class='question_info'>"&_
		"<div class='unit'>$unitinfo$</div>"&_
		"<div class='question_num' style='float:right;'>$field1$<div class='level'>난이도 : <img src='/images/renew/sub/icon_search_$diffImg$.png' alt='$diffTxt$'></div><!--문항번호 : $qid$-->&nbsp;</div>"&_
		"</div>"&_
		"<ul class='question'><br />"&_
		"$src$"&_
		"</ul>"&_
		"</div>$srcA$"

qChgBtnHtml=""

Dim qFolder, dHtml:dHtml=""
dHtml="$src$"

Dim arrDiffImg:arrDiffImg=Array("", "top", "middle", "low") ' 난이도 표시...
Dim arrDiffTxt:arrDiffTxt=Array("", "상", "중", "하") ' 난이도 표시...

If htmlstr<>"" Then
'	Response.write htmlstr &"<br /><br />"
	Call g_oExamBank.Open(CFG_MYSQL_DSExamBankMid)
	Call g_oExamBank.execute("set names euckr") ' mysql 한글 깨짐 대비...

	htmlstr=""
'	sql=pql & dql &" AND q.descriptionpool_id=0 ORDER BY RAND() LIMIT "& limitCnt ' 지문없는 문항에서 먼저 검색...
'	sql="SELECT q_id FROM ("& sql &") AS tmp ORDER BY unitcode, field1"

' 지문 없는 문항...
'	pql1="SELECT * FROM ("& pql1 & dql &" AND q.descriptionpool_id=0 ORDER BY RAND() LIMIT "& limitCnt &") AS tmp1"
	pql1="SELECT * FROM ("& pql1 & dql &" AND q.descriptionpool_id=0 ORDER BY q.regdatetime DESC LIMIT 0,200) AS tmp1 ORDER BY RAND() LIMIT 0,"& limitCnt ' 170317 최신문항으로 검색 정렬...
	pql1="SELECT * FROM ("& pql1 &") AS tmp11" ' union 에러때문에 한번 더...

' 지문 있는 문항...
'	pql2="SELECT * FROM ("& pql2 & dql &" AND q.descriptionpool_id>0 ORDER BY RAND() LIMIT "& limitCnt &") AS tmp2" 
	pql2="SELECT * FROM ("& pql2 & dql &" AND q.descriptionpool_id>0 ORDER BY q.regdatetime DESC LIMIT 0,200) AS tmp2 ORDER BY RAND() LIMIT 0,"& limitCnt ' 170317 최신문항으로 검색 정렬...

'	Response.write pql1 &"<br />"
'	Response.write pql2 &"<br />"

	sql="SELECT q_id FROM ("& pql1 &" UNION "& pql2 &") AS tmp ORDER BY unitcode, field1 LIMIT 0,"& limitCnt
'	Response.write sql

' test용... id만 바꿔서... http://examview.dongahub.com/examdata/657465/html/657465_a.html
'	sql=pql &" FROM QuestionPoolUnitInfoRelation r INNER JOIN QuestionPool q ON r.questionpool_id=q.id WHERE q.id in (650193, 657465, 657543)"
'	Response.write dql
'	Response.write sql

	Set oRS=g_oExamBank.execute(sql)
	If Not (oRS.BOF Or oRS.EOF) Then 
		arrAdded=oRS.GetRows()
	End If 
	Call oRS.close

	If isArray(arrAdded) Then
		kk=0:d_ids2=""
		For ii=0 To UBound(arrAdded, 2)
			If htmlstr<>"" Then
				htmlstr=htmlstr &","
			End If

			q_id=arrAdded(0, ii)
'			Response.write ii &" : "& q_id &"<br />"
			If isNumeric(q_id) Then ' 지문 有...
				strQid="":d_ids1=""
				sql="SELECT q.id AS d_ids, CONCAT(q.id, '|', IF (ASCII(q.questiontype) BETWEEN 49 AND 52, q.questiontype, '0'), '|', q.difficulty,"&_
					"'|', q.questionfilename, '|', r.unitcode, '|', explainfilename, '|', substring(fieldcode, 5, 2)) AS q_id, d.descriptionfilename AS d_file"&_
					" FROM QuestionPool q INNER JOIN DescriptionPool d ON q.descriptionpool_id=d.id"&_
					" INNER JOIN QuestionPoolUnitInfoRelation r ON q.id=r.questionpool_id AND r.unitcode LIKE '"& unitcode &"%'"&_
					" WHERE q.fghwpconfirm='Y' AND q.fgattributeconfirm='Y' AND q.fgview='Y' AND q.descriptionpool_id="& q_id
'				Response.write sql &"<br /><br />"
				Set oRS=g_oExamBank.execute(sql)
				If Not (oRS.BOF Or oRS.EOF) Then
					jj=0
					Do While Not (oRS.BOF Or oRS.EOF)
						d_ids1=d_ids1 &","& oRS("d_ids")
						If strQid<>"" Then
							strQid=strQid &","
						End If 
						strQid=strQid &"q|"& Trim(oRS("q_id"))
						q_desc_file=Trim(oRS("d_file"))
						
						jj=jj+1
						oRS.movenext
					Loop 
'				Response.write "strQid : "& strQid &"<br />"
'				Response.write "jj : "& jj &"<br />"
				End If 
				Call oRS.close

				If strQid<>"" Then
					d_ids1="d|"& q_id &"|"& q_desc_file &"|"& jj &"/"& d_ids1
					strQid="d|"& q_id &"|"& q_desc_file &"|"& jj &","& strQid					
'					Response.write "<br />d_ids1 : "& d_ids1 &"<br />"
'					Response.write "<br />d_str : "& strQid &"<br />"
				End If 

				d_ids2=d_ids2 &"||"& d_ids1
				htmlstr=htmlstr & strQid

				kk=kk+jj
			Else
				htmlstr=htmlstr & q_id
				kk=kk+1
			End If 
'			Response.write "<br />d_ids2 : "& d_ids2 &"<br />"
'			Response.write "kk : "& kk &"<br />" ' 총 문제수
'			Response.write "ii : "& ii &"<br />" ' 체크박스 문제수...

			If kk>=limitCnt Then ' 
				Exit For 
			End If 
		Next 
		Erase arrAdded
	End If 
	If g_MEM.uid="dsdat00" Then 
'		Response.write "htmlstr : "& htmlstr &"<br />"
	End If 

	If htmlstr="" Then
'		Response.write sql
		Call util_alert("해당 조건의 문제가 없습니다.", "")
	End If 

	dCnt=0:ii=0:did=0:jj=0
	tmp1=Split(htmlstr, ",")

	For jj=0 To UBound(tmp1)
'		Response.write tmp1(jj) &"<br />"
		tmp2=Split(tmp1(jj), "|")
		If isArray(tmp2) And ubound(tmp2)>-1 Then
			src="":units=""
			qid=tmp2(1)
'			Response.write qid &"<br />"
			qFolder=getQfolder(qid)

'			Response.write "dCnt : "& dCnt &", ii : "& ii &", did : "& did &"<br />"
			If tmp2(0)="q" Then ' 문제지. q | q_id | questiontype | difficulty | q_filename | unitcode | a_filename | field1 형식...
				unitStr=tmp2(5)
				If useField Then
					units=getFieldInfo(qid)
				Else 
					units=getUnitInfo(unitStr)
				End If 
'				fileUrlQ=examUrl & qFolder &"/html/"& replace(tmp2(4), ".hwp", ".html")
'				fileUrlA=examUrl & qFolder &"/html/"& replace(tmp2(6), ".hwp", ".html")
				If makeStyle="img" Then 
					fileUrlQ=examUrl & getFileImage(qid, tmp2(4))
					fileUrlA=examUrl & getFileImage(qid, tmp2(6))
				ElseIf makeStyle="html" Then 
					fileUrlQ=examUrl & getFilename(qid, tmp2(4))
					fileUrlA=examUrl & getFilename(qid, tmp2(6))
				End If 
'				Response.write fileUrlQ &"<br />"

				If dCnt=0 Or (dCnt>1 And ii=0) Then 
					If dCnt=0 Then
						did=0
					End If 
					qChgBtn=Replace(qChgBtnHtml, "$qStr$", tmp1(jj))
				Else
					qChgBtn=""
				End If 
				If dCnt>0 Then
					dCnt=dCnt-1
				End If 
'				Response.write "q dCnt : "& dCnt &", ii : "& ii &", did : "& did &"<br />"
				ii=ii+1

				srcHtml=Replace(qHtml, "$unitinfo$", units) ' 단원정보 치환...
				srcHtml=Replace(srcHtml, "$diffImg$", arrDiffImg(tmp2(3))) ' 난이도 치환...
				srcHtml=Replace(srcHtml, "$diffTxt$", arrDiffTxt(tmp2(3))) ' 난이도 치환...
				srcHtml=Replace(srcHtml, "$qid$", qid) ' qid 치환...
				srcHtml=Replace(srcHtml, "$did$", did) ' did 치환...
				srcHtml=Replace(srcHtml, "$qStr$", tmp1(jj)) ' did 치환...
'				$field1$<div class='level'>영역 : <img src='/images/renew/sub/img_item_$field1$.png' class='item_subj'></div>
				If classtype="MI" And subject="EN" And Not useField Then
					field1s="<div>영역 : <img src='/images/renew/sub/img_item_"& tmp2(7) &".png' style='width:28px;height:18px;'>&nbsp;</div>"
				Else
					field1s=""
				End If 
				srcHtml=Replace(srcHtml, "$field1$", field1s) ' did 치환...

			ElseIf tmp2(0)="d" Then ' 지문. d | d_id | d_filename | dCnt 형식
				did=qid
				dCnt=CInt(tmp2(3))
				If dCnt>0 Then 
					If makeStyle="img" Then
						'fileUrlQ=examUrl & qFolder &"/image/"& replace(tmp2(2), ".hwp", ".gif")
						fileUrlQ=examUrl & getFileImage(qid, tmp2(2))
					ElseIf makeStyle="html" Then
						'fileUrlQ=examUrl & qFolder &"/html/"& replace(tmp2(2), ".hwp", ".html")
						fileUrlQ=examUrl & getFilename(qid, tmp2(2))
					End If 
					fileUrlA=fileUrlQ ' 해설도 지문 동일...?
					ii=0
				End If 
'				Response.write "d dCnt : "& dCnt &", ii : "& ii &", did : "& did &"<br />"
'				Response.write "dHtml : "& dHtml &"<br />"

				srcHtml=""& dHtml
			End If 

			' question...---------------------------------------------------------------------------------------------------------------------------------
			If makeStyle="img" Then
				src="<img src='"& fileUrlQ &"' />"
			ElseIf makeStyle="html" Then
				src=getInfo_function(fileUrlQ)
				If src<>"" Then 
					tmp3=Split(src, "<BODY>")
					tmp4=Split(tmp3(1), "</BODY>")
					src=tmp4(0)
					src=chkImg(src, examUrl, qid) ' image 정규식으로 처리...

					Erase tmp3
					Erase tmp4
				End If 
			End If 
			srcHtml=Replace(srcHtml, "$src$", src) ' html 소스 치환...
			
			' answer...---------------------------------------------------------------------------------------------------------------------------------
'			Response.write "fileUrlA : "& fileUrlA &"<br />"
			If makeStyle="img" Then
				src="<div class='qExplain'><img src='"& fileUrlA &"' /></div>"
			ElseIf makeStyle="html" Then
				src=getInfo_function(fileUrlA)
				If src<>"" Then 
					tmp3=Split(src, "<BODY>")
					tmp4=Split(tmp3(1), "</BODY>")
					src=tmp4(0)
					src=chkImg(src, examUrl, qid) ' image 정규식으로 처리...

					Erase tmp3
					Erase tmp4
				End If 
				src=rmSpace(src) ' 공백제거
	'			If Left(unitStr, 2)="EL" Then 
					src=ansStyleEL(src) ' (해답) 스타일 수정...
					src="<div class='qExplain'>"& src &"</div>"
	'			End If
			End If 

'			srcHtml=Replace(srcHtml, "$srcA$", "<div style='margin:-40px 0 20px 0;'>"& src &"</div>") ' 해설/정답 치환...
			srcHtml=Replace(srcHtml, "$srcA$", "<div class='item_explain' style='margin:-40px 0 50px 0;'>"& src &"</div>") ' 해설/정답 치환...
			srcHtml=Replace(srcHtml, "$qChgBtn$", qChgBtn) ' 문제교환버튼 치환...

			Response.write srcHtml
			Response.flush 
			
		End If
		Erase tmp2
	Next 
	Response.write "<input type='hidden' id='d_ids' value='"& d_ids2 &"' />"
	Response.write "</div>"

	Call g_oExamBank.Close
End If 
%>
<!--#include virtual='/inc/end.inc' -->