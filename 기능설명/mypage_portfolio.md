## 내정보페이지의 포트폴리오 페이지 구현
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235073211-794dc6a4-408c-4e06-b71e-cfc6e607954a.png">
</details>
<br><br>

<details>
  <summary>모달화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235073377-e7c77285-bc11-4c99-a985-c095ef4b0b12.png">
</details>
<br><br>


### mapping "/portfolio"
해당 페이지내에서 포트폴리오 조회(get)와 수정(post)을 동시에 가능하도록 구현
<br><br><br><br>


### get방식으로 호출될 경우...
우선 로그인상태인지 판별한다. 사용자가 일반 사용자일경우 해당 페이지는 목록에 노출되지않는다.
<br>
그 후 판매자의 포트폴리오 정보를 추가로 불러오는 작업을 실행한다.

<br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@GetMapping("/portfolio")
	public String mypage_portfolio_get(HttpSession session, Model model) {
		logger.info("전문가용 포트폴리오 페이지");
		
		String userId=(String) session.getAttribute("userId");
		if(userId==null) {
			String msg="로그인이 필요한 서비스입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		
		MemberVO memVo = mypageService.selectMemberById(userId);
		String type = memVo.getType();


		ExpertVO vo = null;
		
		if(type.equals("프리랜서")) {
			vo = mypageService.selectExpertById(userId);
			logger.info("프로필 페이지 프리랜서 정보조회 expertVo={}", vo);
		}else {
			String msg="일반회원은 접근할 수 없는 페이지입니다", url="/mypage/profile";
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			return "/common/message";
			
		}
		
		//포트폴리오 이미지 list
		List<ExpertImageVO> list = mypageService.selectExpertPortfolioById(userId);

		logger.info("포트폴리오 리스트사이즈={}",list.size());
		logger.info("포트폴리오 파일정보={}",list);
		logger.info("프로필 페이지 memVo={}",memVo);
		
		model.addAttribute("list", list);
		model.addAttribute("expertVo", vo);
		model.addAttribute("memVo",memVo);
		
		return "/mypage/portfolio";
	}
```
  
  </details>
<br><br>

### post방식으로 호출될 경우...
-  기존에 업로드되어있던 포트폴리오를 DB에서 삭제하고 새로운 파일을 업로드한다
-  수정한 내용 및 선택한 포트폴리오를 업로드하여 적용한다


<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@PostMapping("/portfolio")
	public String mypage_portfolio_post(@RequestParam(required = false) String reviewProtfolioName,
			HttpServletRequest request,	HttpSession session, Model model) {
		
		MultipartHttpServletRequest mtfRequest = (MultipartHttpServletRequest)request;
		String userId = (String)session.getAttribute("userId");
		if(userId==null) {
			String msg="로그인이 필요한 서비스입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		
		List<MultipartFile> fileList = mtfRequest.getFiles("portfolioFile");
		logger.info("포트폴리오 등록 처리 fileList.size={}, 접속중인 유저 아이디 ={}",fileList.size(),userId);
		logger.info("테스트={}",reviewProtfolioName);
		
		String uploadPath = fileUploadUtil.getUploadPath(mtfRequest, ConstUtil.EXPERT_PORTFOLIO_IMAGE);

		int index=0;
		int profileCnt=0;
		
		String msg="멤버프로필 수정 실패", url="/mypage/portfolio";
		//기존포트폴리오 삭제처리
		if(!reviewProtfolioName.equals("") && !reviewProtfolioName.isEmpty()) { //파일업로드를 했을경우 (1이상)
			int delCnt = mypageService.deletePortfolio();
				logger.info("기존 포트폴리오 삭제 성공, cnt={}",delCnt);
		
				//포트폴리오 업로드처리
				for(MultipartFile mf : fileList) {
					String originFileName = mf.getOriginalFilename(); // 원본 파일 명
		            long fileSize = mf.getSize(); // 파일 사이즈
		
		            logger.info("originFileName={} ", originFileName);
		            logger.info("fileSize={}", fileSize);
		            
		            //순수 파일명만 구하기 => a
		    		int idx = originFileName.lastIndexOf(".");
		    		String fileNm=originFileName.substring(0,idx); //a
		    		
		    		//확장자 구하기
		    		String ext = originFileName.substring(idx); //.txt
		            String safeFile = "PORTFOLIO_"+index+"_" + originFileName+ System.currentTimeMillis()+ext;
		            index++;
		            try {
		                mf.transferTo(new File(uploadPath,safeFile));
		            } catch (IllegalStateException e) {
		                e.printStackTrace();
		            } catch (IOException e) {
		                e.printStackTrace();
		            }
		            
		            
		            ExpertImageVO portfolioVo = new ExpertImageVO();
		            //프로필사진 DB로 넣는부분
		            portfolioVo.setUserId(userId);
		            portfolioVo.setFileName(safeFile);
		            portfolioVo.setOriginalFileName(originFileName);
		            portfolioVo.setFileSize(fileSize);
		            portfolioVo.setFileType("PROFILE"); //체크용임 실재로는 xml에서 PROFILE 상수로 들어감
					
					profileCnt = mypageService.insertExpertPorfolio(portfolioVo);
					logger.info("전문가사진 vo, profileVo={}",portfolioVo);
					logger.info("파일 업로드 완료 profileCnt={}", profileCnt);
					
					if(profileCnt>0) {
						msg="포트폴리오 수정 성공";
					}else {
						msg="포트폴리오 수정 성공";
					}
		        }
		}else {
			msg="파일을 선택해야합니다";
		}
		
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		
		return "/common/message";
	}
```
  
</details>
<br>
  
### 이미지를 클릭하여 모달창을 띄우는 경우...
  
해당 이미지를 확대하여 모달창으로 띄워주고, 다시 이미지를 클릭하면 모달창이 닫히게 된다.


<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
```java

<script type="text/javascript">
	$(function(){
		 $("#portfolioImg${vs.index }").click(function(){
			var imgSrc = $('#portfolioBox_innerRight img').attr("src");
			var jstl = "<c:out value='${vs.index }' />";
			$('#portfolioModal_content img').attr("src",imgSrc);
		    $(".portfolioModal").eq(jstl).fadeIn();
		 });
			  
		  $(".portfolioModal_content img").click(function(){
			var jstl = "<c:out value='${vs.index }' />";
		    $(".portfolioModal").eq(jstl).fadeOut();
		 });
	});
</script>
  
  
  
<div class="portfolioBox_outter">
	<div class="portfolioBox_innerRight align_c">
		
		<img alt="포트폴리오 이미지" src="<c:url value='/img/mypage/expert_portfolio/${vo.fileName }' />" 
			class="portfolioImg" id="portfolioImg${vs.index }">
			
		<div class="portfolioModal" id="portfolioModal${vs.index }">
		  <div class="portfolioModal_content" title="클릭하면 창이 닫힙니다.">
		  	<img alt="포트폴리오 모달 이미지" src="<c:url value='/img/mypage/expert_portfolio/${vo.fileName }' />"
		  		style="height: 700px;">
		  </div>
		</div>
																			
	</div>
	<div>
		<p class="align_c">클릭시 확대</p>
	</div>
</div>

```
  </details>
