## 내정보페이지의 거래내역 페이지 구현
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235288808-fdc0b628-57f5-4d45-9e8d-7761f087ec41.png">
</details>
<br><br>
<details>
  <summary>모달창 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235289100-1e272f28-228c-4a98-8e02-5c0a23f03d41.png">
</details>
<br><br>

### mapping "/transaction"
해당 페이지내에서 거래중인 매물 확인과 수락, 의뢰서, 결제등을 동시에 가능하도록 구현
<br><br><br><br>


### get방식으로 호출될 경우...
우선 로그인상태인지 판별한다.
<br>
그 후 판매자의 거래중인 정보를 추가로 불러오는 작업을 실행한다.
<br>
해당 페이지에는 거래중인 5개의 상품만 노출되며 그 이상의 상품에 대한 페이징 처리를 한다.
<br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@RequestMapping(value =  "/transaction", method = {RequestMethod.GET, RequestMethod.POST})
	public String mypage_transaction(@ModelAttribute SearchVO searchVo ,HttpSession session,Model model) {
		logger.info("거래 페이지 searchVo={}",searchVo);
		logger.info("현재 페이지 currentPage={}",searchVo.getCurrentPage());
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
		
		String type = vo.getType();
		
		
		PaginationInfo paging = new PaginationInfo();
		paging.setBlockSize(ConstUtil.BLOCKSIZE5);
		paging.setRecordCountPerPage(ConstUtil.RECORD_COUNT);
		paging.setCurrentPage(searchVo.getCurrentPage());
		
		searchVo.setFirstRecordIndex(paging.getFirstRecordIndex());
		searchVo.setRecordCountPerPage(ConstUtil.RECORD_COUNT);
		
		
		HashMap<String, Object> map = new HashMap<>();
		map.put("searchCondition", searchVo.getSearchCondition());
		map.put("searchKeyword", searchVo.getSearchKeyword());
		map.put("firstRecordIndex", searchVo.getFirstRecordIndex());
		map.put("recordCountPerPage", searchVo.getRecordCountPerPage());
		
		
		
		List<HashMap<String, Object>> list = null;
		if(type.equals("프리랜서")) {
			logger.info("현재 로그인중인 type={}",type);
			map.put("userId", userId);
			
			list = mypageService.selectFormExpert(map);
			logger.info("전문가용 의뢰서 갯수 list.size()={}", list.size());
			
			int totalRecord = mypageService.getTotalRecordTSExpert(map);
			logger.info("프리랜서 토탈레코드 totalRecord={}",totalRecord);
			paging.setTotalRecord(totalRecord);
			
			for(int i=0; i<list.size();i++) {
				HashMap<String, Object> testMap=list.get(i);
				logger.info("테스트용 map체크={}",testMap);
			}
		}else {
			logger.info("현재 로그인중인 type={}",type);
			map.put("userId", userId);
			
			list = mypageService.selectForm(map);
			logger.info("의뢰서 갯수 list.size()={}", list.size());

			int totalRecord = mypageService.getTotalRecordTS(map);
			logger.info("일반회원 토탈레코드 totalRecord={}",totalRecord);
			paging.setTotalRecord(totalRecord);
			
			for(int i=0; i<list.size();i++) {
				HashMap<String, Object> testMap=list.get(i);
				logger.info("테스트용 map체크={}",testMap);
			}
		}
		
		logger.info("페이징용 pagingInfo={}",paging);
		
		model.addAttribute("list",list);
		model.addAttribute("vo",vo);
		model.addAttribute("pagingInfo",paging);

		return "/mypage/transaction";
	}
```
  
  </details>
<br><br>

### 상품거래 승인/취소/완료 버튼을 클릭 할 경우...

컨펌창을 통해 사용자의 응답을 받은 후 최종 확인시 각 페이지에 get방식으로 거래번호를 넘겨준다.
<br>



<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
```java

  /* 승인버튼을 누를 경우 */
  
	@GetMapping("/transactionFormUpdate")
	public String transactionFormUpdate(@RequestParam(required =  false) int formNo,HttpSession session,Model model) {
		logger.info("의뢰서 승인 처리 파라미터 formNo={}",formNo);
		
		FormVo formVo = mypageService.selectFormByNo(formNo);
		logger.info("의뢰서 승인 페이지 vo = {}",formVo);
		
		
		String msg="잘못된 접근입니다", url="/mypage/transaction";
		
		if(formVo.getPayFlag().equals("N")) {
			int formCnt = mypageService.updateForm(formNo);
			if(formCnt>0) {
				msg="거래승인이 완료되었습니다";
			}
		}else {
			msg="이미 거래중인 의뢰입니다";
		}
		
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		return "/common/message";	
	}
	
  
  
  /* 취소버튼을 누를 경우 */
  
	@GetMapping("/transactionFormCancle")
	public String transactionFormCancle(@RequestParam(required =  false) int formNo,HttpSession session,Model model) {
		logger.info("의뢰서 취소 처리 파라미터 formNo={}",formNo);
		
		FormVo formVo = mypageService.selectFormByNo(formNo);
		logger.info("의뢰서 취소 페이지 vo = {}",formVo);
		
		
		String msg="잘못된 접근입니다", url="/mypage/transaction";
		
		if(formVo.getPayFlag().equals("N")) {
			int formCnt = mypageService.updateFormCancle(formNo);
			if(formCnt>0) {
				msg="거래취소가 완료되었습니다";
			}
		}else if(formVo.getPayFlag().equals("Y")){
			int formCnt = mypageService.updateFormCancle(formNo);
			if(formCnt>0) {
				msg="거래취소가 완료되었습니다";
			}
		}else if(formVo.getPayFlag().equals("P")){
				msg="결제가 완료된 상품은 취소할 수 없습니다";
		}else if(formVo.getPayFlag().equals("D")){
				msg="이미 종료된 거래입니다";
		}else if(formVo.getPayFlag().equals("C")){
				msg="이미 취소된 거래입니다";
		}
		
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		return "/common/message";	
	}
	
  
  
  /* 버튼을 누를 경우 */
	
	@GetMapping("/transactionDone")
	public String transactionDone(@RequestParam(required =  false) int formNo,HttpSession session,Model model) {
		logger.info("의뢰서 완료 처리 파라미터 formNo={}",formNo);
		
		FormVo formVo = mypageService.selectFormByNo(formNo);
		logger.info("의뢰서 완료 페이지 vo = {}",formVo);
		
		String freeId = formVo.getPUserId();
		logger.info("판매자아이디 ={}",freeId);
		
		String msg="잘못된 접근입니다", url="/mypage/transaction";
		
		if(formVo.getPayFlag().equals("N")) {
			msg="해당 거래단계에서는 완료할 수 없습니다.";
		}else if(formVo.getPayFlag().equals("Y")){
			msg="해당 거래단계에서는 완료할 수 없습니다.";
		}else if(formVo.getPayFlag().equals("P")){
			int formCnt = mypageService.updateFormDone(formNo);
			if(formCnt>0) {
				msg="거래가 완료되었습니다";
				int plusCnt=mypageService.updateExpertWorkPlus(freeId);
				logger.info("프리랜서 작업량 추가 cnt={}", plusCnt);
			}
		}else if(formVo.getPayFlag().equals("D")){
			msg="이미 종료된 거래입니다";
		}else if(formVo.getPayFlag().equals("C")){
			msg="이미 취소된 거래입니다";
		}
		
		
		model.addAttribute("msg",msg);
		model.addAttribute("url",url);
		
		return "/common/message";	
	}
```
  
</details>
<br>
  
### 의뢰서 버튼을 클릭하는 경우...
우선 로그인상태인지 판별한다.
<br>
그 후 선택한 거래의 의뢰서 정보를 모달창으로 뿌려준다.
<br>
<br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
  
<td class="center"> <!-- 의뢰서 -->
	<div class="_leads_action CModalContainer">
		<a href="#"><i class="fas fa-edit"></i></a>
			<!-- Modal C -->
		   <div class="modal fade modalD" data-backdrop="static" aria-hidden="true" aria-labelledby="exampleModalToggleLabel" tabindex="-1">
		     <div class="modal-dialog modal-lg modal-dialog-centered">
		       <div class="modal-content">
		         <div class="modal-header" style="margin: 0 auto; border-bottom: 3px solid #27ae60;">
		           <h5 class="modal-title" id="exampleModalToggleLabel">의뢰서</h5>
		           <span class="mod-close" data-dismiss="modal" aria-hidden="true" style="border-radius: 50%;"><i class="ti-close"></i></span>
		         </div>
		         <div class="modal-body">
		            <c:import url="/pd/formConfirm">
		               <c:param name="userId" value="${map.B_USER_ID }"></c:param>
		               <c:param name="pdNo" value="${map.PD_NO }"></c:param>
		            </c:import>
		         </div>
		         <div class="modal-footer d-flex justify-content-center">
		            <button type="button" class="btn theme-bg rounded" data-dismiss="modal">확인</button>
		         </div>
		       </div>
		     </div>
		   </div>
	</div>
</td>
  
  
```
  
  </details>
<br><br>
