package com.ez.wonder.chatting.model;

import java.util.HashMap;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChatDAO {
	int insertTestChat(ChatVO chatVo);
	int checkChat(String userId);
	List<HashMap<String, Object>> selectMyChat(String userId);
	List<HashMap<String, Object>> selectChatById(HashMap<String, Object> map);
	String selectNickById(String rUserId);
	int insertChat(ChatVO vo);
}