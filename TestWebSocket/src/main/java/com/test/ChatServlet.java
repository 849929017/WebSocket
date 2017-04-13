package com.test;
import java.util.ArrayList;  
import java.util.List;  
import java.util.Map;  
import java.util.Set;  
import java.util.concurrent.ConcurrentHashMap;  
import java.util.concurrent.ConcurrentMap;  
import javax.websocket.OnClose;  
import javax.websocket.OnError;  
import javax.websocket.OnMessage;  
import javax.websocket.OnOpen;  
import javax.websocket.Session;  
import javax.websocket.server.ServerEndpoint;  
  
import net.sf.json.JSONArray;  
import net.sf.json.JSONObject;  
  
@ServerEndpoint("/chat")  
public class ChatServlet {  
    private String id;  
    private static ConcurrentMap<String,ChatServlet>users = new ConcurrentHashMap<String, ChatServlet>();   
    private Session session;  
      
    private void sendMessage(String mes){  
        this.session.getAsyncRemote().sendText(mes);  
    }  
      
    @OnOpen  
    public void onOpen(Session session){  
        this.session = session;  
        Map<String,List<String>>map = session.getRequestParameterMap();  
        id = map.get("id").get(0);  
        users.put(id, this);  
        List<String>list =new ArrayList<String>( users.keySet());  
        Set<String>key = users.keySet();  
        for(String k: key){  
            users.get(k).sendMessage(JSONArray.fromObject(list).toString());  
        }  
    }  
    @OnClose  
    public void onClose(){  
  
        users.remove(id);  
    }  
       
    /** 
     * 收到客户端消息后调用的方法 
     * @param message 客户端发送过来的消息 
     * @param session 可选的参数 
     */  
    @OnMessage  
    public void onMessage(String message, Session session) {  
        System.out.println("来自客户端的消息:" + message);  
        //here is word filter  
        JSONObject json = JSONObject.fromObject(message);  
        Mes mes = (Mes)JSONObject.toBean(json,Mes.class);  
        if(mes.getTo().isEmpty()){  
            Set<String>key = users.keySet();  
            for(String k: key){  
                if(k.equals(mes.getFrom()))continue;  
                users.get(k).sendMessage(message);  
            }  
        }else{  
            ChatServlet toServlet = users.get(mes.getTo());  
            if(null!=toServlet){  
                toServlet.sendMessage(message);  
            }  
        }  
          
    }  
       
      
    @OnError  
    public void onError(Session session, Throwable error){  
        error.printStackTrace();  
    }  
}  