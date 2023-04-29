## 내정보페이지의 비밀변호 변경 페이지
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235293587-20b201ce-dbec-4996-bbcf-efa664fc814b.png">
</details>

### mapping "/changePwd"
사용자의 암호를 변경할 수 있는 페이지
<br>
기존 암호를 입력해야 변경이 가능하며, Ajax를 이용하여 기존암호와 일치하는지 확인한다.
<br>
확인이 완료되면 새로운 암호값과 새로운 암호 확인값이 서로 같은지 비교한 후 처리해준다.
<br><br><br><br>


### get방식으로 호출될 경우...
- 우선 로그인상태인지 판별한다. <br>
  그 후, Ajax를 이용하여 기존암호와 비교하기위해 데이터를 담아둔다.
<br><br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
	@GetMapping("/changePwd")
	public String mypage_changePwd_get(HttpSession session,Model model) {
		logger.info("암호 변경 페이지");
		
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
		
		model.addAttribute("vo",vo);
		
		return "/mypage/changePwd";
	}
```
  
  </details>
<br><br>

### 기존암호를 입력하는 경우...
Ajax를 이용하여 기존암호와 비교하는 로직을 실행한다.
<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
  
```java
  
/* ajax */
$.ajax({
	url : "<c:url value='/mypage/checkBefore'/>",
	type : 'GET',
	data : "beforePwd=" + data,
	success : function(response) {
		var output = "";
		if (response) {
			output = "기존 암호와 일치합니다";
			$('.beforePwd').addClass('success');
			$('.beforePwd').removeClass('fail');
		} else {
			output = "기존 암호와 불일치합니다";
			$('.beforePwd').addClass('fail');
			$('.beforePwd').removeClass('success');
		}
		$('.beforePwd').text(output);
	},
	error : function(xhr, status, error) {
		alert("beforePwd:" + beforePwd);
	}
});
  
  
/* controller */
	@ResponseBody
	@RequestMapping("/checkBefore")
	public boolean mypage_checkPwd_ajax(HttpSession session,@RequestParam String beforePwd) {
		String userId=(String) session.getAttribute("userId");
		logger.info("암호체크, 유저아이디={}, 입력한 기존 암호={}",userId, beforePwd);
		
		int result = mypageService.checkPwd(userId, beforePwd);
		logger.info("비밀번호 중복체크 결과 1성공, 2실패, 3없음 result={}",result);
		
		boolean bool = false;
		if(result==MypageService.LOGIN_SUCCESS) {
			bool=true;
		}else if(result==MypageService.DISAGREE_PWD) {
			bool=false;
		}
		
		return bool;
	}
  
```
  
  </details>
<br><br>

### post방식으로 호출될 경우...
입력한 비밀번호로 변경하는 로직을 실행한다.


<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
  
```java

	@PostMapping("/changePwd")
	public String mypage_changePwd_post(@RequestParam String newPwd,HttpSession session,Model model) {
		logger.info("암호 변경 처리, 파라미터 newPwd={}",newPwd);
		String userId=(String) session.getAttribute("userId");
		if(userId==null) {
			String msg="로그인이 필요한 서비스입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		
		
		MemberVO vo = mypageService.selectMemberById(userId);
		logger.info("현재 로그인중인 아이디 vo={}",vo);
		vo.setPwd(newPwd);
		
		BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

		String msg="비밀번호 수정 실패", url="/mypage/changePwd";
		String security = encoder.encode(vo.getPwd());
		
		logger.info("비밀번호 암호화 pwd={},security={}",vo.getPwd(),security);
		vo.setPwd(security);
		
		logger.info("수정예정 비밀번호 vo.pwd={}",vo.getPwd());
		int pwdCnt = mypageService.updatePwd(vo);
		logger.info("수정처리 완료 cnt={}",pwdCnt);
		if(pwdCnt>0) {
			msg="비밀번호 수정 성공!";
		}
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		
		return "/common/message";
		
		
	}
  
```
  
  </details>
