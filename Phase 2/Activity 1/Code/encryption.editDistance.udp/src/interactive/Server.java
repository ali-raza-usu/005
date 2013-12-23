package interactive;
import java.io.*;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.nio.channels.spi.SelectorProvider;
import java.util.Iterator;

import junit.framework.Assert;

import org.apache.log4j.Logger;
import org.apache.commons.lang3.exception.ExceptionUtils;
import org.junit.Test;

import utilities.*;

 
public class Server extends Thread{
		
	Logger _logger = Logger.getLogger(Server.class);
    SelectionKey selkey=null;
    Selector sckt_manager=null;
    ByteBuffer buffer = ByteBuffer.allocateDirect(2048);
    private SocketAddress destAddr = null;     
   
    
    
    public Server() { 
	}
    
    public void run(){
        try{
            coreServer();
        }
        catch(Exception e){
        	_logger.error(ExceptionUtils.getStackTrace(e)); 
        }
    }
      
    public static void main(String args[]){
    	Server _server = new Server();
    	_server.start();
    }
    
    
    private void coreServer(){
        try{
            DatagramChannel dgc = DatagramChannel.open();            
            
              try{   
                //Establishing New Channel
            	dgc.bind(new InetSocketAddress("localhost",8899)); 
            	_logger.debug("Server successfully binds to a port ");
                sckt_manager=SelectorProvider.provider().openSelector();
                dgc.configureBlocking(false);   
                DatagramChannel client = null;
                dgc.register(sckt_manager,dgc.validOps());
                _logger.debug("Channel Establishd");
                
             
                 
                 while (true)
                 {                          
                     sckt_manager.select();
                     for (Iterator<SelectionKey> i = sckt_manager.selectedKeys().iterator(); i.hasNext();) 
                     { 
             			SelectionKey key = i.next(); 
             			i.remove(); 
             			client = (DatagramChannel)key.channel();
             			//reading and writing data
             			if (key.isReadable()) {     
             				buffer = ByteBuffer.allocateDirect(2048);
             				buffer.clear();	 
             				//TCP version contains a loop to read all the data, but overall it would not affect the design
             				//The construct to read data in a loop is converted to a single line
             				destAddr = client.receive(buffer); 
	             			buffer.flip();
	             			
	             			
	             			//New Input Message
	             			TranslationRequestMessage request = null;
	             			
	             			
	             			if(buffer.hasRemaining()){
	             				request = (TranslationRequestMessage)convertBufferToMessage(buffer);
	             				_logger.debug("Received " + request);
	             				if (request.getData1().equals("quit")) {
									_logger.debug("Now disconnecting the client");
									client.close();
									return;
								}
         				    int num = 1 + (int)(Math.random() * ((1 - 4) + 1));
         				    Thread.sleep(num*200);
         				  
							String str1 = request.getData1();
         				    String str2 = request.getData2();
         				    
         				    int result = LevenshteinDistance(str1, str2);
         				    TranslationResponseMessage response = new TranslationResponseMessage("Levenshtein Distance between string : " + str1+ " and string "+ str2 + " is "+ result);
             				buffer.clear();
             				buffer = ByteBuffer.wrap(Encoder.encode(response));   
             				//=============================
    		        		client.send(buffer, destAddr); 
    		        		//=============================
    		        		_logger.debug("Sending " + response.getResponse());
    		        		if (request.getData1().equals("quit")|| request.getData2().equals("quit")) {
								client.close();
								return;
							}
	             		 }//buffer.hasRemaining
             			} 
                      }
                    }
              }catch (IOException e)
              { 
            	  _logger.error(ExceptionUtils.getStackTrace(e)); 
              }
               finally
              {                
                    try 
                    { 
                    	if (dgc != null){ 
                    		dgc.close();
                        }                    	         
                    }
                    catch (IOException e) 
                    { 
                    	_logger.error(ExceptionUtils.getStackTrace(e)); 
                    }                   
               }
        }
        catch(Exception e)
        {
        	e.printStackTrace();
        	_logger.error(ExceptionUtils.getStackTrace(e)); 
            
        }    
    }

    private Message convertBufferToMessage(ByteBuffer buffer) {
    	 Message message = null;					
		 byte[] bytes = new byte[buffer.remaining()];
		 buffer.get(bytes);
		 message = (Message) Encoder.decode(bytes);
		 buffer.clear();
		 buffer = ByteBuffer.wrap(Encoder.encode(message));  		
		 return message;
	}	
    
    int LevenshteinDistance(CharSequence str1, CharSequence str2)
	  {
    	int[][] distance = new int[str1.length() + 1][str2.length() + 1];
    	 
        for (int i = 0; i <= str1.length(); i++)
                distance[i][0] = i;
        for (int j = 1; j <= str2.length(); j++)
                distance[0][j] = j;

        for (int i = 1; i <= str1.length(); i++)
                for (int j = 1; j <= str2.length(); j++)
                        distance[i][j] = minimum(
                                        distance[i - 1][j] + 1,
                                        distance[i][j - 1] + 1,
                                        distance[i - 1][j - 1]
                                                        + ((str1.charAt(i - 1) == str2.charAt(j - 1)) ? 0
                                                                        : 1));

        return distance[str1.length()][str2.length()];
	  }
    
    private static int minimum(int a, int b, int c) {
        return Math.min(Math.min(a, b), c);
}
    
  @Test
  public void testStringDifference(){
	  String s = "kitten";
	  String l = "sittin";
	  int distance = LevenshteinDistance(s, l);
	  Assert.assertEquals(2, distance);
	  
	  s = "kitten";
	  l = "";
	  distance = LevenshteinDistance(s, l);
	  Assert.assertEquals(6, distance);
	  
	  s = "";
	  l = "";
	  distance = LevenshteinDistance(s, l);
	  Assert.assertEquals(0, distance);
	  
	  s = "kitten";
	  l = "sittin";
	  distance = LevenshteinDistance(l, s);
	  Assert.assertEquals(2, distance);
	  
	  s = "kittn";
	  l = "sittn";
	  distance = LevenshteinDistance(l, s);
	  Assert.assertEquals(1, distance);
	  
	  s = "kitten";
	  l = "sittn";
	  distance = LevenshteinDistance(l, s);
	  Assert.assertEquals(2, distance);
  }
}
