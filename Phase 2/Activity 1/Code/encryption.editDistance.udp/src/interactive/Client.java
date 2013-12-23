package interactive;
import java.io.*;
import java.net.InetSocketAddress;
import java.net.SocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.*;

import org.apache.commons.lang3.exception.ExceptionUtils;
import org.apache.log4j.Logger;

import utilities.*;


public class Client extends Thread
{
	Logger _logger = Logger.getLogger(Client.class);
    SelectionKey selkey=null;
    Selector sckt_manager=null;
    private SocketAddress srcAddr = null;
    ByteBuffer buffer = ByteBuffer.allocateDirect(2048);
    ByteBuffer readBuf = ByteBuffer.allocateDirect(2048);
    BufferedReader bufReader = null;
    //TranslationRequestMessage reqmsg = null; // declaring TranslationRequestMessage
    public Client() {
	}


    public void coreClient(){
    	
       String _data1 = null;
       String _data2 = null;
       DatagramChannel dc = null;
     
        try
        { 
        	//Connecting to Server
        	dc = DatagramChannel.open();
        	dc.bind(new InetSocketAddress(8896)); 
        	dc.configureBlocking(false);       
            srcAddr = new InetSocketAddress("localhost",8899);
            dc.connect(srcAddr);
            _logger.debug("Channel connected!");
            while(true)
            {
            	 if(dc.isConnected())
            	 {	     
            		 try{
            			if(dc != null){
            				System.out.println("===============Levenshtein Translator======================");
            				System.out.print("Enter String 1 : ");
            				bufReader = new BufferedReader(new InputStreamReader(System.in));            				
            			    _data1 = bufReader.readLine();
            			    
            			    System.out.print("Enter String 2 : ");
            				bufReader = new BufferedReader(new InputStreamReader(System.in));            				
            			    _data2 = bufReader.readLine();	
            			    
            			 
            				if(_data1!= null && _data2 != null)
            				{
            					
            					
            					Message reqmsg = new TranslationRequestMessage(_data1, _data2);
            					
            					
            					
	            				buffer = ByteBuffer.wrap(Encoder.encode(reqmsg));          
	            				//=================================
	            				dc.send(buffer, srcAddr);
	            				//=================================
	            	    		_logger.debug("Sending strings '" + ((TranslationRequestMessage) reqmsg).getData1()+ "' and '"+((TranslationRequestMessage) reqmsg).getData2()+"'");     
	            	    		if(((TranslationRequestMessage) reqmsg).getData1().equals("quit") || ((TranslationRequestMessage) reqmsg).getData2().equals("quit")){
	                       			dc.close();
	                       			return;
	             				}
            				}
             				buffer.clear();	
             			
             				readBuf.clear();
            				while(dc.read(readBuf)<=0);
	            				readBuf.flip();
	            				
	            				TranslationResponseMessage resmsg = (TranslationResponseMessage)convertBufferToMessage(readBuf);
	            				System.out.println("Received " + resmsg.getResponse());
	            				_logger.debug("Received " + resmsg.getResponse());	          				
            			}
            		 }catch(Exception e)
            		 {
            			e.printStackTrace();
            			_logger.error(ExceptionUtils.getStackTrace(e));
            		 }
            	 }
            }   
        } 
        catch (IOException e) 
        {                  	
        	e.printStackTrace();
        	_logger.error(ExceptionUtils.getStackTrace(e));
        }
        finally
        {                
              try 
              { 
              	if (dc.isConnected()){ 
              		dc.close();
                  }
              	if (bufReader != null){ 
              		bufReader.close();
                  }                        
              }
              catch (IOException e) 
              { 
              	_logger.error(ExceptionUtils.getStackTrace(e)); 
              }                   
         }
      }

     
     public void run()
     {
      try
      {
        coreClient();
      }
      catch(Exception e)
      {
    	  e.printStackTrace();
    	  _logger.error(e);
      }}
     

     public static void main(String args[])
     {
     	Client _client = new Client();
     	_client.start();
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
    
}
