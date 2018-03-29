<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_index"
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual='/inc/topmenu_renewal.inc' -->
<%
Dim selSeq:selSeq=util_nte(request("selSeq"), 1, "int") '1창체, 2자유학기제, depthSeqStudent:학생참여형 수업
g_pageDiv=g_pageDiv&selSeq

Dim typeSeq:typeSeq=util_nte(request("typeSeq"), 3, "int") '2depth사용, 3depth사용
Dim getup_seq:getup_seq=util_nte(request("getup_seq"), 0, "int")
Dim geteq:geteq=util_nte(request("geteq"), 0, "int")
Dim seq:seq=util_nte(request("seq"), 0, "int")
Dim getsubeq:getsubeq=util_nte(request("getsubeq"), 0, "int")
Dim content_seq:content_seq=util_nte(request("content_seq"), 0, "int")
Dim startCate, sql, oRS
Dim startType

Dim tp_seq:tp_seq=util_nte(request("tp_seq"), 0, "int")
Dim tp_img_path:tp_img_path=util_nte(request("tp_img_path"), "", "string")
Dim tp_caption:tp_caption=util_nte(request("tp_caption"), "", "string")
Dim tp_key_word:tp_key_word=util_nte(request("key_word"), "", "string")
Dim tp_copyright:tp_copyright=util_nte(request("copyright"), "", "string")

Dim page:page=util_nte(request("page"), 1, "int")
Dim cateB:cateB=util_nte(Trim(request("cateB")), "", "string")
Dim cateS:cateS=util_nte(Trim(request("cateS")), "", "string")

Dim depth4:depth4=util_nte(request("depth4"), 0, "int")
Dim rndCode:rndCode=util_unic() ' 20180327

'Response.write "typeSeq : "&typeSeq&"<br />"
'Response.write "getup_seq : "&getup_seq&"<br />"
'Response.write "geteq : "&geteq&"<br />"
'Response.write "seq : "&seq&"<br />"
'Response.write "getsubeq : "&getsubeq&"<br />"

If getup_seq=0 Then
	sql = "SELECT top 1 seq FROM CP_category WITH(NOLOCK) WHERE depth=2 AND up_seq="&selSeq&" AND isDisplay=1 ORDER BY orderNo, seq"
	'Response.write sql
	Set oRS=g_oDB.Execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
			startCate = oRS("seq")
		Else
			startCate=0
		End If
	Call oRS.Close()
	Set oRS = Nothing

	getup_seq=startCate

	sql = "SELECT * FROM CP_category WITH(NOLOCK) WHERE depth=3 AND up_seq="&startCate&" AND isDisplay=1 ORDER BY orderNo, seq"
'	Response.write sql
	Set oRS=g_oDB.Execute(sql)
		If Not (oRS.BOF Or oRS.EOF) Then
		startType=""
		Do While Not (oRS.BOF Or oRS.EOF)
			If startType<>"" Then
				startType=startType&","&oRS("seq")
			Else
				startType=oRS("seq")
			End If
			oRS.movenext
		Loop
		Else
			startType="0"
		End If
	Call oRS.Close()
	Set oRS = Nothing
End If
%>
<input type="hidden" id="cateB" value="<%=cateB %>" />
<input type="hidden" id="cateS" value="<%=cateS %>" />
<script type="text/javascript">
var getseq;
var getup_seq;
var geteq;
var getsubeq;
var typeSeq=<%=typeSeq %>;
var selSeq=<%=selSeq %>;

var tp_seq=<%=tp_seq %>;
var tp_img_pat="<%=tp_img_path %>";
var tp_caption="<%=tp_caption %>";
var key_word="<%=tp_key_word %>";
var tp_copyright="<%=tp_copyright %>";

function goList(pg){
	if (typeof(pg)!="number") pg=1;
	if (typeof(coment)=="undefined") coment="";
	if($(".list_accordion_sub li a").hasClass("on")){
		typeSeq=3
	}else{
		typeSeq=2
	}
	var xUrl="getList.asp?seq="+getseq+"&getup_seq="+getup_seq+"&geteq="+geteq+"&getsubeq="+getsubeq+"&typeSeq="+typeSeq+"&selSeq="+selSeq+"&page="+ pg;
	xUrl+="&depth4=<%=depth4 %>&rnd=<%=rndCode %>a";
//	console.log(xUrl);

	if (document.getElementById("school")) xUrl+="&school="+ $("#school").val();
	if ($.trim($("#content_title").val())!="") xUrl+="&content_title="+ $.trim($("#content_title").val());
	if ($.trim($("#reqQnaTab").val())!="") xUrl+="&reqQnaTab="+ $.trim($("#reqQnaTab").val());
	if ($.trim($("#orderBy1").val())!="") xUrl+="&orderBy1="+ $.trim($("#orderBy1").val());
	xUrl=getCateBS(xUrl);
	//$(".sub_right").load(encodeURI(xUrl));
	//alert(encodeURI(xUrl));
	$("#etcList").load(encodeURI(xUrl));	
	//$("#divPageNavi").load(encodeURI(xUrl +"&mode=showPaging"));
}
function orderBy1(){
	var orderBy1=$("#orderBy1").val();
	if(orderBy1=="DESC" || orderBy1==""){
		$("#orderBy1").val("ASC")
	}else if(orderBy1=="ASC"){
		$("#orderBy1").val("DESC")
	}
	
	goList(1);
}
function showQnATab(selSeq, typeSeq, getup_seq, geteq, coment){
	$("#reqQnaTab").val(coment);

	goList(1);
}
function srchList(){
	//alert(school);
	//if ($.trim($("#content_title").val())==""){
	//	alert("검색어를 입력해 주세요.");
	//	return;
	//}
	goList(1);
}
function chkLoop(chkname){
	var chks="";
	$('.'+chkname).each(function(){
		if($(this).is(':checked') && $(this).css('visibility') != 'hidden' && chks.indexOf($(this).val()) < 0){
			if (chks!="") chks += ",";
			chks += $(this).val();
		}
	});	
	return chks;
}
function checkAll(obj){
	$("input[name=chkSingle]").attr("checked", obj.checked);
	$("input[name=chkAll]").attr("checked", obj.checked);
}
function chkSingle(obj){
	if (!obj.checked) $("input[name=chkAll]").attr("checked", obj.checked);
}
function gotoScrap(){
	var chks="";
	$("input[name=chkSingle]").each(function(){
		if($(this).is(':checked')){
			if (chks!="") chks+=",";
			chks+=$(this).val();
		}
	});
	goScrap(chks);
}


function setEtcLi(selSeq, seq, eq, type){
	videoOff();

	var tmp="";
	var typeSeq = <%=typeSeq %>;
	var selSeq = <%=selSeq %>;
	if (typeof(type)=="undefined") type="";
	var xUrl="getLiList.asp?depth=2&up_seq=<%=selSeq %>&rnd=<%=rndCode %>b";
	var getData;
	var firstLi;
	if(seq>0){
		$.get(xUrl, function(data) {
			getData = eval(data);
			if (getData.length>0){
				for (var i=0; i<getData.length; i++){
					//alert(getData[i][3]);
					if(getData[i][3]=="0"){
						tmp+="<li>";
						//tmp+="<a href=\"javascript:setEtcLi("+ getData[i][0] +", "+ i +", '"+getData[i][3]+"');\" id='lnbTitle"+i+"' class=\"title accordion_first";
						tmp+="<a href=\"/activity/?selSeq="+selSeq+"&typeSeq=2&getup_seq="+ getData[i][0] +"&geteq="+ i +"\" id='lnbTitle"+i+"' class=\"title accordion_first";
						if (i==eq){ 
							tmp+=" on";
						}
						tmp+="\">"+ getData[i][1] +"</a>";
						tmp+="</li>";
					}else{
						tmp+="<li>";
						if(i==0){
							//tmp+="<a href=\"javascript:setEtcLi("+ getData[i][0] +", "+ i +", '"+getData[i][3]+"');\" id='lnbTitle"+i+"' class=\"title accordion_first03";
							tmp+="<a href=\"/activity/?selSeq="+selSeq+"&typeSeq=3&getup_seq="+ getData[i][0] +"&geteq="+ i +"\" id='lnbTitle"+i+"' class=\"title accordion_first03";
						}else{
							//tmp+="<a href=\"javascript:setEtcLi("+ getData[i][0] +", "+ i +", '"+getData[i][3]+"');\" id='lnbTitle"+i+"' class=\"title accordion_03";
							tmp+="<a href=\"/activity/?selSeq="+selSeq+"&typeSeq=3&getup_seq="+ getData[i][0] +"&geteq="+ i +"\" id='lnbTitle"+i+"' class=\"title accordion_03";
						}
						if (i==eq){ 
							tmp+=" on";
						}
						tmp+="\">"+ getData[i][1] +"</a>";
						tmp+="<div class=\"con\">";
						tmp+="<ul class=\"list_accordion_sub\" name='liItbDnSbj' id='liItbDnSbj"+ i +"' style='display:none;'>";
						tmp+="</ul>";
						tmp+="</div>";
						tmp+="</li>";
					}
				}
			}

			$("#leftListLi").html(tmp);
			if(type=="0"){
				setEtcSubLiType(selSeq, seq, eq);
				typeSeq=2;
			}else{
				//setEtcSubLi(seq, eq);
				typeSeq=3;
			}
			
			
		});
	}
	//alert(firstLi);
	
}

function setEtcSubLi(selSeq, up_seq, eq, seq, subeq, page){
	videoOff();

	if (typeof(subeq)!="number") subeq=0;
	if (typeof(seq)!="number") seq=0;
	if (typeof(page)!="number") page=1;
	var tmp="";
	var xUrl="getLiList.asp?depth=3&up_seq="+up_seq +"&rnd=<%=rndCode %>c";
	var getData;
	if(up_seq>0){
		$.get(xUrl, function(data) {
			getData = eval(data);

			var list=$("ul [name=liItbDnSbj]");
			list.css("display", "none");
			//list.eq(eq).css("display", "");
			$("#liItbDnSbj"+eq).css("display", "");
			//var tt=numTitle; //arr[curItbIdx].length-1; // 배열 마지막에 title 존재...
			if (getData.length>0){
				for (var i=0; i<getData.length; i++){
					tmp+="<li><span></span>";
						//tmp+="<a href=\"javascript:setEtcSubLi("+ getData[i][2] +", "+ eq +", "+ getData[i][0] +", "+ i +");\" class=\"";
						tmp+="<a href=\"/activity/?selSeq="+selSeq+"&typeSeq="+typeSeq+"&getup_seq="+ getData[i][2] +"&geteq="+ eq +"&seq="+ getData[i][0] +"&getsubeq="+ i +"\" class=\"";
<% If selSeq=depthSeqStudent And geteq=0 Then %>
						if (i==<% If seq>0 Then %><%=getsubeq %><% Else %>eq<% End If %>){
							getRightList(selSeq, getData[i][2], eq, <% If seq>0 Then %><%=seq %><% Else %>getData[i][0]<% End If %>, <%=getsubeq %>, 3, page);
<% Else %>
						if (i==subeq){
							getRightList(selSeq, getData[i][2], eq, getData[i][0], i, 3, page);
<% End If %>
							tmp+=" on";							
							getup_seq=getData[i][2];
							geteq=eq;
							getseq=getData[i][0];
							getsubeq=i;
						}
						tmp+="\">"+ getData[i][1] +"</a>";
					tmp+="</li>";
				}
			}
			$("#liItbDnSbj"+eq).html(tmp);
			
		});
	}
}
function setEtcSubLiType(selSeq, up_seq, eq, seq, subeq, page){
	videoOff();

	if (typeof(subeq)!="number") subeq=0;
	if (typeof(seq)!="number") seq=0;
	if (typeof(page)!="number") page=1;
	var tmp="";
	var xUrl="getLiList.asp?mode=2depth&depth=2&up_seq="+up_seq +"&rnd=<%=rndCode %>d";
	var getData;
	if(up_seq>0){
		$.get(xUrl, function(data) {
			getData = eval(data);

			var list=$("ul [name=liItbDnSbj]");
			list.css("display", "none");
			$("#liItbDnSbj"+eq).css("display", "");
			//var tt=numTitle; //arr[curItbIdx].length-1; // 배열 마지막에 title 존재...
			if (getData.length>0){
				for (var i=0; i<getData.length; i++){
					tmp+="<li><span></span>";
						tmp+="<a href=\"/activity/?selSeq="+selSeq+"&typeSeq="+typeSeq+"&getup_seq="+ getData[i][2] +"&geteq="+ eq +"&seq="+ getData[i][0] +"&getsubeq="+ i +"\" class=\"";
						if (i==subeq){
							tmp+=" on";
							getRightList(selSeq, getData[i][2], eq, getData[i][0], i, 2, page);
							getup_seq=getData[i][2];
							geteq=eq;
							getseq=getData[i][0];
							getsubeq=i;
						}
						tmp+="\">"+ getData[i][1] +"</a>";
					tmp+="</li>";
				}
			}
			$("#liItbDnSbj"+eq).html(tmp);
			
		});
	}
}

function getRightList(selSeq, getup_seq, geteq, seq, getsubeq, typeSeq, page){
	if (typeof(subeq)!="number") subeq=0;
	if (typeof(seq)=="undefined") seq=0;
	if (typeof(page)!="number") page=1;

	if (document.getElementById("school")) xUrl+="&school="+ $("#school").val();
	if ($.trim($("#content_title").val())!="") xUrl+="&content_title="+ $.trim($("#content_title").val());
	if ($.trim($("#reqQnaTab").val())!="") xUrl+="&reqQnaTab="+ encodeURIComponent($.trim($("#reqQnaTab").val()));
	if ($.trim($("#orderBy1").val())!="") xUrl+="&orderBy1="+ $.trim($("#orderBy1").val());

	if(seq>0 || getup_seq>0){
		var xUrl="getList.asp?seq="+ seq+"&getup_seq="+getup_seq+"&geteq="+geteq+"&getsubeq="+getsubeq+"&typeSeq="+typeSeq+"&selSeq="+selSeq+"&page="+page;
		xUrl+="&depth4=<%=depth4 %>&rnd=<%=rndCode %>e";
//		console.log(xUrl);

		if (document.getElementById("school")) xUrl+="&school="+ $("#school").val();
		if ($.trim($("#content_title").val())!="") xUrl+="&content_title="+ $.trim($("#content_title").val());
		if ($.trim($("#reqQnaTab").val())!="") xUrl+="&reqQnaTab="+ encodeURIComponent($.trim($("#reqQnaTab").val()));
		if ($.trim($("#orderBy1").val())!="") xUrl+="&orderBy1="+ $.trim($("#orderBy1").val());
		xUrl=getCateBS(xUrl);
		//$("#etcDetail").empty();
		//$("#etcList").css("display","");
		$("#etcList").load(xUrl);
	}
}
function getCateBS(param){ // 지역선택 값...
	var cateB="<%=cateB %>", cateS="<%=cateS %>";	
	var tmp;
	if ($("#selCateAreaBig").length>0){
		tmp=$("#selCateAreaBig").val();
		if (cateB!=tmp && tmp!="undefined" && cateB!=tmp){
			cateB=tmp;
		}
		tmp=$("#selCateAreaSmall").val();
		if (cateS!=tmp && tmp!="undefined" && cateS!=tmp){
			cateS=tmp;
		}
	}else if ($("#selCateBig").length>0){
		tmp=$("#selCateBig").val();
		if (cateB!="" && tmp!="undefined" && cateB!=tmp){
			cateB=tmp;
		}
		tmp=$("#selCateSmall").val();
		if (cateS!="" && tmp!="undefined" && cateS!=tmp){
			cateS=tmp;
		}
	}
	if (cateB!=""){
		param+="&cateB="+ encodeURIComponent(cateB);
	}
	if (cateS!=""){
		param+="&cateS="+ encodeURIComponent(cateS);
	}
	return param;
}
function etcPhotoDetail(selSeq, getup_seq, geteq, seq, getsubeq, tp_seq, img_path, caption, key_word, copyright, page){
//	if(mem_o.gotoLogin()) return;
<% If g_Mem.uid<>"" Then %>
<% If chkIsCerti() Then %>
	if(tp_seq>0){
		if (typeof(page)!="number") page=1;
		var xUrl="activity_detail.asp";
		xUrl+="?selSeq="+selSeq+"&getup_seq="+getup_seq+"&geteq="+geteq+"&seq="+seq+"&getsubeq="+getsubeq+"&tp_seq="+tp_seq;
		xUrl+="&tp_img_path="+encodeURIComponent(img_path)+"&tp_caption="+encodeURIComponent(caption)+"&key_word="+encodeURIComponent(key_word)+"&copyright="+encodeURIComponent(copyright);
		xUrl+="&page="+page +"&depth4=<%=depth4 %>&rnd=<%=rndCode %>f";
		xUrl=getCateBS(xUrl);

		location.href=xUrl;
	}
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
	return;
<% End If %>
<% Else %>
	location.href="/sign/login.asp?retURL=%2Factivity%2F%3FselSeq%3D<%=selSeq %>"
<% End If %>
}

function etcDetail(selSeq, content_seq, getup_seq, geteq, seq, getsubeq, typeSeq, page){
//	if(mem_o.gotoLogin()) return;
<% If g_Mem.uid<>"" Then %>
<% If chkIsCerti() Then %>
	if (typeof(pg)!="number") pg=1;
	if(content_seq>0){
		var xUrl="etcDetail.asp?selSeq="+selSeq+"&content_seq="+content_seq+"&getup_seq="+getup_seq+"&geteq="+geteq+"&seq="+seq+"&getsubeq="+getsubeq+"&typeSeq="+typeSeq+"&page="+page+"&depth4=<%=depth4 %>&rnd=<%=rndCode %>g";
		//alert(xUrl);
		$("#etcList").css("display","none");
		$("#etcDetail").load(xUrl);	
	}
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
	return;
<% End If %>
<% Else %>
	location.href="/sign/login.asp?retURL=%2Factivity%2F%3FselSeq%3D<%=selSeq %>"
<% End If %>
}
function viewPath(idx, title, path, subSE_type){
if (typeof(subSE_type)!="number") subSE_type=-1;
<% If g_Mem.uid<>"" Then %>
<%	If chkIsCerti() Then %>
	$("#showDetail").css("display", "");
	$("#course1").css("display", "none");
	$(".box_char_top").css("display", "none");

	if(subSE_type!=-1){
		$("#TabTitle").text(arrTabs[subSE_type]+" > ");
	}
	$("#jobTitle").text(title);
	$("#btnJobScrap").attr("onClick", "goScrap("+ idx +");");
	$(".box_course_con").html('<img src="'+ path +'" />');
<%	Else %>
	menu_o.openAlertPop(null, null, null, 11);
	return;
<%	End If %>
<% Else %>
	location.href='/sign/login.asp?retURL=<%=urlEtc %>?etc=0';
<% End If %>
}
function showList(){
	videoOff();
	$("#etcDetail").empty();
	
	//$("#etcDetail").css("display","none");
	$("#etcList").css("display","");
}
function videoOff(){
	//alert($.browser.msie);
	//alert($.browser.version);
	if(($.browser.msie && $.browser.version<=10) || $.browser.version==11){
		try{
			$('embed')[0].pause();
			$("#innerVideo").css("display","none");
			$("#innerVideo").fadeOut("fast");
			$("#innerVideo").remove();
		}catch(e){}
	}
}
function goDetail(seq){
	var xUrl="getDetailActivity.asp?seq="+seq +"&rnd=<%=rndCode %>h";
	location.href=xUrl;
}
function setTitle(obj){
	try{
		obj.title=obj.innerText;
	}catch(e){}
}
$(document).ready(function(){
	var selSeq=<%=selSeq %>;
	var content_seq=<%=content_seq %>
	var typeSeq=<%=typeSeq %>;
	var tp_seq=<%=tp_seq %>;
	if(selSeq==1){
		$(".num4 a").addClass("on");
		$(".num5 a").removeClass("on");
	}else if(selSeq==2 || selSeq==<%=depthSeqStudent %>){
		$(".num4 a").removeClass("on");
		$(".num5 a").addClass("on");
	}
	
	setEtcLi(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, '<%=startType %>');

	if(content_seq>0){
		if(typeSeq==2){
			setTimeout("setEtcSubLiType(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, <%=page %>)",100);
		}else{
			setTimeout("setEtcSubLi(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, <%=page %>)",100);
		}
		setTimeout("etcDetail(<%=selSeq %>, <%=content_seq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, <%=typeSeq %>, <%=page %>)",300);
	}else{
		if(typeSeq==2){
			setTimeout("setEtcSubLiType(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, <%=page %>)",100);
		}else{
			setTimeout("setEtcSubLi(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, <%=page %>)",100);
		}
		//etcDetail();
	}

	if(tp_seq>0){
		setTimeout("setEtcSubLi(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>)",100);
		setTimeout("etcPhotoDetail(<%=selSeq %>, <%=getup_seq %>, <%=geteq %>, <%=seq %>, <%=getsubeq %>, '<%=tp_seq %>', '<%=tp_img_path %>', '<%=tp_caption %>', '<%=tp_key_word%>', '<%=tp_copyright%>', <%=page %>)",500);
	}

	//setTimeout("etcDetail(content_seq, getup_seq, geteq, seq, getsubeq, typeSeq, pg)",800);

	//setTimeout("setEtcSubLi(17, 4, 18, 0, 3, 1)",600);
	//setTimeout("etcDetail(72, 17, 4, 18, 0, 3)",800);
});
</script>
	<div class="sub_wrap">
		<div class="box_sub_con type05 clearfix">
			<div class="sub_left">
				<div id="slnb1" class="box_smart_sub">
					<ul id="leftListLi" class="list_accordion type02"></ul>
				</div>
				<!--<a href="/file/" target="_blank"><img src="../images/renew/sub/bn_library.png?time=<%=rndCode %>" /></a>-->
<!--#include virtual="/inc/inc_lnb_banner.asp"-->
			</div>
			<div class="sub_right" id="etcList">

			</div>
		</div>
	</div>
</div>
<!--#include file="inc_scrapFormNjs.asp"-->

<!--#include virtual='/inc/footer_renewal.inc' -->
<!--#include virtual='/inc/end.inc' -->

<!-- 확대보기 새창 -->
<!--#include virtual="/etc/inc_etc5_pop.asp"-->