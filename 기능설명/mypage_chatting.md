## 내정보페이지의 채팅(메세지) 페이지 구현
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235289422-5e22c443-8f76-4006-b9ec-141ba9b608ed.png">
</details>
<br><br>


### mapping "/chatting"
해당 페이지내에서 거래중인 상대방을 선택하고, 해당 상대와의 메세지를 채팅방식으로 주고받을 수 있습니다.
<br><br><br><br>


### get방식으로 호출될 경우...
우선 로그인상태인지 판별한다.
<br>
그 후 판매자의 거래중인 대상을 불러오는 작업을 실행한다.
<br>


<details>
  <summary>(클릭) 코드확인</summary>
  
```java

	@GetMapping("/chatting")
	public String mypage_chatting_get(@RequestParam(name = "userId" ,required = false) String otherUserId,HttpSession session,Model model) {
		logger.info("채팅 페이지");
		String userId=(String) session.getAttribute("userId");
		if(userId==null) {
			String msg="로그인이 필요한 서비스입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		
		MemberVO vo = mypageService.selectMemberById(userId);
		logger.info("프로필 페이지 vo={}",vo);
		
		if(otherUserId!=null) {
			logger.info("상대방 아이디={}",otherUserId);
			
			HashMap<String, Object> map = new HashMap<>();
			map.put("rUserId", userId);
			map.put("sUserId", otherUserId);
			logger.info("파라미터 map={}",map);
	
			List<HashMap<String, Object>> otherList = chatService.selectChatById(map);
			logger.info("거래대상과의 채팅수={}",otherList.size());
			
			if(otherList.size()==0) {
				ChatVO chatVo = new ChatVO();
				chatVo.setSUserId(userId);
				chatVo.setRUserId(otherUserId);
				int cnt = chatService.insertDefaultChat(chatVo);
				chatVo.setSUserId(otherUserId);
				chatVo.setRUserId(userId);
				int otherCnt = chatService.insertDefaultChat(chatVo);
				
				logger.info("기본채팅 메세지 출력 성공 cnt={}",cnt);
				
				String msg="기본 메세지 등록에 실패하였습니다", url="/mypage/chatting";
				if(cnt>0 && otherCnt>0) {
					msg="기본 메세지 등록에 성공하였습니다";
					
					model.addAttribute("msg",msg);
					model.addAttribute("url",url);
					
				}
				return "/common/message";
			}
		
		}
		
		List<HashMap<String, Object>> list = chatService.selectMyChat(userId);
		
		logger.info("현재 채팅중인 채팅방 list={}", list);
		
		
		model.addAttribute("list",list);
		model.addAttribute("vo",vo);
		
		return "/mypage/chatting";
	}
  
```
  
  </details>
<br><br>

  
### 채팅로직

대상을 선택하면, 대상과의 대화내용을 Ajax로 불러와서 우측의 Detail화면에 뿌려준다.
<br>
보낼 메세지를 작성하고 엔터키나 전송 버튼을 누르면 메세지를 데이터에 등록하고 Ajax로 다시 Detail화면에 데이터를 불러온다.
<br>

<br><br>
  
<details>
  <summary>(클릭) 코드확인</summary>
  
```java

/* 대상선택시 대상과의 대화내용 불러오는 함수 */
$('.dash-msg-inbox li').each(function(item,idx){
	$(this).click(function(){
		var rUserId = $(this).find('.message-by-headline input').val();
		$('#nowId').val(rUserId);
		
		getChatDetail(rUserId);
		
		/* readonly chatSendArea */
		$('#chatSendArea').removeAttr( 'readonly' );
		$('#chatSendArea').attr( "placeholder","내용을 입력해주세요");
		$('#chatCommentContainer').scrollTop($('#chatCommentContainer').height());
		
		//chatInterval();
	});
});
  
  
/* Ajax */
	function getChatDetail(rUserId){
		
		$.ajax({
			url : "<c:url value='/chat/chatDetail'/>",
			type : 'GET',
			data : "rUserId="+rUserId,
			success : function(response) {
				var sUserId = "<c:out value='${vo.userId}'/>";
				var html="";
				var rNickname = "";
				var rUserId = "";
				
				for(var i =0;i<response.length;i++){
				console.log(response[i].CONTENT); //response = list
				console.log(response[i], i);
					if(response[i].S_USER_ID===sUserId) {
						var content = response[i].CONTENT.trim();
						var replace = content.replace('\n', '<br />');
						html += "<div class='message-plunch me'>";
						//html += "	<div class='dash-msg-avatar margin-top-10 right'><i class='fa fa-user' style='font-size: 3em'></i></div>";
						html += "	<div class='dash-msg-text right'><p>"+replace+"</p></div>";
						
						rNickname =response[i].R_NICKNAME;
						rUserId =response[i].R_USER_ID;
					}else if(!(response[i].S_USER_ID===sUserId)) {
						var content = response[i].CONTENT
						var replace = content.replace('\n', '<br />');
						html += "<div class='message-plunch '>";
						//html += "	<div class='dash-msg-avatar margin-top-10 left'><img src=\"<c:url value='/img/mypage/expert_profile/"+filename+"' />\" alt=\"프로필사진\"></div>";
						html += "	<div class='dash-msg-avatar margin-top-10 left'><i class='fa fa-user' style='font-size: 3em'></i></div>";
						html += "	<div class='dash-msg-text left'><p>"+replace+"</p></div>";
					}
					html += "</div>";
					html += "";
				}
				
				$('.dash-msg-content').empty();
				$('.dash-msg-content').append(html);
				$('#chatCommentContainer').scrollTop($('.dash-msg-content').innerHeight());
				
				$('.messages-headline h4').empty();
				$('.messages-headline h4').append(rNickname+"(<span id='r_Id'>"+rUserId+"</span>) 님과의 메세지함입니다");
			},
			error : function(xhr, status, error) {
				alert("메세지 불러오기 실패, rUserId = "+rUserId);
			}
		});
	} //function
  
  
/* controller */
	@ResponseBody
	@RequestMapping("/chatDetail")
	public List<HashMap<String, Object>> chatDetail(@RequestParam("rUserId") String rUserId, HttpSession session) {
		String sUserId = (String) session.getAttribute("userId");
		String rUserIdSession = (String) session.getAttribute("rUserId");
		if(rUserIdSession!=null) {
			logger.info("기존 채팅상대 id={}",rUserIdSession);
		}else {
			logger.info("기존 채팅상대 id 없음");
		}
		session.removeAttribute("rUserId"); //기존 상대방 아이디 세션삭제
		session.setAttribute("rUserId", rUserId); //현재 상대방 아이디 세션추가
		rUserIdSession = (String) session.getAttribute("rUserId");
		logger.info("채팅 detail ajax, 파라미터 상대방아이디={},내아이디={}",rUserId,sUserId);
		logger.info("상대 아이디 세션={}",rUserIdSession);
		
		HashMap<String, Object> map= new HashMap<String, Object>();
		map.put("rUserId", rUserId);
		map.put("sUserId", sUserId);
		logger.info("파라미터 map={}",map);
		
		List<HashMap<String, Object>> list = chatService.selectChatById(map);
		logger.info("채팅중인 list = {}",list);
		logger.info("채팅중인 list.size()={}",list.size());
		
	
		return list; 
	}
  
  
  
  
/* 메세지 작성 후 데이터화하는 함수 */
  
	function sendChat(){
		var content = $('#chatSendArea').val().trim();
		
		/* 
		content = content.replaceAll("\n","<br>");
		console.log(content);
		 */
		var rUserId = $('#r_Id').text();
		
		if(content.length===0){
			alert("내용을 입력하세요");
		}else{
			$.ajax({
				url : "<c:url value='/chat/insertChat'/>",
				type : 'POST',
				data : {"content":content},
				success : function() {
					getChatDetail(rUserId);
				},
				error : function(xhr, status, error) {
					alert("test메세지 입력 실패, content = "+content);
				}
			}); //ajax
		} //else
		$('#chatSendArea').val('');
	} //function
  
  //엔터키로 전송하기
  		$("#chatSendArea").on("keyup",function(e){
			e.preventDefault();
			var code = e.keyCode ? e.keyCode : e.which;
			if (code == 13) // EnterKey
			{
				if (e.shiftKey === true){
					// shift 키가 눌려진 상태에서는 new line 입력
				}else	{
					sendChat();
				}

				return false;
			}
		});
    
  

/* controller */
  
	@ResponseBody
	@RequestMapping("/insertChat") 
	public void insertChat(@RequestParam("content") String content, HttpSession session) {
					  
		String sUserId = (String) session.getAttribute("userId");
		String rUserId = (String) session.getAttribute("rUserId");
		logger.info("채팅 입력 ajax, 파라미터 내아이디={},상대아이디={},메세지={}",sUserId, rUserId,content);
		
		ChatVO vo = new ChatVO();
		vo.setRUserId(rUserId);
		vo.setSUserId(sUserId);
		vo.setContent(content);
		int cnt = chatService.insertChat(vo);
		if(cnt>0) {
			logger.info("입력한 메세지 vo={}",vo);
		}else {
			logger.info("메세지 입력 실패, cnt=0");
		}

	}
  
```
  
</details>
<br>
  
  
  
  
  
  
  
  
  
