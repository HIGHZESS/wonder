## 내정보페이지의 메인화면 구현
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235071510-bdba356b-d2b9-44e6-9d5f-3ccedcd16cab.png">
</details>

### mapping "/profile"
해당 페이지내에서 정보조회(get)와 수정(post)을 동시에 가능하도록 구현
<br><br><br><br>


### get방식으로 호출될 경우...
- 우선 로그인상태인지 판별한다. <br>
  그 후, 사용자가 판매자(프리랜서)인지, 일반이용자인지 구분하여 판매자일경우 판매자용 정보를 추가로 불러오는 작업을 실행한다.
- 판매자가 사용가능한 언어는 체크상태(checked)로 보여준다.
<br><br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@GetMapping("/profile")
	public String mypage_profile_get(HttpSession session, Model model) {
		logger.info("프로필 페이지");
		
		
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
		

		//세션아이디가 없을때(로그인 안되어있을때) 로그인창으로 이동시키는것 추가해야함 (테스트시에는 없음)
		
		ExpertVO vo = null;
		
		if(type.equals("프리랜서")) {
			vo = mypageService.selectExpertById(userId);
			logger.info("프로필 페이지 프리랜서 정보조회 expertVo={}", vo);
			
			
			String language = vo.getLang();
			String[] langArr = language.split(",");
			logger.info("langArr.length={}",langArr.length);
			
			String framework = vo.getFrame();
			String[] frameArr = framework.split(",");
			logger.info("frameArr.length={}",frameArr.length);
			
			List<LanguageVO> langList = mypageService.selectAllLanguage();
			logger.info("langList.size={}",langList.size());

			List<FrameworkVO> frameList = mypageService.selectAllFramework();
			logger.info("langList.size={}",frameList.size());
			
			
			
			model.addAttribute("langArr",langArr); //전문가 사용가능 언어
			model.addAttribute("frameArr",frameArr); //전문가 사용가능 프레임워크
			model.addAttribute("langList",langList); //전체 언어
			model.addAttribute("frameList",frameList); //전체 프레임워크
			
		}
		logger.info("프로필 페이지 memVo={}",memVo);
		
		model.addAttribute("expertVo", vo);
		model.addAttribute("memVo",memVo);
		
		return "/mypage/profile";
	}
```
  
  </details>
<br><br>

### post방식으로 호출될 경우...
-  수정한 내용 및 선택한 프로필사진을 업로드하여 적용한다
-  기존에 업로드되어있던 프로필사진을 DB에서 삭제하고 새로운 사진을 업로드한다

<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@PostMapping("/profile")
	public String mypage_profile_post(@ModelAttribute ExpertImageVO profileVo ,@ModelAttribute MemberVO memberVo, 
			@ModelAttribute ExpertVO expertVo,  HttpServletRequest request, HttpSession session,Model model) {
		String userId = (String) session.getAttribute("userId");
		if(userId==null) {
			String msg="로그인이 필요한 서비스입니다";
			String url="/";
			
			model.addAttribute("msg",msg);
			model.addAttribute("url",url);
			
			return "/common/message";
		}
		
		memberVo.setUserId(userId);
		logger.info("멤버프로필 수정 처리, memberVo={}",memberVo);
		int cnt=mypageService.updateMember(memberVo);
		logger.info("멤버프로필 업데이트 결과, cnt={}",cnt);
		
		int check = mypageService.checkFree(userId);
		logger.info("프리랜서 확인 1이면 프리랜서, check={}", check);
		int freeCnt=0;
		
		
		String fileName="", originFileName="";
		long fileSize=0;
		List<Map<String, Object>> fileList=null;
		
		if(check>0) {
			expertVo.setUserId(userId);
			freeCnt = mypageService.updateFree(expertVo);
			logger.info("프리랜서 업데이트 결과, freeCnt={}, expertVo={}", freeCnt, expertVo);
			
			//파일 업로드
			try {
				fileList = fileUploadUtil.profileUpload(request, ConstUtil.EXPERT_PROFILE_IMAGE);
				logger.info("fileList 사이즈 ={}",fileList.size());
				if(fileList.size()!=0 && !fileList.isEmpty()) {
					
					for(Map<String, Object> fileMap : fileList) {
						originFileName=(String) fileMap.get("originalFileName");
						fileName=(String) fileMap.get("fileName");
						fileSize=(long)fileMap.get("fileSize");
						logger.info("파일 업로드 성공, fileName={}, fileSize={}",fileName, fileSize);
						
						if(fileSize>10*1024*1024) {
							String msg="이미지는 10MB를 초과할 수 없습니다.",
									url="/mypage/profile";
							return "/common/message";
						}
					
						//프로필사진 DB로 넣는부분
						profileVo.setUserId(userId);
						profileVo.setFileName(fileName);
						profileVo.setOriginalFileName(originFileName);
						profileVo.setFileSize(fileSize);
						profileVo.setFileType("PROFILE"); //체크용임 실재로는 xml에서 PROFILE 상수로 들어감
						
						int profileCnt = mypageService.insertExpertProfile(profileVo);
						logger.info("전문가사진 vo, profileVo={}",profileVo);
						logger.info("파일 업로드 완료 profileCnt={}", profileCnt);
						
						//이전파일이름
						//메소드를 count(*)갯수로 바꾸고, (2이상이 나올경우 expert_img_no가 가장 작은값 삭제) 이걸 반복해서 2이하까지
						int checkCountProfile = mypageService.checkExpertProfileById(userId);
						logger.info("현재 프로필사진 갯수={}",checkCountProfile);
						if(checkCountProfile>1) {
							while(true) {
								int deleteDupProfileCnt = mypageService.deleteDupExpertProfile(userId);
								int checkCount = mypageService.checkExpertProfileById(userId);
								logger.info("중복 프로필 사진 삭제 결과 cnt={}, 남은 프로필사진 갯수={}",deleteDupProfileCnt,checkCount);
								if(checkCount==1) {
									break;
								}
							}
						}
					} //for
				}else{	//사진업로드 안했을경우
					logger.info("사진 업로드 안함");
					profileVo.setUserId(userId);
					profileVo.setFileName("default_profile.png");
					profileVo.setOriginalFileName("default_profile.png");
					profileVo.setFileSize(18906);
					profileVo.setFileType("PROFILE"); //체크용임 실재로는 xml에서 PROFILE 상수로 들어감

					int defaultCnt = mypageService.insertDefaultExpertProfile(profileVo);
					logger.info("기본프로필 등록");
					
					int checkCountProfile = mypageService.checkExpertProfileById(userId);
					logger.info("현재 프로필사진 갯수={}",checkCountProfile);
					if(checkCountProfile>1) {
						while(true) {
							int deleteDupProfileCnt = mypageService.deleteDupExpertProfile(userId);
							int checkCount = mypageService.checkExpertProfileById(userId);
							logger.info("중복 프로필 사진 삭제 결과 cnt={}, 남은 프로필사진 갯수={}",deleteDupProfileCnt,checkCount);
							if(checkCount==1) {
								break;
							}
						}
					}
				}//else
					
			} catch (IllegalStateException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}

		} //전문가용 if종료
		
		
		
		String msg="멤버프로필 수정 실패", url="/mypage/profile";
		if(check==0) {
			if(cnt>0) {
				msg="프로필 수정 성공";
			}
		}else if(check>0) {
			if(freeCnt>0) {
				msg="프로필 수정 성공";
			}
		}
		
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		
		return "/common/message";
	}
```
  
  </details>
