<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="support_CD"

Dim sch:sch=util_nte(Trim(request("sch")), "M", "string")
Dim curri:curri=util_nte(Trim(request("curri")), "15", "string") ' 180108 15개정 추가...
If curri<>"15" Then
	curri="09"
End If
%>
<!--#include virtual='/inc/start.inc' -->
<!--#include virtual='/inc/topmenu_renewal.inc' -->
<script>
var arr09=new Array();
var arr08=new Array();
var arr15=new Array();
var curri="<%=curri %>";

function showTabTitle(tab, sch){// 탭메뉴 제목...
	var tabs=$("table td[name=title_"+ tab +"]");
	tabs.removeClass("on");
	$("#title_"+ tab + sch).addClass("on");
	$(".tbl_smart_book").hide(0, function(){$(this).show()}); // 잔상이 남아서 강제 redraw...

	arr09.length=0;
	arr08.length=0;
	arr15.length=0;
	var xUrl="getList_CD.asp?sch="+ sch +"&curri="+ curri;
	$("#innerBody").load(xUrl);
}
function showCD(curSch, newCurri){
	document.location.href="CD.asp?sch="+ curSch +"&curri="+ newCurri;
}
function dnBigFile(curri, idx, files){
	if(mem_o.gotoLogin()) return;
<% If chkIsCerti() Then %>
	var arr=eval("arr"+ curri); 
	var files=arr[idx][files];
	if (files!="") D.location.href=files;
<% Else %>
	menu_o.openAlertPop(null, null, null, 11);
<% End If %>
}
function printCD(curri){
	var arr=eval("arr"+ curri); // sbj, title, files1,2,3
	var icon="btn_model";
	if (curri=="08") icon="icon_cd_green";
	var tgt, tmp;
	//var typeArr = ["국어 ① (이)","국어 ② (이)","국어 ③ (이)","국어 ④ (이)","국어 ⑤ (이)","국어 ⑥ (이)"]
	//alert(arr.length);
	for (var i=0; i<arr.length; i++){
		tmp='<li>';
		tmp+='<div></div><a>'+ arr[i][1] +'</a></div>';
//		for (var j=2; j<arr[i].length; j++){
		for (var j=2; j<5; j++){
			if (arr[i][j]!=""){
				tmp+='<button type="button" class="'+ icon +'0'+ (j-1) +'" onClick="dnBigFile(\''+ curri +'\', '+ i +', '+ j +');">'+ arr[i][5] +' '+ (j-1) +'</button>&nbsp;';
			}
		}
		tmp+='</li>';
//		if(arr[i][0]=="MK" && i>5 && i<13){//중등 국어 (이) 오른쪽 처리
//			tgt=$("#"+ arr[i][0] + curri+"_02");
//		}else{
			tgt=$("#"+ arr[i][0] + curri);
//		}
		tgt.html(tgt.html() + tmp);
	}
}
$(document).ready(function(){
	/* CD down Tab */
	
	$(".CD_down_subject_wrap .CD_down_01").click(function(){
		$(".CD_down_subject_wrap div").removeClass("on");
		$(this).addClass("on");
	});

	$(".CD_down_subject_wrap .CD_down_02").click(function(){
		$(".CD_down_subject_wrap div").removeClass("on");
		$(this).addClass("on");
	});

	$(".CD_down_subject_wrap .CD_down_03").click(function(){
		$(".CD_down_subject_wrap div").removeClass("on");
		$(this).addClass("on");
	});

	showTabTitle("CD", '<%=sch %>');
/*
	$(".revision_tab ul li.tab_btn_2015 img.off_btn").click(function(){
		$('.revision_tab ul li.tab_btn_2015 img.on_btn').addClass("on");
		$('.revision_tab ul li.tab_btn_2015 img.off_btn').removeClass("on");
		$('.revision_tab ul li.tab_btn_2009 img.on_btn').removeClass("on");
		$('.revision_tab ul li.tab_btn_2009 img.off_btn').addClass("on");
	});

	$(".revision_tab ul li.tab_btn_2009 img.off_btn").click(function(){
		$('.revision_tab ul li.tab_btn_2009 img.on_btn').addClass("on");
		$('.revision_tab ul li.tab_btn_2009 img.off_btn').removeClass("on");
		$('.revision_tab ul li.tab_btn_2015 img.off_btn').addClass("on");
		$('.revision_tab ul li.tab_btn_2015 img.on_btn').removeClass("on");
	});*/
});
</script>

	<div class="sub_wrap">
		<div class="CD_down_titile"><span>교사용CD/DVD 다운로드&nbsp;<img src="/images/renew/sub/icon_smart_2015.png" style=" margin-bottom:2.5px;"/><img src="/images/renew/sub/icon_smart_2009.png" style=" margin:0 4px 2.5px 8px;"/></span>
		<button onClick="location.href='http://textbook.doosandonga.com/popup/cyberbookpop.jsp'" style="display:none;"><p>07개정 교사용CD 다운로드</p></button></div>
		<div class="CD_down_wrap">
				<div class="CD_down_subject_wrap">
					<div name="title_CD" class="CD_down_01" id="title_CDE" onClick="showTabTitle('CD', 'E');"><p>초등</p></div>
					<div name="title_CD" class="CD_down_02" id="title_CDM" onClick="showTabTitle('CD', 'M');"><p>중등</p></div>
					<div name="title_CD" class="CD_down_03" id="title_CDH" onClick="showTabTitle('CD', 'H');"><p>고등</p></div>
				</div>
				<div class="con" id="innerBody" style="padding-top:0;">
					<!--div class="revision_tab">
						<ul>
							<li class="tab_btn_2015">
								<img src="/images/renew/sub/icon_btn_15_on.png" class="on_btn"/>
								<img src="/images/renew/sub/icon_btn_15_off.png" class="off_btn on"/>
							</li>
							<li class="tab_btn_2009">
								<img src="/images/renew/sub/icon_btn_09_on.png" class="on_btn on"/>
								<img src="/images/renew/sub/icon_btn_09_off.png" class="off_btn" />
							</li>
							<li></li>
						</ul>
					</div-->
				</div>
		</div>
	</div>
</div>

<!--#include virtual='/inc/footer_renewal.inc' -->
<!--#include virtual='/inc/end.inc' -->
