<%@ CodePage=65001 Language="VBScript"%>
<%Option Explicit%>
<%
g_needDB=True
g_pageGrade=-100
g_pageDiv="activity_getList_reply"
%>
<script language="VBScript" runat="server" src="/inc/config.inc"></script>
<!--#include virtual='/inc/start.inc' -->

<%
Dim sql, oRS, ii, wquery, sortBy
Dim page, pagesize, initPage, totCnt, totpage
Dim idx, rp_seq, grp_num, userid, regDate, reply, is_delete, sub_rpCnt, isWriter, isSecret, secretUserId
Dim phTxt:phTxt="※ 성격에 맞지 않은 게시글이나 다른 사람의 권리를 침해하거나 명예를 훼손하는 게시물은  사전 동의없이 관리자가 임의로 삭제 가능합니다."

' 페이지에서 직접 삭제 가능한 관리자 id...
%>
<!--#include virtual="/customer/inc_renew_web_admin.asp"-->
<%
idx=util_nte(request("idx"), 0, "int")

page=util_nte(request("page"), 1, "int")
pagesize=20
initPage=(page-1)*pagesize

If idx>0 Then
	wquery=" content_seq="& idx &" AND is_delete='n'"

	sql="SELECT COUNT(*) FROM CP_reply WHERE"& wquery
'	Response.write sql
	Set oRS=g_oDB.Execute(sql)
		totCnt=oRS(0)
	Call oRS.close()
	totpage=int((totCnt-1)/pagesize)+1
%>
<% 'If g_Mem.uid<>"" Then %>
<form name="fmReply0" method="post">
<input type="hidden" name="mode" value="add" />
						<ul class="detail_comment" id="liRp0">
							<li>댓글 작성</li>
							<li>| <span style="font-weight:600;"><%=g_Mem.uid %></span></li>
							<li><label><input type="checkbox" name="isSecret" id="isSecret" value="Y" />비밀 댓글</label></li>
							<li style="position:relative;">
							<textarea name="reply" id="reply0" onClick="chkRpLen(this);" onBlur="chkRpLen(this);" placeholder=""><%=phTxt %></textarea>
							<button onClick="chkFm(0);"><p>등록</p></button>

							</li>
						</ul>
</form>
<% 'End If %>

									

<%
	If totCnt>0 Then
		sortBy="grp_num DESC, grp_ord, regDate DESC"

		sql="SELECT * FROM (SELECT ROW_NUMBER() OVER(ORDER BY "& sortBy &") AS ROWNUM,"&_
			" * FROM CP_reply WHERE"& wquery&_
			") AS tmp WHERE ROWNUM BETWEEN "& initPage+1 &" AND "& initPage+pagesize
		'Response.write sql
		Set oRS=g_oDB.execute(sql)
		ii=0
%>
						<table>						
							<thead>
								<tr>
									<td colspan="3">
										<ul>
											<li>댓글 리스트 </li>
											<li>| 총 <span><%=totCnt %></span>건</li>
										</ul>
									</td>
								</tr>
							</thead>
							<tbody>
<%
		Do While Not (oRS.BOF Or oRS.EOF)
			rp_seq=oRS("rp_seq")
			grp_num=oRS("grp_num")
			userid=Trim(oRS("UserId"))
			regDate=Trim(oRS("regDate"))
			reply=Trim(oRS("reply"))
			is_delete=Trim(oRS("is_delete"))
			sub_rpCnt=oRS("sub_rpCnt")
			isSecret=oRS("isSecret")
			secretUserId=oRS("secretUserId")

			If is_delete="Y" Then reply="* 삭제된 댓글 입니다."

			isWriter=False
			If userid=g_Mem.uid Then isWriter=True ' 글쓴이
			If Not isWriter And Not isAdmin Then
				If Len(userid)>3 Then
					userid=Left(userid, Len(userid)-3) &"***"
					'Response.write "serid=Left(userid, Len(userid)-3) : " & userid & "<br />"
					'Response.End
				Else
					userid=Left(userid, 1) &"**"
					'Response.write "userid=Left(userid, 1) : " & userid & "<br />"
					'Response.End
				End If

				If isSecret="Y" And (g_Mem.uid="" Or g_Mem.uid<>secretUserId) Then reply="* 비밀 댓글 입니다."
			End If
			If InStr(admStr, Trim(oRS("UserId")))>0 Then userid="두클 운영자"
			
			If oRS("grp_ord")=0 Then ' 1depth 답글...
%>
								<tr<% If (ii+1)=totCnt Then %> style="border-bottom:1px solid #6d8dc6;"<% End If %>>
									<td><%=userid %></td>
									<td class="data_target">

										<ul style="width: 640px;"> 
											<li style="overflow: hidden;">
												<span class="date"><%=regDate %></span>
<% If is_delete="n" Then %>
												<button type="button" onClick="btnReply('add', <%=rp_seq %>, <%=grp_num %>);"><p>답글</p></button>
<%				If isWriter Or isAdmin Then %>
												<% If isWriter Then %>
												<button type="button" onClick="btnReply('edit', <%=rp_seq %>, <%=grp_num %>);"><p>수정</p></button>
												<% End If %>
												<button type="button" onClick="btnReply('del', <%=rp_seq %>, <%=grp_num %>);"><p>삭제</p></button>
<%				End If %>
<% End If %>
											<li><span><%=reply %></span></li>
										</ul>
									</td>
								</tr>




<% If is_delete="n" Then %>
								<tr id="liRp<%=grp_num %>" style="display:none;" class="in_comm">
									<td colspan="2" style="padding:0px">
<form name="fmReply<%=grp_num %>" method="post">
<input type="hidden" name="mode" value="add" />
<input type="hidden" name="rp_seq" />
										<ul class="detail_comment type02">
											<li>댓글 작성</li>
											<li>| <span><%=g_Mem.uid %></span></li>
											<li><label><input type="checkbox" name="isSecret" id="isSecret" value="Y" />비밀 댓글</label></li>
											<li style="position:relative;">
											<textarea name="reply" id="reply<%=grp_num %>" onClick="chkRpLen(this);" placeholder=""><%=phTxt %></textarea>
											<button onClick="chkFm(<%=grp_num %>);"><p>등록</p></button>
											</li>
										</ul>
</form>										
									</td>
								</tr>
<%				If isWriter Then ' 수정 입력화면... %>
								<tr id="liRpEdit<%=rp_seq %>" style="display:none;border-bottom:1px solid #ebebeb;" class="in_comm">
									<td colspan="2" style="padding:0px">
<form name="fmRpEdit<%=rp_seq %>" method="post">
<input type="hidden" name="mode" value="edit" />
<input type="hidden" name="rp_seq" value="<%=rp_seq %>" />
										<ul class="detail_comment type02">
											<li>댓글 작성</li>
											<li>| <span><%=g_Mem.uid %></span></li>
											<li></li>
											<li style="position:relative;">
											<textarea name="reply" id="rpEdit<%=rp_seq %>" onClick="chkRpLen(this);"><%=reply %></textarea>
											<button onClick="chkFm(<%=grp_num %>, <%=rp_seq %>);"><p>등록</p></button>
											</li>
										</ul>
</form>
									</td>
								</tr>
<%				End If %>
<% End If %>
<%
			Else ' 2depth 답글...
%>
								<tr class="reply" <%If totCnt=ii+1 Then%>style="border-bottom:0px;"<%End If %>>
									<td colspan="2" class="data_target">
										<ul style="width: 700px;overflow: hidden;"> 
											<li style="margin-top: 3px;display: inline-block;">
												<img src="/images/renew/sub/reply_figure.png" style="position:absolute;margin-left: -9px;"/>
												<button type="button"><p>답글</p></button><span style="width: 115px;margin-left: 5px;line-height: 13px;vertical-align: super;font-size: 14px;color: #333333;"><%=userid %></span>
											</li>
<% If is_delete="n" Then %>
<%				If isWriter Or isAdmin Then %>
											<li style="width: 539px;float:right;overflow: hidden;">
												<span class="date"><%=regDate %></span>

												<button type="button" onClick="btnReply('edit', <%=rp_seq %>, <%=grp_num %>);"><p>수정</p></button>
												<button type="button" onClick="btnReply('del', <%=rp_seq %>, <%=grp_num %>);"><p>삭제</p></button>

											</li>
<%				End If %>
<% End If %>
											<li style="float: right;width: 539px;">
												<span><%=reply %></span>
											</li>
										</ul>
									</td>									
								</tr>

<% If is_delete="n" Then %>
<%				If isWriter Then ' 수정 입력화면... %>
								<tr id="liRpEdit<%=rp_seq %>" style="display:none;" class="in_comm">
									<td colspan="2" style="padding:0px">
<form name="fmRpEdit<%=rp_seq %>" method="post">
<input type="hidden" name="mode" value="edit" />
<input type="hidden" name="rp_seq" value="<%=rp_seq %>" />
										<ul class="detail_comment type02">
											<li>댓글 작성</li>
											<li>| <span><%=g_Mem.uid %></span></li>
											<li></li>
											<li style="position:relative;">
											<textarea name="reply" id="rpEdit<%=rp_seq %>" onClick="chkRpLen(this);"><%=reply %></textarea>
											<button onClick="chkFm(<%=grp_num %>, <%=rp_seq %>);"><p>등록</p></button>
											</li>

										</ul>
</form>
									</td>
								</tr>
<%				End If %>
<% End If %>


<%
			End If
			ii=ii+1
			oRS.movenext
		Loop
		Call oRS.close()
%>
							</tbody>						
						</table>
						<div class="box_table_num" style="margin-bottom:80px;">
							<% Call renew_pageNavi_ul("getReply", page, totpage, 9) %>
						</div>

<%
	End If
End If
%>
					</div>								

<script>
function btnReply(mode, seq, grp){
	if(mem_o.gotoLogin()) return;
	if (typeof(grp)!="number") grp=0;
	var addli;
	var editli;

	addli=$("#liRp"+ grp);
	editli=$("#liRpEdit"+ seq);

	
	if (mode=="add"){
		if (addli.css("display")=="none"){
			$(".in_comm").css("display", "none");
			//addli.toggle();
//			$("#reply"+ grp).focus();
			addli.css("display","");
		}else{
			$(".in_comm").css("display", "none");
			//addli.toggle();
			addli.css("display","none");
		}
	}else if (mode=="edit"){
		if (editli.css("display")=="none"){
			$(".in_comm").css("display", "none");
			//editli.toggle();
//			$("#rpEdit"+ seq).focus();
			editli.css("display","");
		}else{
			$(".in_comm").css("display", "none");
			//editli.toggle();
			editli.css("display","none");
		}
	}else if (mode=="del"){
		if (confirm("삭제 하시겠습니까?")){
			document.ifrProc.location.href="proc_reply.asp?mode=del&content_seq=<%=idx %>&grp_num="+ grp +"&rp_seq="+ seq;
		}
	}
//	alert(id0.css("display"));
}
function chkRpLen(obj){
	if(mem_o.gotoLogin()) return;
	obj.value=obj.value.split("<%=phTxt %>").join("");// placeholder 문구 삭제...
	if (!chkInputLen(obj.id, 400)) return;
}
function chkFm(grp, seq){
	if(mem_o.gotoLogin()) return;

	var fm, rp;
	if (typeof(seq)=="number"){ // 입력...
		fm=eval("document.fmRpEdit"+ seq);
		rp=$("#rpEdit"+ seq);
	}else{
		fm=eval("document.fmReply"+ grp);
		rp=$("#reply"+ grp);
	}
	if ($.trim(rp.val())==""){
		alert("댓글을 입력해 주세요.");
		fm.reply.focus();
		return;
	}

	fm.target="ifrProc";
	fm.action="proc_reply.asp?content_seq=<%=idx %>&grp_num="+ grp;
	//fm.submit();
}
</script>
<!--#include virtual='/inc/end.inc' -->