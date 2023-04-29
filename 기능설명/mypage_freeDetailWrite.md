## 판매자 정보 요약보기 페이지
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235294291-87ef08ee-2d3e-40f9-953d-1cbd6d5085ef.png">
</details>

### mapping "/freeDetailWrite"
판매자의 정보를 요약해서 볼 수 있는 페이지
<br>
내정보페이지에서는 좌측 판매자프로필사진을 클릭하면 팝업창으로 띄워진다.
<br>
판매자의 기본 정보와 포트폴리오내용, 그리고 지금까지 거래완료된 고객들의 리뷰점수와 내용이 종합적으로 표시된다.
<br>
포트폴리오는 포트폴리오설정화면과 마찬가지로 모달창으로 확대하여 볼 수 있다.
<br><br><br><br>


### get방식으로 호출될 경우...
우선 로그인상태인지 판별한다. <br>
판매자의 정보를 모델에 담아 jsp 페이지로 리턴한다.
<br><br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
	@GetMapping("/freeDetailWrite")
	public String mypage_feeDetail_get(@RequestParam String sellUserId  ,HttpSession session, Model model) {
		logger.info("프리랜서 명함 작성 페이지");
		
		//String userId=(String) session.getAttribute("userId");
		MemberVO memVo = mypageService.selectMemberById(sellUserId);
		String type = memVo.getType();
		logger.info("파라미터 아이디={}",sellUserId);
		
		
		logger.info("해당 유저 타입={}",type);
		if(!type.equals("프리랜서")) {
			String msg="잘못된 접근입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		

		ExpertVO expertVo = mypageService.selectExpertById(sellUserId);
		ExpertImageVO ExpertProfileVo = mypageService.selectExpertProfileById(sellUserId);
		logger.info("expertVo={}",expertVo);
		logger.info("profileVo={}",ExpertProfileVo);
		logger.info("memVo={}",memVo);
		
		List<ReviewVO> reviewList=reviewService.selectReviewByUserId(sellUserId);
		logger.info("리뷰 목록 조회, reviewList.size={}", reviewList.size());
		Map<String, Object> map=reviewService.getAvgScoreByUserId(sellUserId);
		logger.info("리뷰 평점 조회, map={}", map);
		List<ExpertImageVO> portfolioList = mypageService.selectExpertPortfolioById(sellUserId);
		
		model.addAttribute("list", portfolioList);
		model.addAttribute("expertVo", expertVo);
		model.addAttribute("profileVo", ExpertProfileVo);
		model.addAttribute("memVo",memVo);
		model.addAttribute("reviewList", reviewList);
		model.addAttribute("map", map);

		return "/mypage/freeDetailWrite";
	}
```
  
  </details>
<br><br>
