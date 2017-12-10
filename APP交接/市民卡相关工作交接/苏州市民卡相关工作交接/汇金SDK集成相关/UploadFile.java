package com.csii.upp.paygate.action.post.lchj;


import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * 
 * 上传文件socket
 *
 * @author 
 * @history
 */
public class UploadFile {
	
	String command = "";
	String commandHead = "";
	String commandBody = "";
	
	public Socket socket = null;
	SocketAddress socketAddress = null;
	SocketUtils su = new SocketUtils();
	 private static Log log = LogFactory.getLog(UploadFile.class);
	/**
	 * 连接远程服务器
	 * @param time
	 * @return
	 */
	public boolean connectCmd(int time) {
		try {
			
			socket = new Socket(); // 创建客户端socket
			socketAddress = new InetSocketAddress("218.4.255.222",Integer.parseInt("18024"));
			socket.setSoTimeout(time);// 设置60秒自动断开
			socket.connect(socketAddress);
		} catch (Exception e) {
			e.printStackTrace();
		} 
		return socket.isConnected();
	}
	
	/**
	 * 发送文件上传请求报文（4001）
	 * 
	 * @param cmd
	 * @throws Exception
	 */
	public String sendUploadFileCmd(String str) throws Exception {
		command = str;
		System.out.println("发送："+command);
		// 发送到服务器
		String result = su.sendMessageServer(command.getBytes(), socket);

		// ---------------------
		System.out.println("接收："+result);
		return result;

	}
	
	
	/**
	 * 断开远程服务器
	 */
	public void closeCmd(Socket socket) {
		try {
			socket.close();
		} catch (Exception e) {
			e.printStackTrace();
		} 
	}
	
	public String uploadMethod(){
		try {
			UploadFile uf = new UploadFile();
			uf.connectCmd(60000);
			uf.sendUploadFileCmd("4001");
			//如果有文件继续4003请求
			uf.closeCmd(uf.socket);
			return "上传完毕";
		} catch (Exception e) {
			e.printStackTrace();
			return e.getMessage();
		}
	}
	public static void main(String[] args) {
		try {
			UploadFile uf = new UploadFile();
			uf.connectCmd(600000);
			String cmd ="UPP40028  ";
			 String xmlStr = "";
	        xmlStr = "<?xml version='1.0' encoding='UTF-8'?>"+
	   			 "<Message>"+
	   			 "<Head>"+
	   			 "<TransCode>UPP40028</TransCode>"+
	   			 "</Head>"+
	   			 "<Body>"+
	   			 "<MobileNo>18915986666</MobileNo>"+
	   			 "<UniqFlag>666</UniqFlag>"+
	   			"<UserPlace>802000</UserPlace>"+
	   			 "</Body>"+
	   			 "</Message>";
	        System.out.println("长度："+(xmlStr.length()+18));
		    uf.sendUploadFileCmd("00000"+(xmlStr.length()+18)+cmd+xmlStr);
			//如果有文件继续4003请求
			uf.closeCmd(uf.socket);     
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
