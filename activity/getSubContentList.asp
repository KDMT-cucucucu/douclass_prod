<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getMediaList"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->

<%
Dim sql, oRS, ii, wquery, sortBy
Dim page, pagesize, initPage, totCnt, totpage

Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim template:template=util_nte(request("template"), 0, "int")
Dim getup_seq:getup_seq=util_nte(request("getup_seq"), 0, "int")
Dim geteq:geteq=util_nte(request("geteq"), 0, "int")
Dim getsubeq:getsubeq=util_nte(request("getsubeq"), 0, "int")
Dim mode:mode=util_nte(request("mode"), "", "string")
Dim subcnt, blockpg
Dim content_title, content_image
Dim thumbnail
Dim subSeq

Dim num:num=util_nte(request("num"), 0, "int")

page=util_nte(request("page"), 1, "int")

'Response.write template

%>
<%
Sub subConBtn1 (script, cpage, tpage, gsize)
    If tpage>=cpage Then
		Dim page_s:page_s = cpage-Round(gsize/2)
		If tpage-gsize<page_s Then page_s = tpage-gsize
		If page_s<1 Then page_s=1
		Dim page_e:page_e = page_s+gsize
		If page_e>tpage Then page_e = tpage ' 있는 페이지까지만 표시
%>
<%	If cpage>1 Then %>
							<img src="/images/renew/sub/arrow_left_on.png" class="arrow_left" onClick="javascript:void <%=script %>(<%=cpage-1 %>);" />
<%	Else %>
							<img src="/images/renew/sub/arrow_left_off.png" class="arrow_left" onClick="javascript:;" />
<%	End If
	
	Dim page
	For page=page_s to page_e
		If page<=tpage Then
			If page=cpage Then
%> 
						
<%			Else %>

<%			End If
		Else
%>
							
<%
		End If
	Next
	
	If cpage<tpage Then
%>
							<img src="/images/renew/sub/arrow_right_on.png" class="arrow_right" onClick="javascript:void <%=script %>(<%=cpage+1 %>);" />
<%	Else %>
							<img src="/images/renew/sub/arrow_right_off.png" class="arrow_right" onClick="javascript:;" />
<%	End If %>
<%
    End If
End Sub
%>
<%
Sub subConBtn3 (script, cpage, tpage, gsize)
    If tpage>=cpage Then
		Dim page_s:page_s = cpage-Round(gsize/2)
		If tpage-gsize<page_s Then page_s = tpage-gsize
		If page_s<1 Then page_s=1
		Dim page_e:page_e = page_s+gsize
		If page_e>tpage Then page_e = tpage ' 있는 페이지까지만 표시
%>
<%	If cpage>1 Then %>
							<img src="/images/renew/sub/arrow_left_on.png" class="photoData_screen_left_btn" onClick="javascript:void <%=script %>(<%=cpage-1 %>);" />
<%	Else %>
							<img src="/images/renew/sub/arrow_left_off.png" class="photoData_screen_left_btn" onClick="javascript:;" />
<%	End If
	
	Dim page
	For page=page_s to page_e
		If page<=tpage Then
			If page=cpage Then
%> 
						
<%			Else %>

<%			End If
		Else
%>
							
<%
		End If
	Next
	
	If cpage<tpage Then
%>
							<img src="/images/renew/sub/arrow_right_on.png" class="photoData_screen_right_btn" onClick="javascript:void <%=script %>(<%=cpage+1 %>);" />
<%	Else %>
							<img src="/images/renew/sub/arrow_right_off.png" class="photoData_screen_right_btn" onClick="javascript:;" />
<%	End If %>
<%
    End If
End Sub
%>


<% 
If template=1 Then
%>
<script type="text/javascript">
function viewPrev(num){
	var len=$(".slide_thum li img").length;
	var fPage=$("#subList1 .box_table_num ul.clearfix li").find("strong").text();
	var lPage=$("#subList1 .box_table_num ul.clearfix li").length;

	for(var i=0; i<lPage; i++){
		if($("#subList1 .box_table_num ul.clearfix li:eq("+i+") a").text()=="Next"){
			lPage=i-2;
		}
	}

	for(var i=len; i>=0; i--){
		if(i>0 && i<=len){
			$(".arrow_left").attr("src", "/images/renew/sub/arrow_left_on.png");
			$(".arrow_right").attr("src", "/images/renew/sub/arrow_right_on.png")
			if($(".slide_thum li img:eq("+i+")").hasClass("on")){
				moveClick=$(".slide_thum li:eq("+((i)-num)+") img").attr("onClick");
				//alert(moveClick);
				moveClick=eval(moveClick);
				$(".slide .slide_thum li img").removeClass("on");
				$(".slide_thum li:eq("+(i-num)+") img").addClass("on");
				return;
			}
		}else if((i==0 && fPage==lPage && fPage>1) || (i==0 && fPage<lPage && fPage>1)){
			getSubConList(Number(fPage)-1, 9);
		}else{
			$(".arrow_left").attr("src", "/images/renew/sub/arrow_left_off.png");
			return;
		}
	}
}
function viewNext(num){
	var len=$(".slide_thum li img").length;
	var fPage=$("#subList1 .box_table_num ul.clearfix li").find("strong").text();
	var lPage=$("#subList1 .box_table_num ul.clearfix li").length;

	for(var i=0; i<lPage; i++){
		if($("#subList1 .box_table_num ul.clearfix li:eq("+i+") a").text()=="Next"){
			lPage=i-2;
		}
	}
	for(var i=0; i<len; i++){
		if(i+num>0 && i+num<len){
			$(".arrow_left").attr("src", "/images/renew/sub/arrow_left_on.png")
			if($(".slide_thum li img:eq("+i+")").hasClass("on")){
				//alert(i);
				moveClick=$(".slide_thum li:eq("+(i+1)+") img").attr("onClick");
				//alert(moveClick);
				moveClick=eval(moveClick);
				$(".slide .slide_thum li img").removeClass("on");
				$(".slide_thum li:eq("+(i+num)+") img").addClass("on");
				return;
			}

		}else if(i==9 && fPage<lPage){
			getSubConList(Number(fPage)+1, 0);
		}else if((i==9 && fPage==lPage) || ((i+1)==len && fPage==lPage)){
			$(".arrow_right").attr("src", "/images/renew/sub/arrow_right_off.png");
			return;
		}
	}
}

$(function(){
var num = '<%=num %>';

	var len=$(".slide_thum li img").length;
	var fPage=$("#subList1 .box_table_num ul.clearfix li").find("strong").text();
	var lPage=$("#subList1 .box_table_num ul.clearfix li").length;

	for(var i=0; i<lPage; i++){
		if($("#subList1 .box_table_num ul.clearfix li:eq("+i+") a").text()=="Next"){
			lPage=i-2;
		}
	}

	var firstClick=$(".slide_thum li:eq("+num+") img").attr("onClick");
	firstClick = eval(firstClick);
	$(".slide_thum li:eq("+num+") img").addClass("on");	
		
	if(fPage==1){
		$(".arrow_left").attr("src", "/images/renew/sub/arrow_left_off.png");
	}

	/*	slide_thum */
	$(".slide .slide_thum li:nth-child(n+1) img").click(function(){
		$(".slide .slide_thum li img").removeClass("on");			
		$(this).addClass("on");
	});			
	$(".slide .slide_thum li:nth-child(n+6)").css("margin-top", "2px");
});
</script>
<%
	'sql = "SELECT * FROM CP_contents WHERE isDelete<>'Y' AND seq="& seq
	'Response.write sql
	'Set oRS=g_oDB.Execute(sql)
	'	If Not (oRS.BOF Or oRS.EOF) Then
	'		content_title=Trim(oRS("title"))
	'		content_image=Trim(oRS("image"))
	'	End If
	'Call oRS.Close()
	'Set oRS = Nothing


	SQL="SELECT COUNT(*) AS cnt FROM CP_contetsSub WHERE type='image' AND from_seq="& seq
	'Response.write SQL
	Set oRS=g_oDB.Execute(sql)
		subcnt=oRS(0)
	Call oRS.close()
	Set oRS = Nothing
	If subcnt>0 Then
		pagesize=10
		totpage=int((subcnt-1)/pagesize)+1
		blockpg=pagesize*(page-1)
		If page<1 Then
			page=1
		ElseIf page>totpage Then
			page=totpage
		End If

%>
								<% 'Call subConBtn1("getSubConList", page, totpage, 10) %>
								<img src="/images/renew/sub/arrow_left_on.png" class="arrow_left" onClick="javascript:viewPrev(1);" />
								<img src="/images/renew/sub/arrow_right_on.png" class="arrow_right" onClick="javascript:viewNext(1);" />
								<img src="<%=content_image %>" class="slide_main"/>
								<span class="slide_main_info"><div id="triangle-up"></div><%=content_title %></span>
								<span style="position:absolute;margin-left:35px;margin-top:14px;font-size:14px;color:#333333;font-family:'맑은 고딕', '나눔고딕', '돋움';">관련 사진 보기</span>
								<ul class="slide_thum">
<%
		SQL="SELECT * FROM "&_
			" (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, seq DESC) AS ROWNUM, c.*"&_
			" FROM CP_contetsSub AS c WHERE type='image' AND from_seq="&seq&") AS list"&_
			" WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		'Response.write SQL
		'Response.End
		Set oRS=g_oDB.Execute(sql)
			ii=0
			Do While Not (oRS.BOF Or oRS.EOF)
%>
									<li><img src="<%=Trim(oRS("path")) %>" onClick="viewPhoto('<%=Trim(oRS("path")) %>', '<%=Trim(oRS("content")) %>', <%=ii+1 %>);" /></li>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
%>
								<!--<li style="width:500px;"><span>데이터가 없습니다.</span></li>-->
<%

		End If 
%>
								</ul>
								<%Call new_pageNavi_ul("getSubConList", page, totpage, 10)%>
								</div>
<%
	ElseIf template=2 Then
%>
<script type="text/javascript">
$(function(){
	/*	slide_thum */
	$(".box_photoData_screen li:nth-child(n+1) img").click(function(){
		$(".box_photoData_screen li img").removeClass("on");			
		$(this).addClass("on");
	});						

});
</script>
<%
		SQL="SELECT COUNT(*) AS cnt FROM CP_contetsSub WHERE from_seq="& seq
		'Response.write SQL
		Set oRS=g_oDB.Execute(sql)
			subcnt=oRS(0)
		Call oRS.close()
		Set oRS = Nothing

		If subcnt>0 Then
			pagesize=4
			totpage=int((subcnt-1)/pagesize)+1
			blockpg=pagesize*(page-1)
			If page<1 Then
				page=1
			ElseIf page>totpage Then
				page=totpage
			End If
%>
							<span>관련 콘텐츠 보기</span>
							<% Call subConBtn3("getSubConList", page, totpage, 4) %>
							<ul class="box_photoData_screen clearfix" >
<%
		SQL="SELECT * FROM "&_
			" (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, seq DESC) AS ROWNUM, c.*"&_
			" FROM CP_contetsSub AS c WHERE from_seq="&seq&") AS list"&_
			" WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		'Response.write SQL
		'Response.End
		Set oRS=g_oDB.Execute(sql)
			ii=0
			Do While Not (oRS.BOF Or oRS.EOF)
				thumbnail = Trim(oRS("thumbnail"))
				subSeq = oRS("contents_seq")
%>
								<li>
								<% If thumbnail<>"" Then %>
									<img src="<%=thumbnail %>" style="width:132px; height:100px;" onClick="goDetail('<%=subSeq %>');" />
								<% Else %>
									<img src="/images/renew/noimage.gif" style="width:132px; height:100px;" onClick="goDetail('<%=subSeq %>');" />
								<% End If %>
								<span><%=Trim(oRS("title")) %></span>	
								</li>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
%>
								
<%					
		Else
%>
								<!--<li style="width:500px;"><span>데이터가 없습니다.</span></li>-->
<%

		End If 
%>
							</ul>
<%
	ElseIf template=3 Then
%>
<script type="text/javascript">
$(function(){
	/*	slide_thum */
	$(".box_photoData_screen li:nth-child(n+1) img").click(function(){
		$(".box_photoData_screen li img").removeClass("on");			
		$(this).addClass("on");
	});						

});
</script>
<%
		SQL="SELECT COUNT(*) AS cnt FROM CP_contetsSub WHERE type='image' AND from_seq="& seq
		Set oRS=g_oDB.Execute(sql)
			subcnt=oRS(0)
		Call oRS.close()
		Set oRS = Nothing

		If subcnt>0 Then
			pagesize=4
			totpage=int((subcnt-1)/pagesize)+1
			blockpg=pagesize*(page-1)
			If page<1 Then
				page=1
			ElseIf page>totpage Then
				page=totpage
			End If
%>
							<span>관련 콘텐츠 보기</span>
							<% Call subConBtn3("getSubConList", page, totpage, 4) %>
							<ul class="box_photoData_screen clearfix" >
<%
		SQL="SELECT * FROM "&_
			" (SELECT ROW_NUMBER() OVER(ORDER BY orderNo ASC, seq DESC) AS ROWNUM, c.*"&_
			" FROM CP_contetsSub AS c WHERE type='image' AND from_seq="&seq&") AS list"&_
			" WHERE rownum BETWEEN "& (blockpg+1) &" AND "& (blockpg+pagesize)
		'Response.write SQL
		'Response.End
		Set oRS=g_oDB.Execute(sql)
			ii=0
			Do While Not (oRS.BOF Or oRS.EOF)
%>
								<li><img src="<%=Trim(oRS("path")) %>" style="width:132px; height:100px;" onClick="viewPhoto('<%=Trim(oRS("path")) %>');" /><span><%=Trim(oRS("title")) %></span></li>
<%
			ii=ii+1
			oRS.MoveNext
		Loop
		oRS.Close()
%>
								
<%					
		Else
%>
								<!--<li style="width:500px;"><span>데이터가 없습니다.</span></li>-->
<%

		End If 
%>
							</ul>
<% End If %>
<script>
$(document).ready(function(){
	var subcnt=<%=subcnt %>;
	if(subcnt==0){
		$("#subList<%=template %>").css("display", "none");
	}
});
</script>
<!--#include virtual='/inc/end.inc' -->