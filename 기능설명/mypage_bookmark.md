## 내정보페이지의 즐겨찾기 페이지 구현
<br>
<details>
  <summary>화면 미리보기</summary>
  <br>
  <img width="1265" alt="wonder_main" src="https://user-images.githubusercontent.com/105254085/235286918-f70972b9-0d84-442f-8bd3-fe70510e155f.png">
</details>
<br><br>


### mapping "/bookmark"
해당 페이지내에서 즐겨찾기 확인과 삭제(Ajax)를 동시에 가능하도록 구현
<br><br><br><br>


### get방식으로 호출될 경우...
우선 로그인상태인지 판별한다.
<br>
그 후 판매자의 즐겨찾기 정보를 추가로 불러오는 작업을 실행한다.
<br>
해당 페이지에는 5개의 상품만 노출되며 그 이상의 상품에 대한 페이징 처리를 한다.
<br>

<details>
  <summary>(클릭) 코드확인</summary>
  
```java
@RequestMapping("/bookmark")
	public String mypage_bookmark(@ModelAttribute SearchVO searchVo, HttpSession session,Model model) {
		logger.info("찜(북마크) 페이지");
		
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
		
		PaginationInfo paging = new PaginationInfo();
		paging.setBlockSize(ConstUtil.BLOCKSIZE5);
		paging.setRecordCountPerPage(ConstUtil.RECORD_COUNT);
		paging.setCurrentPage(searchVo.getCurrentPage());
		
		searchVo.setFirstRecordIndex(paging.getFirstRecordIndex());
		searchVo.setRecordCountPerPage(ConstUtil.RECORD_COUNT);
		
		
		HashMap<String, Object> map = new HashMap<>();
		map.put("userId", userId);
		map.put("searchCondition", searchVo.getSearchCondition());
		map.put("searchKeyword", searchVo.getSearchKeyword());
		map.put("firstRecordIndex", searchVo.getFirstRecordIndex());
		map.put("recordCountPerPage", searchVo.getRecordCountPerPage());

		List<HashMap<String, Object>> list = mypageService.selectBookmark(map);
		logger.info("북마크 페이지 리스트size={}", list.size());
		
		int totalRecord = mypageService.getTotalRecordBM(map);
		logger.info("북마크 totalRecord={}",totalRecord);
		
		paging.setTotalRecord(totalRecord);
		
		model.addAttribute("list",list);
		model.addAttribute("pagingInfo",paging);
		model.addAttribute("vo",vo);
		
		return "/mypage/bookmark";
	}
```
  
  </details>
<br><br>

### 찜 취소 버튼을 클릭 할 경우...

컨펌창을 통해 사용자의 응답을 받은 후 최종 확인시 bookmarkDel 페이지에게 삭제할 게시글 번호를 get방식으로 보내준다.
<br>
bookmarDel 페이지에서 받은 게시글번호를 이용하여 삭제후, bookmark페이지로 리다이렉트한다.



<br>
<details>
  <summary>(클릭) 코드확인</summary>
  
```java

/* 컨펌 창 */

	$(function(){
		$('.action').each(function(item,idx){
			$(this).find('.delete').click(function(){
				if(!confirm('찜 목록에서 제거하시겠습니까?')){
					return false;
				}else{
					var deleteNo = $(this).next().val();
					location.href="<c:url value='/mypage/bookmarkDel?no="+deleteNo+"' />"
				}//컨펌
			}); //삭제버튼 클릭 이벤트
		});
	});
  
  
  
/* bookmarkDel */

@GetMapping("/bookmarkDel")
	public String mypage_bookmarkDel_get(@RequestParam(defaultValue = "0") String no,HttpSession session) {
		int pdNo=Integer.parseInt(no);
		logger.info("북마크 삭제 페이지, 삭제할 번호={}",pdNo);
		String userId=(String) session.getAttribute("userId");
		MemberVO vo = mypageService.selectMemberById(userId);
		logger.info("프로필 페이지 vo={}",vo);
		
		HashMap<String, Object> map = new HashMap<>();
		map.put("userId", userId);
		map.put("pdNo", pdNo);
		
		logger.info("삭제 파라미터 map={}", map);
		
		int cnt = mypageService.deleteBookmark(map);
		if(cnt>0) {
			logger.info("북마크 삭제완료");
			
		}else {
			logger.info("북마크 삭제실패");
		}
		
		return "redirect:/mypage/bookmark";
	}

```
  
</details>
<br>
