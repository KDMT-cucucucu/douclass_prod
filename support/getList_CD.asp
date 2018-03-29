<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="support_CD"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<script type="text/javascript" src="/js/admin.js"></script>
<!--#include virtual='/inc/start.inc' -->

<%
Dim sql, oRS, arrRows, arrCnt, ii
Dim sch, imgPath, curri, sbj, title, files1, files2, files3, oldSbj:oldSbj=""
Dim type02, mediaType

sch=util_nte(Trim(request("sch")), "M", "string")
curri=util_nte(Trim(request("curri")), "15", "string") ' 180108 15개정 추가...
%>
					<div class="revision_tab">
						<ul>
<% If curri="15" Then %>	<!-- icon_btn_2009_on 에서 icon_btn_09_on 변경 -->
							<li class="tab_btn_2015" style="cursor:pointer;">
								<img src="/images/renew/sub/icon_btn_15_on.png" class="on_btn on"	onClick="showCD('<%=sch %>', '15');" />
								<img src="/images/renew/sub/icon_btn_15_off.png" class="off_btn"/>
							</li>
							<li class="tab_btn_2009" style="cursor:pointer;">
								<img src="/images/renew/sub/icon_btn_09_on.png" class="on_btn"/>
								<img src="/images/renew/sub/icon_btn_09_off.png" class="off_btn on" onClick="showCD('<%=sch %>', '09');" />
							</li>
<% Else %>
							<li class="tab_btn_2015" style="cursor:pointer;">
								<img src="/images/renew/sub/icon_btn_15_on.png" class="on_btn"/>
								<img src="/images/renew/sub/icon_btn_15_off.png" class="off_btn on" onClick="showCD('<%=sch %>', '15');" />
							</li>
							<li class="tab_btn_2009" style="cursor:pointer;">
								<img src="/images/renew/sub/icon_btn_09_on.png" class="on_btn on" onClick="showCD('<%=sch %>', '09');" />
								<img src="/images/renew/sub/icon_btn_09_off.png" class="off_btn" />
							</li>
<% End If %>
							<li></li>
						</ul>
					</div>
<%
If sch="M" Then ' 선택 과목 때문에 하단에 한번 더 쿼리...
	sql="SELECT tmp.imgPath, cd.curri, cd.sbj, cd.title, cd.files1, cd.files2, cd.files3, cd.mediaType FROM TP_cdList AS cd INNER JOIN ("&_
		"SELECT srt.*, img.imgPath FROM TP_sortingSubject AS srt LEFT JOIN TP_imageList AS img"&_
		" ON srt.sch=img.sch AND srt.sbj=img.sbj AND img.img_position='support' AND img.Dbook_seq=0 AND img.sub_position IS NULL"&_
		" WHERE srt.sch='"& sch &"') AS tmp"&_
		" ON tmp.sch=cd.sch AND tmp.sbj=cd.sbj AND cd.isDisplay='Y'"&_
		" AND (cd.files1<>'' OR cd.files2<>'' OR cd.files3<>'')"&_
		" AND cd.sbj NOT IN ('"& chkSbjGrp(0) &"')"&_
		" WHERE tmp.sch='"& sch &"' AND cd.curri='"& curri &"' ORDER BY tmp.orderNo, cd.curri DESC, cd.orderNo"
Else
	sql="SELECT tmp.imgPath, cd.curri, cd.sbj, cd.title, cd.files1, cd.files2, cd.files3, cd.mediaType FROM TP_cdList AS cd INNER JOIN ("&_
		"SELECT srt.*, img.imgPath FROM TP_sortingSubject AS srt LEFT JOIN TP_imageList AS img"&_
		" ON srt.sch=img.sch AND srt.sbj=img.sbj AND img.img_position='support' AND img.Dbook_seq=0 AND img.sub_position IS NULL"&_
		" WHERE srt.sch='"& sch &"') AS tmp"&_
		" ON tmp.sch=cd.sch AND tmp.sbj=cd.sbj AND cd.isDisplay='Y'"&_
		" AND (cd.files1<>'' OR cd.files2<>'' OR cd.files3<>'')"&_
		" WHERE cd.sch='"& sch &"' AND cd.curri='"& curri &"' ORDER BY tmp.orderNo, cd.curri DESC, cd.orderNo"
End If
'Response.write "<tr><td colspan=3>"& sql &"</td></tr>"
arrRows=get_oRs(sql)
If IsArray(arrRows) Then
	arrCnt=UBound(arrRows, 2)
	For ii=LBound(arrRows, 2) To arrCnt
		imgPath = arrRows( 0, ii )
		curri = arrRows( 1, ii )
		sbj = arrRows( 2, ii )
		title = arrRows( 3, ii )
		files1 = arrRows( 4, ii )
		files2 = arrRows( 5, ii )
		files3 = arrRows( 6, ii )
		mediaType = util_nte(Trim(arrRows( 7, ii )), "CD", "string")		

		If sbj<>oldSbj Then
%>
<script>
var sch = "<%=sch %>";
var sbj = "<%=sbj %>";

var arr=eval("arrSbj"+ sch);
for(var i=0; i <arr.length; i++){
    if(arr[i][0] == sbj){
		var tmpTitle=arr[i][1];
		if (arr[i][0]=="X"){
			tmpTitle=tmpTitle.replace("창의적 체험활동", "창체");
			tmpTitle=tmpTitle.replace("창의적 체험", "창체");
		}
		if (arr[i][0]!="2"){ // 예체능 아니면...
			tmpTitle+="<img src='/images/renew/sub/icon_smart_20<%=curri %>_2.png' style='position:relative; top:2.5px; left:9px;' />";
		}
	   $("#<%=sch & sbj %>_title").html(tmpTitle);
	   break;
    }
}
</script>
					<ul class="list">
						<span id="<%=sch & sbj %>_title" class="title"><%'=title %></span>
						<ul style="overflow:hidden;">
							<ul class="subject" id="<%=sch & sbj & curri %>">
							</ul>
							<ul class="subject type02" id="<%=sch & sbj & curri %>_02">
							</ul>
						</ul>
					</ul>
<%		
		End If

		If curri<>"" Then
%>
<script>
arr<%=curri %>.push(["<%=sch & sbj %>", "<%=title %>", "<%=files1 %>", "<%=files2 %>", "<%=files3 %>", "<%=mediaType %>"]);
</script>
<%
		End If

		oldSbj=sbj
	Next
	Erase arrRows

	If sch="M" Then ' 선택 과목... 'N','I','J' -> '0'
		sql="SELECT tmp.imgPath, cd.curri, '0' AS sbj, cd.title, cd.files1, cd.files2, cd.files3 FROM TP_cdList AS cd LEFT JOIN ("&_
			"SELECT srt.*, img.imgPath FROM TP_sortingSubject AS srt LEFT JOIN TP_imageList AS img"&_
			" ON srt.sch=img.sch AND srt.sbj=img.sbj AND img.img_position='support' AND img.Dbook_seq=0 AND img.sub_position IS NULL"&_
			" WHERE srt.sch='"& sch &"') AS tmp"&_
			" ON tmp.sch=cd.sch AND tmp.sbj=cd.sbj AND cd.isDisplay='Y'"&_
			" AND (cd.files1<>'' OR cd.files2<>'' OR cd.files3<>'')"&_
			" AND cd.sbj IN ('"& chkSbjGrp(0) &"')"&_
			" WHERE tmp.sch='"& sch &"' AND cd.curri='"& curri &"' ORDER BY tmp.orderNo, cd.curri DESC, cd.orderNo"
'		Response.write "<tr><td colspan=3>"& sql &"</td></tr>"
		Set oRS=g_oDB.execute(sql)
		Do While Not (oRS.BOF Or oRS.EOF)
			imgPath=Trim(oRS("imgPath"))
			curri=Trim(oRS("curri"))
			sbj="0"' Trim(oRS("sbj"))
			title=Trim(oRS("title"))
			files1=Trim(oRS("files1"))
			files2=Trim(oRS("files2"))
			files3=Trim(oRS("files3"))

		If sbj<>oldSbj Then
		
%>
					<ul class="list">
						<span class="title">선택<%'=title %><img src="/images/renew/sub/icon_smart_20<%=curri %>_2.png" style=" position:relative; top:2.5px; left:9px;"/></span>
						<ul style="overflow:hidden;">
							<ul class="subject" id="<%=sch & sbj & curri %>">
							</ul>
							<ul class="subject type02" id="<%=sch & sbj & curri %>_02">
							</ul>
						</ul>
					</ul>
<%		
		End If

		If curri<>"" Then
%>
<script>
arr<%=curri %>.push(["<%=sch & sbj %>", "<%=title %>", "<%=files1 %>", "<%=files2 %>", "<%=files3 %>", "<%=mediaType %>"]);
</script>
<%
		End If

			oldSbj=sbj
			oRS.movenext
		Loop
		Call oRS.close()
	End If
End If
%>
<script>
printCD("09");
printCD("15");
//printCD("08");

//수학 문구 추가...
//var MM08=$("#MM08").html();
//MM08+='<br /><span style="font-family:Dotum, 돋움;font-size:11px;color:#757575;">※ 실행 오류 시 <a href="http://www.douclass.com/customer/?list=1&idx=517" style="color:blue;text-decoration:underline;">여기</a>를 클릭하세요.</span>';
//$("#MM08").html(MM08);

//var HM08=$("#HM08").html();
//HM08+='<br /><span style="font-family:Dotum, 돋움;font-size:11px;color:#757575;">※ 실행 오류 시 <a href="http://www.douclass.com/customer/?list=1&idx=546" style="color:blue;text-decoration:underline;">여기</a>를 클릭하세요.</span>';
//$("#HM08").html(HM08);
</script>