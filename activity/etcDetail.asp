<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getDetail"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->
<%
Dim content_seq:content_seq=util_nte(request("content_seq"), 0, "int")
Dim getup_seq:getup_seq=util_nte(request("getup_seq"), 0, "int")
Dim geteq:geteq=util_nte(request("geteq"), 0, "int")
Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim getsubeq:getsubeq=util_nte(request("getsubeq"), 0, "int")
Dim typeSeq:typeSeq=util_nte(request("typeSeq"), 3, "int")
Dim selSeq:selSeq=util_nte(request("selSeq"), 1, "int")

Dim tp_seq:tp_seq=util_nte(request("tp_seq"), 0, "int")
Dim tp_img_path:tp_img_path=util_nte(request("tp_img_path"), "", "string")
Dim tp_caption:tp_caption=util_nte(request("tp_caption"), "", "string")
Dim key_word:key_word=util_nte(request("key_word"), "", "string")
Dim tp_copyright:tp_copyright=util_nte(request("copyright"), "", "string")
Dim cateB:cateB=util_nte(Trim(request("cateB")), "", "string")
Dim cateS:cateS=util_nte(Trim(request("cateS")), "", "string")

'Response.write "content_seq : "&content_seq&"<br />"
'Response.write "getup_seq : "&getup_seq&"<br />"
'Response.write "geteq : "&geteq&"<br />"
'Response.write "seq : "&seq&"<br />"
'Response.write "getsubeq : "&getsubeq&"<br />"

Dim board, template, search, reply
Dim lnbTitle, subTitle


Dim SQL, oRS, dbt, wquery, orderBy, ii
Dim depth1_title, depth2_title, depth3_title, depth_seq, cp_title
Dim seqQuery
Dim cp_seq, depth1, depth2, depth3
Dim school, subject, title, coment, thumbnail, video, image, document, link, content, tag, orderNo, regDate, isDisplay, isNew, isDelete
Dim content_type
Dim up_seq, oRS2, cnt, cnt2, cnt_seq
Dim pagesize, page, totpage, blockpg
Dim school_title
Dim main_content
Dim comentSub
Dim iii, depth4
Dim tabTitle, tab0Sel:tab0Sel=False

page=util_nte(request("page"), 1, "int")
depth4=util_nte(Trim(request("depth4")), 0, "int")
Dim subcnt

If selSeq=depthSeqStudent Then
	sql = "SELECT * FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (typeSeq+1) &" AND up_seq="& seq
	If depth4>0 Then
		sql=sql &" AND seq="& depth4
	End If 
Else 
	sql = "SELECT * FROM CP_category WITH(NOLOCK) WHERE depth="&typeSeq&" AND seq="& seq
End If 
'If g_Mem.uid="kdmtdev" Then 
'	Response.write sql &"<br />"
'End If 
Set oRS=g_oDB.Execute(sql)
	If Not (oRS.BOF Or oRS.EOF) Then
		up_seq = oRS("up_seq")
		subTitle = Trim(oRS("title"))
		comentSub = Trim(oRS("coment"))
		board = oRS("board")
		template = oRS("template")
		search = oRS("search")
		reply = oRS("reply")
	End If
Call oRS.Close()
Set oRS = Nothing
'Response.write up_seq

If up_seq>0 Then 'title
	If selSeq=depthSeqStudent Then
		sql = "SELECT title FROM CP_category WITH(NOLOCK) WHERE depth="& typeSeq &" AND seq="& seq
	Else 
		sql = "SELECT title FROM CP_category WITH(NOLOCK) WHERE depth="&typeSeq-1&" AND seq="& up_seq
	End If 
'	If g_Mem.uid="kdmtdev" Then 
'		Response.write sql &"<br />"
'	End If 
	Set oRS=g_oDB.Execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			lnbTitle = Trim(oRS("title"))
		End If
	Call oRS.Close()
	Set oRS = Nothing
End If
%>
<%If seq > 0 Then ' 수정
	SQL="SELECT *, cp.cp_title AS cp_cp_title FROM CP_contents AS c WITH(NOLOCK)"&_
		" INNER JOIN CP_list AS cp WITH(NOLOCK) ON cp.cp_seq=c.cp_seq WHERE seq="& content_seq &" AND isDelete<>'Y'"
'	Response.write sql
	Set oRS=g_oDB.Execute(SQL)
	If Not(oRS.EOF Or oRS.BOF) Then 
'		seq=oRS("seq")
		cp_title=Trim(oRS("cp_cp_title"))
		cp_seq=oRS("cp_seq")
		depth1=oRS("depth1")
		depth2=oRS("depth2")
		depth3=oRS("depth3")
		school=oRS("school")
		If school="E" Then
			school_title="초등"
		ElseIf school="M" Then
			school_title="중등"
		ElseIf school="H" Then
			school_title="고등"
		Else
			school_title="전체"
		End If
		subject=oRS("subject")
		title=Trim(oRS("title"))
		coment=Trim(oRS("coment"))
		thumbnail=Trim(oRS("thumbnail"))
		video=Trim(oRS("video"))
		image=Trim(oRS("image"))
		document=Trim(oRS("document"))
		link=Trim(oRS("link"))
		content=Trim(oRS("content"))
		tag=Trim(oRS("tag"))
		regDate=Trim(oRS("regDate"))
		content_type=Trim(oRS("content_type"))
		If content_type="video" Then
			If video<>"" Then
				main_content=video
			End If
		ElseIf content_type="image" Then
			If image<>"" Then
				main_content=image
			End If
		ElseIf content_type="document" Then
			If document<>"" Then
				main_content=document
			End If
		ElseIf content_type="link" Then
			If link<>"" Then
				main_content=link
			End If
		End If
	End If
	Call oRS.Close()
	Set oRS = Nothing
End If
%>
<script type="text/javascript">
function goActivityMain(selSeq, upSeq, geteq, seq, getsubeq, pg, tSeq){
	var xUrl="/activity/";
	xUrl+="?selSeq="+ selSeq +"&getup_seq="+ upSeq +"&geteq="+ geteq +"&seq="+ seq +"&getsubeq="+ getsubeq;
	if (typeof(pg)!="undefined" && pg!=""){
		xUrl+="&page="+ pg;
	}
	if (typeof(tSeq)!="undefined" && tSeq!=""){
		xUrl+="&typeSeq="+ tSeq;
	}
	xUrl+="&cateB="+ encodeURIComponent("<%=cateB %>") +"&cateS="+ encodeURIComponent("<%=cateS %>");
	xUrl+="&depth4=<%=depth4 %>";

	location.href=xUrl;
}
function getReply(pg){
	if (typeof(pg)!="number") pg=1;
	var xUrl="getList_reply.asp?idx=<%=seq %>&page="+ pg;
	//alert(xUrl);
	$("#innerReply").load(xUrl);
}
function goDnSingle(path){
	//alert("http:://"+window.location.hostname+path);
	if(mem_o.gotoLogin()) return;
<% If chkIsCerti() Then %>
//	ifrProc.location.href="http://"+window.location.hostname+path;
//	var dnUrl="/down/download_file.asp?file="+ encodeURIComponent(path);
	var dnUrl=path;
	document.ifrProc.location.href=dnUrl;
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
	return;
<% End If %>
}
$(document).ready(function(){
	var reply=<%=reply %>

	if(reply==1){
		getReply();
	}

var getsubeq = <%=getsubeq %>;
		$(".education_list li a").click(function(){
			$(".education_list li a").removeClass("on");
			$(this).addClass("on");
			$(".education_list li:nth-child(n+1) a").css("border-right-width", "");
			$(".education_list_05").css("border-left-width","");
			$(".education_list li:nth-child(n+6) a").css("border-right-width", "");
			$(".education_list_010").css("border-left-width","");
			$(".education_list_15").css("border-left-width","");
			$(".education_list_20").css("border-left-width","");
			$(".education_list > li > a > span").css("background-color","");					
			$(".education_list > li > a > span").css("background-color","");	
			$(".education_list li:first-child a > span").css("background-color","#d8d8d8");	
			$(".education_list_06 > span").css("background-color","#d8d8d8");
			$(".education_list li a.bd_top").css("border-top-color","#d8d8d8");
			var activeTab=$(this).attr("rel");	
		});
		
		$(".education_list li:nth-child(n+1) a").click(function(){
			$(this).addClass("on");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		});	


		if(getsubeq==1){
			$(".education_list li:first-child a").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==2){
			$(".education_list_02").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==3){
			$(".education_list_03").css("border-right-width","0");
			$(".education_list_05").css("border-left-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==4){
			$(".education_list_04").css("border-right-width","0");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==5){
			$(".education_list li:first-child a > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==6){
			$(".education_list_06").css("border-right-width","0");
			$(".education_list_02 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==7){
			$(".education_list_07").css("border-right-width","0");
			$(".education_list_03 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==8){
			$(".education_list_08").css("border-right-width","0");
			$(".education_list_010").css("border-left-width","0");
			$(".education_list_04 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==9){
			$(".education_list_09").css("border-right-width","0");
			$(".education_list_05 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==10){
			$(".education_list_06 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==11){
			$(".education_list_011").css("border-right-width","0");
			$(".education_list_07 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==12){
			$(".education_list_012").css("border-right-width","0");
			$(".education_list_08 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==13){
			$(".education_list_013").css("border-right-width","0");
			$(".education_list_015").css("border-left-width","0");
			$(".education_list_09 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==14){
			$(".education_list_014").css("border-right-width","0");
			$(".education_list_010 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==15){
			$(".education_list_011 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==16){
			$(".education_list_016").css("border-right-width","0");
			$(".education_list_012 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==17){
			$(".education_list_017").css("border-right-width","0");
			$(".education_list_013 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==18){
			$(".education_list_018").css("border-right-width","0");
			$(".education_list_020").css("border-left-width","0");
			$(".education_list_014 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}else if(getsubeq==19){
			$(".education_list_019").css("border-right-width","0");
			$(".education_list_015 > span").css("background-color","#204687");
			$(".education_list li:nth-child(n+1) a.on.bd_top").css("border-top-color","#204687");
			$(".education_list li:nth-child(n+1) a.on > span").css("background-color","#204687");
		}


		$(".education_list li:first-child a").click(function(){
			$(this).addClass("on");
		});			
		$(".education_list_02").click(function(){
			$(this).addClass("on");
			$(".education_list li:first-child a").css("border-right-width","0");
		});		
		$(".education_list_03").click(function(){
			$(this).addClass("on");
			$(".education_list_02").css("border-right-width","0");
		});		
		$(".education_list_04").click(function(){
			$(this).addClass("on");
			$(".education_list_03").css("border-right-width","0");
			$(".education_list_05").css("border-left-width","0");
		});	
		$(".education_list.type02 .education_list_04").click(function(){
			$(this).addClass("on");
			$(".education_list_03").css("border-right-width","0");
		});		
		$(".education_list_05").click(function(){
			$(this).addClass("on");
			$(".education_list_04").css("border-right-width","0");
		});					
		$(".education_list_06").click(function(){
			$(this).addClass("on");
			$(".education_list li:first-child a > span").css("background-color","#204687");
		});			
		$(".education_list_07").click(function(){
			$(this).addClass("on");
			$(".education_list_06").css("border-right-width","0");
			$(".education_list_02 > span").css("background-color","#204687");
		});		
		$(".education_list_08").click(function(){
			$(this).addClass("on");
			$(".education_list_07").css("border-right-width","0");
			$(".education_list_03 > span").css("background-color","#204687");
		});		
		$(".education_list_09").click(function(){
			$(this).addClass("on");
			$(".education_list_08").css("border-right-width","0");
			$(".education_list_010").css("border-left-width","0");
			$(".education_list_04 > span").css("background-color","#204687");
		});			
		$(".education_list_010").click(function(){
			$(this).addClass("on");
			$(".education_list_09").css("border-right-width","0");
			$(".education_list_05 > span").css("background-color","#204687");
		});
		$(".education_list_011").click(function(){
			$(this).addClass("on");
			$(".education_list_06 > span").css("background-color","#204687");
		});			
		$(".education_list_012").click(function(){
			$(this).addClass("on");
			$(".education_list_011").css("border-right-width","0");
			$(".education_list_07 > span").css("background-color","#204687");
		});		
		$(".education_list_013").click(function(){
			$(this).addClass("on");
			$(".education_list_012").css("border-right-width","0");
			$(".education_list_08 > span").css("background-color","#204687");
		});		
		$(".education_list_014").click(function(){
			$(this).addClass("on");
			$(".education_list_013").css("border-right-width","0");
			$(".education_list_015").css("border-left-width","0");
			$(".education_list_09 > span").css("background-color","#204687");
		});			
		$(".education_list_015").click(function(){
			$(this).addClass("on");
			$(".education_list_014").css("border-right-width","0");
			$(".education_list_010 > span").css("background-color","#204687");
		});		
		$(".education_list_016").click(function(){
			$(this).addClass("on");
			$(".education_list_011 > span").css("background-color","#204687");
		});			
		$(".education_list_017").click(function(){
			$(this).addClass("on");
			$(".education_list_016").css("border-right-width","0");
			$(".education_list_012 > span").css("background-color","#204687");
		});		
		$(".education_list_018").click(function(){
			$(this).addClass("on");
			$(".education_list_017").css("border-right-width","0");
			$(".education_list_013 > span").css("background-color","#204687");
		});		
		$(".education_list_019").click(function(){
			$(this).addClass("on");
			$(".education_list_018").css("border-right-width","0");
			$(".education_list_020").css("border-left-width","0");
			$(".education_list_014 > span").css("background-color","#204687");
		});			
		$(".education_list_020").click(function(){
			$(this).addClass("on");
			$(".education_list_019").css("border-right-width","0");
			$(".education_list_015 > span").css("background-color","#204687");
		});		
});

function setTabFocus(num){
	$(".education_list li a").removeClass("on");
	if (num>0){
		$(".education_list_0"+ num).click();
	}else{
		$(".education_list li:first-child a").click();
	}
}
</script>
				<div class="inner">
<% If template=1 Then %> <!--포스터형 -->
<script type="text/javascript">
function getSubConList(pg, num){
	if (typeof(pg)!="number") pg=1;
	if (typeof(num)!="number") num=0;
	var xUrl="getSubContentList.asp?template=<%=template %>&num="+num+"&seq=<%=seq %>&page="+ pg;
	//alert(xUrl);
	$("#subList<%=template %>").load(xUrl);
}
function viewPhoto(path, title, ii){
	var len=$(".slide_thum li img").length;
	var fPage=$("#subList1 .box_table_num ul.clearfix li").find("strong").text();
	var lPage=$("#subList1 .box_table_num ul.clearfix li").length;
	for(var i=0; i<lPage; i++){
		if($("#subList1 .box_table_num ul.clearfix li:eq("+i+") a").text()=="Next"){
			lPage=i-2;
		}
	}

	//alert("len : "+len+"|ii : "+ii+"|fPage : "+fPage+"|lPage : "+lPage);

	if(fPage==lPage && ii==len){
		$(".arrow_right").attr("src", "/images/renew/sub/arrow_right_off.png");
	}else{
		$(".arrow_right").attr("src", "/images/renew/sub/arrow_right_on.png");
	}

	$(".slide_main").attr("src", path);
	$(".slide_main_info").empty();
	if(title!=""){
		$(".slide_main_info").html("<div id='triangle-up'></div>"+title);
	}
	//alert(path);
}
$(function(){
	/*education_list_Tab  start*/
	//$(".education_list li:first-child a").addClass("on");
		
	/*	slide_thum */
	$(".slide .slide_thum li:nth-child(n+1)").click(function(){;
		$(".slide .slide_thum li").removeClass("on");			
		$(this).addClass("on");
	});			
	$(".slide .slide_thum li:nth-child(n+6)").css("margin-top", "2px");		
	/*textarea */
		$(".textarea_placeholder").click(function(){
		$(".textarea_placeholder").css("display","none");
	});			
	/*popup*/
	$(".popup_close").click(function(){
		$(".creat_popup").css("display", "none");	
		$(".opacity").css("display", "none");	
	});	
	$(".popup_open").click(function(){
		$(".creat_popup").css("display", "block");	
		$(".opacity").css("display", "block");
	});

	getSubConList();
});
</script>
					<% If typeSeq=3 Then %>
					<div class="title_creativity">
						<span class="ml2"><%=lnbTitle %></span>
					</div>
<% Call tabHead(selSeq, typeSeq, seq, up_seq, depth4, getup_seq, geteq, getsubeq, coment, template, page, subTitle) %>
					<% End If %>
					<button type="button" class="creativity_list_btn" style="margin-top:6px;" onClick="goActivityMain('<%=selSeq%>', '<%=getup_seq %>', '<%=geteq %>', '<%=seq %>', '<%=getsubeq %>', '<%=page %>', '<%=typeSeq %>');"><p>목록보기</p></button>
					<div class="creativity_detail reply_wrap" style="margin-bottom:80px;">
						<div class="creativity_detail_title"><div><%=school_title %></div><p><%=title %></p><button type="button" onClick="goScrap(<%=content_seq %>);"><p>스크랩</p></button></div>
						 <ul class="detail_title_bot">
							<li class="info_data_group"><div>분류</div><p><%=subTitle %></p></li>
							<li class="info_data_origin" style="margin-left: 28px;"><div>출처</div><p><%=cp_title %></p></li>
						 </ul>
						 <div class="creativity_detail_slide">
							<ul class="creativity_detail_info">
<%
'content=Trim(content)
'content=Replace(content, "&lt;","<")
'content=Replace(content, "&gt;",">")
%>
								<li><%=content %></li>
							</ul>
							<div class="popup_out">
							<% If thumbnail<>"" Then %>
								<img src="<%=thumbnail %>" />
							<% Else %>
								<img src="/images/renew/noimage.gif" />
							<% End If %>
							<img src="/images/renew/sub/icon_zoom_pop.jpg" class="popup_open"/></div>
							<div class="slide" id="subList<%=template %>">
							</div>
						</div>
						<div id="innerReply"></div>

					<div class="creat_popup" style="display:none;">
						<div class="creat_popup_top">
							<div><%=school_title %></div>
							<p><%=title %></p>
							<button type="button" class="popup_close"><p style="margin-top:-2px">닫기</p></button>
						</div>
						<% If image<>"" Then %>
							<img src="<%=image %>" />
						<% Else %>
							<img src="/images/renew/noimage.gif" />
						<% End If %>
						<button type="button" class="popup_close"><p style="margin-top: -2px;">닫기</p></button>
					</div>			
					<div class="opacity" style="display:none;"></div>	
							</div>
						</div>		
					</div>
<% ElseIf template=2 Then %> <!--동영상 -->
<script type="text/javascript">
function innerVideo(){
	var content_type = "<%=content_type %>";
	var video = "<%=video %>";
	if(content_type=="video" && video!=""){
		var xUrl="preView.asp?files="+encodeURIComponent('<%=video %>');
		//alert(xUrl);
		$("#innerVideo").load(xUrl);	
	}	
}
function getSubConList(pg){
	if (typeof(pg)!="number") pg=1;
	var xUrl="getSubContentList.asp?template=<%=template %>&seq=<%=seq %>&page="+ pg;
	//alert(xUrl);
	$("#subList<%=template %>").load(xUrl);
}
function viewVideo(path){
	$(".creative_photoData").attr("src", path);
	var xUrl="preView.asp?files="+encodeURIComponent(path);
	//alert(xUrl);
	$("#innerVideo").empty();
	$("#innerVideo").load(xUrl)
}
$(document).ready(function(){
	innerVideo();
	getSubConList();
});
</script>
					<div class="title_creativity">
						<span class="ml2"><%=lnbTitle %></span>
					</div>
<% Call tabHead(selSeq, typeSeq, seq, up_seq, depth4, getup_seq, geteq, getsubeq, coment, template, page, subTitle) %>	
					<button type="button" class="creativity_list_btn" style="margin-top:6px;" onClick="goActivityMain('<%=selSeq%>', '<%=getup_seq %>', '<%=geteq %>', '<%=seq %>', '<%=getsubeq %>', '<%=page %>', '<%=typeSeq %>');"><p>목록보기</p></button>
					<div class="creativity_detail" style="margin-bottom:80px;">
						<div class="creativity_detail_title"><div>전체</div><p><%=title %></p></div>
						<ul class="detail_title_bot">
							<li class="info_data_group"><div>분류</div><p><%=subTitle %></p></li>
							<li class="info_data_origin" style="margin-left: 28px;"><div>출처</div><p><%=cp_title %></p></li>
							<li style="float: right;padding:10px;"><button type="button" onClick="goScrap(<%=content_seq %>);"><p>스크랩</p></button></li>
						</ul>
<% If (content_type="video" Or content_type="link") And document<>"" Then ' 동영상콘텐츠에 파일다운로드... %>
					<ul class="detail_title_bot renew" style="border-top:0;">
						<li>
							<span class="first" style="width:60px;display:inline-block;font-weight:600;color:#98753f;">첨부파일</span><span>｜</span><span class="file" style="cursor:pointer;text-decoration:underline;color:#0073db;" onClick="goDnSingle('<%=document %>');"><%=Mid(document, InStrRev(document, "/")+1) %></span> 
						</li>
					</ul>
<% End If %>
						<div class="creativity_detail_video">
						<% If content_type="video" Then %>
							<div id="innerVideo" style="text-align:center;"></div>
						<% ElseIf content_type="link" Then %>
							<div id="innerVideo" style="text-align:center;"><%=link %></div>
						<% End If %>
							 <div class="video_info"><%=content %></div>
						</div>
						<div class="box_photoData_screen_wrap" id="subList<%=template %>">						
						</div>	
						<div id="innerReply"></div>
					</div>
<%	' 동영상 로그 쌓기는 여기서...
	If content_seq>0 And (content_type="video" Or content_type="link") Then %>
		<input type="hidden" name="waLog" id="waCateId" value="DCactivity<%=selSeq %>" />
		<input type="hidden" name="waLog" id="waEventId" value="<%=content_seq %>" />
<%	End If %>

<% ElseIf template=3 Then %> <!--관련 사진 앨범 -->
<script type="text/javascript">
function getSubConList(pg){
	if (typeof(pg)!="number") pg=1;
	var xUrl="getSubContentList.asp?template=<%=template %>&seq=<%=seq %>&page="+ pg;
	//alert(xUrl);
	$("#subList<%=template %>").load(xUrl);
}
function viewPhoto(path){
	$(".creative_photoData").attr("src", path);
	//alert(path);
}
$(document).ready(function(){
	getSubConList();
});
</script>
	<% If tp_seq>0 And tp_img_path<>"" Then %>
		<% tp_img_path=Replace(tp_img_path, "_thumb", "_galaxy") %>
					<div class="title_creativity" style="margin-bottom:35px;">
						<span class="ml2"><% If tp_seq>0 And tp_img_path<>"" Then %>사진 자료실<% End If %></span>
					</div>
					<div class="education_data_title"><%=subTitle %></div>								
					<button type="button" class="creativity_list_btn" style="margin-top:6px;" onClick="goActivityMain('<%=selSeq%>', '<%=getup_seq %>', '<%=geteq %>', '<%=seq %>', '<%=getsubeq %>', '<%=page %>', '<%=typeSeq %>');"><p>목록보기</p></button>
					<div class="creativity_detail" style="margin-bottom:80px;">
						<div class="creativity_detail_title"><p><%=tp_caption %></p></div>
						 <ul class="detail_title_bot">
							<li class="info_data_origin"><div>출처</div><p><%=tp_copyright %></p></li>
							<li style="float: right;padding:10px;">
								<button type="button" onClick="goDnMedia(<%=tp_seq %>);" style="margin-left:5px;"><p>다운로드</p></button>
								<button type="button" onClick="goScrap('<%=tp_seq %>');"><p>스크랩</p></button>
							</li>
						 </ul>
							<img src="<%=tp_img_path %>" class="creative_photoData"/>
							<% If key_word<>"" Then %>
							<span style="font-size:12px;"><%=key_word %></span>
							<% End If %>
					</div>
	<% Else %>
					<div class="title_creativity" style="margin-bottom:35px;">
						<span class="ml2"><%=lnbTitle %></span>
					</div>
					<div class="education_data_title"><%=subTitle %></div>								
					<button type="button" class="creativity_list_btn" style="margin-top:6px;" onClick="goActivityMain('<%=selSeq%>', '<%=getup_seq %>', '<%=geteq %>', '<%=seq %>', '<%=getsubeq %>', '<%=page %>', '<%=typeSeq %>');"><p>목록보기</p></button>
					<div class="creativity_detail">
						<div class="creativity_detail_title"><p><%=title %></p></div>
						 <ul class="detail_title_bot">
							<li class="info_data_origin"><div>출처</div><p><%=cp_title %></p></li>
							<li style="float: right;padding:10px;">
							<button type="button" ><p>다운로드</p></button>
							<button type="button" onClick="goScrap(<%=content_seq %>);"><p>스크랩</p></button></li>
						 </ul>
						 <% 'If content_type=<> %>
							<img src="<%=image %>" class="creative_photoData"/>
						 <% 'End If %>
						<div class="box_photoData_screen_wrap" id="subList<%=template %>">						
						</div>						 
					</div>
	<% End If %>
<% ElseIf template=4 Then %> <!--HTML 게시판 -->
<% If selSeq=depthSeqStudent Then %>
					<div class="title_creativity">
						<span class="ml2"><%=lnbTitle %></span>
					</div>
<%
If up_seq>0 Then 'title
	Call tabHead(selSeq, typeSeq, seq, up_seq, depth4, getup_seq, geteq, getsubeq, coment, template, page, subTitle)
End If
%>

<% Else %>
					<div class="title_freesem type02">
						<span class="ml2"><%=subTitle %></span>
						<span><%=comentSub %></span>
					</div>
<% End If %>
<%
'------------------------------------------------------------------------------------------
Sub tabHead(FselSeq, FtypeSeq, Fseq, Fup_seq, Fdepth4, Fgetup_seq, Fgeteq, Fgetsubeq, Fcoment, Ftemplate, Fpage, FsubTitle) 
%>
					<ul class="education_list">
<%
	Dim Fsql, FoRS, Fcnt, Fii, Fcnt_seq, FtabTitle, Ftab0Sel, FtabSel, FtabHref, cellLimit
	Ftab0Sel=False:FtabSel=False:cellLimit=5

	If FselSeq=depthSeqStudent Then
		Fsql = "SELECT COUNT(*) AS cnt FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (FtypeSeq+1) &" AND up_seq="& Fseq
	Else 
		Fsql = "SELECT COUNT(*) AS cnt FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& FtypeSeq &" AND up_seq="& Fup_seq
	End If 
'	Response.write sql
	Set FoRS=g_oDB.Execute(Fsql)
		Fcnt=FoRS(0)
	Call FoRS.close()
	Set FoRS = Nothing
	If Fcnt>0 Then
		If FselSeq=depthSeqStudent Then
			Fsql="SELECT title, seq"&_
				" FROM CP_category AS cate WITH(NOLOCK) WHERE isDisplay=1 AND depth="& (FtypeSeq+1) &" AND up_seq="& Fseq
		Else 
			Fsql="SELECT title, seq"&_
				" FROM CP_category WITH(NOLOCK) WHERE isDisplay=1 AND depth="& FtypeSeq &" AND up_seq="& Fup_seq
		End If 
		Fsql=Fsql &" ORDER BY orderNo, regDate"
		Set FoRS=g_oDB.Execute(Fsql)
		Fii=0
		Do While Not (FoRS.BOF Or FoRS.EOF)
			Fcnt_seq=FoRS("seq")
			If Fdepth4=0 And Fii=0 And FselSeq=depthSeqStudent Then
				Fdepth4=Fcnt_seq
			End If 
			If Fdepth4=Fcnt_seq Then
				FtabTitle=Trim(FoRS("title"))
			Else
				FtabTitle=FsubTitle
			End If 
			If FselSeq=depthSeqStudent Then
				If Fdepth4=Fcnt_seq Then
					FtabSel=True
				End If 
				FtabHref="/activity/?selSeq="& FselSeq &"&typeSeq="& FtypeSeq &"&getup_seq="& Fgetup_seq &"&geteq="& Fgeteq &"&seq="& Fseq &"&getsubeq="& Fgetsubeq &"&depth4="& Fcnt_seq
			Else 
				If Fgetsubeq=Fii Then
					FtabSel=True
				End If 
				FtabHref="javascript:goActivityMain('"& FselSeq &"', '"& Fgetup_seq &"', '"& Fgeteq &"', '"& Fcnt_seq &"', '"& Fii &"', '', '"& FtypeSeq &"');"
			End If 

			If Fii=0 Then ' 첫번째 탭... %>
						<li><a name="tabTitle" href="<%=FtabHref %>" class="<% If Fii<cellLimit Then %>bd_top<% End if %><% If FtabSel Then %> on<% End If %>" onMouseOver="setTitle(this);"><%=Trim(FoRS("title")) %><span></span></a></li>
<%				If Fdepth4=Fcnt_seq Then 
					Ftab0Sel=True %>
<script>
setTabFocus(0);
</script>
<%				End If
			Else %>
						<li><a name="tabTitle" href="<%=FtabHref %>" class="education_list_0<%=Fii+1 %><% If Fii<cellLimit Then %> bd_top<% End if %><% If FtabSel Then %> on<% End If %>" onMouseOver="setTitle(this);"><%=Trim(FoRS("title")) %><span></span></a></li>
<%				If Not Ftab0Sel Then 
					If FselSeq=depthSeqStudent And Fdepth4=Fcnt_seq Then %>
<script>
setTabFocus(<%=(Fii+1) %>);
</script>
<%					End If
				End If
			End If

			Fii=Fii+1
			FtabSel=False 
			FoRS.movenext
		Loop
		Call FoRS.close()
		Set FoRS = Nothing

		For Fii=Fii To (-(int(-(Fcnt/cellLimit)))-1)*cellLimit+(cellLimit-1) 
%>
						<li><a href="#" class="education_list_0<%=(Fii+1) %><% If Fii<cellLimit Then %> bd_top<% End if %>" style="cursor:default;"><span></span></a></li>
<%
		Next
	End If 
%>
					</ul>
<%	If FselSeq=depthSeqStudent And Ftemplate=4 Then %>
					<div class="education_data_title"><%=FtabTitle %><span style="font-size:13px;color:#747474;margin-left:15px;display: inline-block;"><%=Fcoment %></span></div>
<%	ElseIf (Ftemplate=1 And FtypeSeq=3) Or Ftemplate=2 Then %>
					<div class="education_data_title"><%=FtabTitle %></div>					
<%
	End If 
End Sub '------------------------------------------------------------------------------------------
%>
					<!--
					<div class="education_data_title"><%=subTitle %></div>
					-->
<% If selSeq=depthSeqStudent Then %>
					<button type="button" class="customer_list_btn" style="margin-top:6px;" onClick="window.history.back();"><p>목록보기</p></button>
<% Else %>
					<button type="button" class="customer_list_btn" style="margin-top:6px;" onClick="goActivityMain('<%=selSeq%>', '<%=getup_seq %>', '<%=geteq %>', '<%=seq %>', '<%=getsubeq %>', '<%=page %>', '<%=typeSeq %>');;"><p>목록보기</p></button>
<% End If %>
					<div class="customer_detail" style="clear:both;margin-bottom:80px;">
						<div class="customer_detail_title type02"><p><%=title %></p><span><%'=Left(regDate, 10)%></span></div>
						<ul class="add_file type04" style="border-top:none;">
						<% If link<>"" Then %>
							<li>URL</li>
						<% Else %>
							<li>첨부파일</li>
						<% End If %>
							<li>
								<% If document<>"" Then %>
									<p><a href="javascript:goDnSingle('<%=document %>');"><%=Mid(document, InStrRev(document,"/")+1) %></a></p>
								<% End If %>
								<% If video<>"" Then %>
									<p><a href="javascript:goDnSingle('<%=video %>');"><%=Mid(video, InStrRev(video,"/")+1) %></a></p>
								<% End If %>
								<% If image<>"" Then %>
									<p><a href="javascript:goDnSingle('<%=image %>');"><%=Mid(image, InStrRev(image,"/")+1) %></a></p>
								<% End If %>
								<% If link<>"" Then %>
									<p><a href="<%=link %>" target="_blank"><%=link %></a></p>
									</li><li style="float:right;margin-top:-50px;"><button type="button" onClick="goScrap(<%=content_seq %>);" class="create_scrap"><p>스크랩</p></button>
								<% End If %>
							</li>
						</ul>
						<div class="customer_announce">
							<%=content %>
						</div>
						<!--
						<button type="button" class="creativity_list_btn" style="margin-top:6px;" onClick="showList();"><p>목록보기</p></button>
						-->
						<div id="innerReply" style="border-top:1px solid #dcdcdc;"></div>					 
					</div>

<% ElseIf template=5 Then %> <!--HTML 하드코딩 -->
							<%=content %>
<% Else %> <!--사용안함 -->

<% End If %>
				</div>
<!--#include virtual='/inc/end.inc' -->