<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>"> 
    <title>点对点聊天</title>  
    
	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">    
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<!--
	<link rel="stylesheet" type="text/css" href="styles.css">
	-->
	<link rel='stylesheet' href='http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css'>
    <style type="text/css">
body {
	background-color: #f8f6e9;
}
.mycenter{
    margin-top: 100px;
    margin-left: auto;
    margin-right: auto;
    height: 350px;
    width:500px;
    padding: 5%;
    padding-left: 5%;
    padding-right: 5%;
}
.mycenter mysign{
    width: 440px;
}
.mycenter input,checkbox,button{
    margin-top:2%;
    margin-left: 10%;
    margin-right: 10%;
}
.mycheckbox{
    margin-top:10px;
    margin-left: 40px;
    margin-bottom: 10px;
    height: 10px;
}
#chitchat {
	display: none;
}
.chitchat{
    margin-top: 100px;
    margin-left: auto;
    margin-right: auto;
    height: 350px;
    width:500px;
    padding: 5%;
    padding-left: 5%;
    padding-right: 5%;
}
    </style>
</head>  
  
<body>
	<div class="mycenter" id="mycenter">
		<div class="mysign">
			<div class="col-lg-11 text-center text-info">
				<h2>请登录</h2>
			</div>
			<div class="col-lg-10">
				<input type="text" class="form-control" id="user_name" name="user_name"
					placeholder="请输入账户名" required autofocus />
			</div>
			<div class="col-lg-10"></div>
			<div class="col-lg-10">
				<button type="button"  class="btn btn-success col-lg-12" onclick="login()" >登录</button>
			</div>
		</div>
	</div>
	<div class="chitchat" id="chitchat">
		<div id="to">
			发送给:[<span class="users">所有人</span>]
		</div>
		<div id="container">
			<div id="left_panel">
				<div id="left_top">
					<!-- <div class="mes from_me">FROM ME</div>  
                <div class="mes to_me">TO ME</div> -->
				</div>
				<textarea id="left_bottom" cols="50" rows="3"></textarea>
				
			</div>
			<div id="right_panel">
				<div id="right_top"></div>
				<div id="right_bottom">
				<input type="button" id="login" value="发送" onclick="send()" style="margin-top:50px" />
					<!-- <input type="text" id="user_name" placeholder="User Name"
						maxlength="10" required /> <input type="button" id="login"
						value="登录" onclick="login()" /> -->
				</div>
			</div>

		</div>
	</div>
	<script>
		var userName;
		var toUser = "";
		var websocket = null;
		function choose(arg) {
			toUser = arg.innerHTML;
			document.getElementById("to").innerHTML = '发送给:[<span class="users">'
					+ toUser + '</span>]';
			if (toUser === '所有人')
				toUser = '';
		}
		function login() {
			if (!document.getElementById("user_name").checkValidity())
				return;
			userName = document.getElementById("user_name").value;
			if (userName == "")
				return;
			ws();
		}
		function ws() {
			if ('WebSocket' in window) {
				websocket = new WebSocket("ws://" + location.host
						+ "/TestWebSocket/chat?id=" + userName);
				//连接成功建立的回调方法  
				websocket.onopen = function(event) {
					console.log("websocket open");
					document.getElementById("mycenter").style.display="none";
					document.getElementById("chitchat").style.display="block";
					//var opt = document.getElementById("right_bottom");
					//opt.innerHTML = '<input type="button" id="login" value="发送" onclick="send()" style="margin-top:50px" />';
				}
				//连接发生错误的回调方法  
				websocket.onerror = function() {
					console.log("websocket error");
					alert("登录失败");
				};
				//连接关闭的回调方法  
				websocket.onclose = function() {
					console.log("websocket close");
					document.getElementById("mycenter").style.display="block";
					document.getElementById("chitchat").style.display="none";
					//var opt = document.getElementById("right_bottom");
					//opt.innerHTML = '<input type="text" id="user_name" placeholder="User Name" maxlength="10" required/><input type="button" id="login" onclick]="login()" value="登录"/>';
				};
				//接收到消息的回调方法  
				websocket.onmessage = function(e) {
					var json = JSON.parse(e.data);
					if ((typeof json.to) == 'undefined') {
						var html = '<div class="users" onclick="choose(this)">所有人</div>';
						for ( var k in json) {
							html += '<div class="users" onclick="choose(this)">'
									+ json[k] + '</div>';
						}
						document.getElementById("right_top").innerHTML = html;
					} else {
						var record = document.getElementById("left_top");
						var html = '<div class="mes to_me">' + json.from
								+ ' : ' + json.content + '</div>';
						record.innerHTML += html;
					}
				};
			} else
				alert("Not Support!");
		}
		window.onbeforeunload = function() {
			if (null != websocket)
				websocket.close();
		};
		function send() {
			var input = document.getElementById("left_bottom");
			var mes = {
				from : userName,
				to : toUser,
				content : input.value
			};
			if (null != websocket)
				websocket.send(JSON.stringify(mes));
			var html = '<div class="mes from_me">' + input.value + ' : '
					+ userName + '</div>';
			document.getElementById("left_top").innerHTML += html;
			input.innerHTML = '';
		}
	</script>  
</body>  
</html>  