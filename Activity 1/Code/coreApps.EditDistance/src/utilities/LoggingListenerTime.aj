package aspects.encyption;


import interactive.Client;
import interactive.Server;

import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import joinpoints.communication.ReceiveEventJP;
import joinpoints.communication.RequestReplyConversationJP;
import joinpoints.communication.SendEventJP;
import joinpoints.connection.ChannelJP;

import org.apache.log4j.Logger;

import utilities.Encoder;
import utilities.Message;
import baseaspects.communication.OneWayReceiveAspect;
import baseaspects.communication.OneWaySendAspect;
import baseaspects.connection.CompleteConnectionAspect;

public aspect LoggingListenerTime extends CompleteConnectionAspect
{
	Logger logger = Logger.getLogger(LoggingListenerTime.class);
	
	
	Object around(ChannelJP _channelJp): ConversationBeginOnListener(_channelJp)
	{					

		KMClient km_client = new KMClient();
		km_client.connectToServer();//Connecting to KeyManager
		km_client.sendMessage(new KeyRequest(Server.class.getSimpleName(),"abcde"));
		try 
		{
			KeyResponse resp = (KeyResponse) km_client.receiveMessage();
			km_client.closeSocket();
			if (resp != null)
			{
				EncryptionAspect.sharedKey = resp.getKey();
			}
		}	
		catch (IOException e) 
		{
			e.printStackTrace();
			km_client.closeSocket();
		}
		
		return proceed(_channelJp);
		
	}
}
	
