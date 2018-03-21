<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=1 ' 로그인 상태에서...
g_pageDiv="proc_get_etcPhotoData" ' 출판CMS 데이터([TEXTBOOK_prod].dbo.CMS_MEDIA_MAIN) ----> 창체 사진자료실...(TP_CMS_MEDIA_MAIN)
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<%
Dim sql, oRS, tbl, wqry, maxMediaSeq, iql, col
Dim isProd:isProd=False  ' 실제 작업인지............................ False / True

' 등록된 max값 구하기...
sql="SELECT ISNULL(MAX(media_seq), 0) FROM TP_CMS_MEDIA_MAIN"
Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
maxMediaSeq=oRS(0)
Call oRS.close()

Response.write "maxMediaSeq : "& maxMediaSeq &"<br /><br />"
'maxMediaSeq=164280 ' ex

' insert qry & cols...
iql="INSERT INTO TP_CMS_MEDIA_MAIN ("&_
	"cate_code, cateL_code, cateS_code, isDisplay, media_seq, curri_no"&_
	", large_cate_code, large_cate_name, middle_cate_code, middle_cate_name, small_cate_code, small_cate_name, detail_cate_code, detail_cate_name"&_
	", file_name, file_mng_name, code, code_subj_cd, code_grd_cd, code_chapter1, code_chapter2, code_chapter3, code_eng_code1, code_eng_code2, code_eng_code3"&_
	", code_formation, code_q_type, code_q_step, code_q_property, code_q_math, code_q_frequency, code_q_difficulty, code_q_represent, code_q_questionstep"&_
	", caption, key_word, media_desc, copyright, media_type, file_type, upload_path, is_delete, reg_user_no, reg_user_date, modi_user_no, modi_date) "


col=", null AS cateS_code, 'y' AS isDisplay"&_
	", media_seq, curri_no"&_
	", large_cate_code, large_cate_name, middle_cate_code, middle_cate_name, small_cate_code, small_cate_name, detail_cate_code, detail_cate_name"&_
	", file_name, file_mng_name, code, code_subj_cd, code_grd_cd, code_chapter1, code_chapter2, code_chapter3, code_eng_code1, code_eng_code2, code_eng_code3"&_
	", code_formation, code_q_type, code_q_step, code_q_property, code_q_math, code_q_frequency, code_q_difficulty, code_q_represent, code_q_questionstep"&_
	", caption, key_word, media_desc, copyright, media_type, file_type, upload_path, is_delete, reg_user_no, reg_user_date, modi_user_no, modi_date"

tbl=" FROM [TEXTBOOK_prod].dbo.CMS_MEDIA_MAIN AS ori WITH (NOLOCK)"&_
	" WHERE media_seq>"& maxMediaSeq &" AND is_delete='N'"


' 지역학습 데이터 이전... (한국문화관광연구원)
wqry=tbl &" AND license=N'한국문화관광연구원'"

sql="SELECT COUNT(*)"& wqry
Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
Response.write "count : "& oRS(0) &"<br /><br />"
Call oRS.close()

sql="SELECT 'area' AS cate_code"&_
	", ori.detail_cate_name AS cateL_code"&_
	col & wqry	
Response.write iql & sql &"<br />"
If isProd Then
	Call g_oDB.execute(iql & sql)
	Response.write "done...<br />"
End If 
Response.write "<br />"



' 이미지 자료실 데이터 이전... (동아출판) / 상위 카테고리 매칭...
wqry=tbl &" AND license=N'동아출판'"

sql="SELECT COUNT(*)"& wqry
Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
Response.write "count : "& oRS(0) &"<br /><br />"
Call oRS.close()

sql="SELECT 'photo' AS cate_code"&_
	", CASE"&_
	"	WHEN large_cate_name=N'역사' THEN 'his'"&_
	"	WHEN large_cate_name=N'사회' OR large_cate_name=N'일반사회' THEN 'soc'"&_
	"	WHEN large_cate_name=N'지리' THEN 'loc'"&_
	"	WHEN large_cate_name=N'과학' THEN 'sci'"&_
	"	WHEN large_cate_name=N'실과' AND small_cate_name like N'%종류' THEN 'sci'"&_
	"	WHEN large_cate_name=N'기술가정' THEN 'tch'"&_
	"	WHEN large_cate_name=N'실과' AND (middle_cate_name=N'가정' OR middle_cate_name=N'기술') THEN 'tch'"&_
	"	WHEN large_cate_name=N'미술' OR large_cate_name=N'음악' THEN 'cul'"&_
	"	WHEN large_cate_name=N'체육' THEN 'les'"&_
	"END AS cateL_code"&_
	col & wqry
'	"--	when large_cate_name=N'기술가정' AND (middle_cate_name=N'건설기술' OR middle_cate_name=N'건설 기술') THEN 'cul'"&_
Response.write iql & sql &"<br />"
If isProd Then
	Call g_oDB.execute(iql & sql)
	Response.write "done...<br />"
End If 
Response.write "<br />"


' 이미지 데이터 하위 카테고리 매칭...
sql="UPDATE TP_CMS_MEDIA_MAIN SET cateS_code="&_
	"CASE"&_
	" WHEN cateL_code='his' THEN"&_
	"	CASE"&_
	"		WHEN middle_cate_name=N'세계사' THEN 'wrd'"&_
	"	ELSE 'kor'"&_
	"	END"&_
	" WHEN cateL_code='soc' THEN"&_
	"	CASE"&_ 
	"		WHEN small_cate_name=N'정치' THEN 'pol'"&_
	"		WHEN small_cate_name=N'경제' THEN 'eco'"&_
	"		WHEN small_cate_name=N'사회문화' THEN 'cul'"&_
	"		WHEN small_cate_name=N'법' THEN 'law'"&_
	"		WHEN middle_cate_name=N'국제' THEN 'wrd'"&_
	"	ELSE 'kor'"&_
	"	END"&_
	" WHEN cateL_code='loc' THEN"&_
	"	CASE"&_
	"		WHEN small_cate_name=N'지형' THEN 'geo'"&_
	"		WHEN small_cate_name=N'도시' THEN 'cty'"&_
	"		WHEN small_cate_name=N'문화' THEN 'cul'"&_
	"		WHEN small_cate_name=N'인구' THEN 'pop'"&_
	"		WHEN middle_cate_name=N'세계' THEN 'wrd'"&_
	"	ELSE 'kor'"&_
	"	END"&_
	" WHEN cateL_code='sci' THEN"&_
	"	CASE "&_
	"		WHEN small_cate_name=N'동식물' THEN 'aNp'"&_
	"		WHEN large_cate_name=N'실과' AND middle_cate_name=N'기술' AND (small_cate_name like N'%종류') THEN 'aNp'"&_
	"		WHEN middle_cate_name=N'생명' THEN 'lif'"&_
	"		WHEN middle_cate_name=N'물질' THEN 'mat'"&_
	"		WHEN middle_cate_name=N'물리' THEN 'phy'"&_
	"		WHEN middle_cate_name=N'통합' THEN 'stc'"&_
	"	ELSE 'ear'"&_
	"	END"&_
	" WHEN cateL_code='tch' THEN"&_
	"	CASE"&_
	"		WHEN middle_cate_name LIKE N'가족%' OR middle_cate_name LIKE N'직업%' THEN 'mem'"&_
	"		WHEN large_cate_name=N'실과' AND middle_cate_name=N'기술' AND small_cate_name=N'진로' THEN 'mem'"&_
	"		WHEN middle_cate_name=N'의' OR middle_cate_name=N'식' OR middle_cate_name=N'주' OR middle_cate_name=N'소비' THEN 'env'"&_
	"		WHEN large_cate_name=N'실과' AND middle_cate_name=N'가정' THEN 'env'"&_
	"		WHEN middle_cate_name=N'기술의 발달' OR middle_cate_name=N'발명' OR middle_cate_name=N'제조기술' OR middle_cate_name=N'제조 기술'"&_
	" OR middle_cate_name=N'생명기술' OR middle_cate_name=N'생명 기술' OR middle_cate_name=N'수송기술' OR middle_cate_name=N'수송 기술' THEN 'inv'"&_
	"		WHEN middle_cate_name=N'전기 전자 기술' OR middle_cate_name=N'기계 기술' THEN 'elc'"&_
	"		WHEN middle_cate_name=N'정보 통신 기술' THEN 'com'"&_
	"		WHEN middle_cate_name like N'건설%' THEN 'bld'"&_
	"		WHEN large_cate_name=N'실과' AND middle_cate_name=N'기술' THEN 'ltc'"&_
	"	ELSE ''"&_
	"	END"&_
	" WHEN cateL_code='cul' THEN"&_
	"	CASE"&_
	"		WHEN large_cate_name=N'음악' THEN 'mus'"&_
	"		WHEN middle_cate_name=N'디자인' AND (small_cate_name like N'건축%' OR small_cate_name like N'실내외%') THEN 'arc'"&_
	"	ELSE 'art'"&_
	"	END"&_
	" WHEN cateL_code='les' THEN"&_
	"	CASE"&_
	"		WHEN middle_cate_name=N'경쟁활동' OR middle_cate_name=N'도전활동' THEN 'spt'"&_
	"		WHEN middle_cate_name=N'여가활동' OR middle_cate_name=N'표현활동' THEN 'les'"&_
	"		WHEN middle_cate_name=N'건강활동' THEN 'hlt'"&_
	"	ELSE ''"&_
	"	END"&_
	" END"&_
	" WHERE is_delete='N'"&_
	" AND cate_code='photo'"&_
	" AND media_seq>"& maxMediaSeq
Response.write sql &"<br />"
If isProd Then
	Call g_oDB.execute(sql)
	Response.write "done...<br />"
End If 
Response.write "<br />"


' count...
sql="SELECT COUNT(*) FROM TP_CMS_MEDIA_MAIN WHERE media_seq>"& maxMediaSeq
Response.write sql &"<br />"
Set oRS=g_oDB.execute(sql)
Response.write "total count : "& oRS(0)
Call oRS.close()


' 엑셀 처리 참고... 164280
sql="SELECT cate_code, cateL_code, cateS_code, COUNT(cateL_code) AS cnt"&_
	" FROM TP_CMS_MEDIA_MAIN WHERE media_seq>"& maxMediaSeq &_
	" GROUP BY cate_code, cateL_code, cateS_code"
Response.write "<br /><br />엑셀 처리...<br />"
Response.write sql &"<br />"
%>

<!--#include virtual='/inc/END.inc' -->