package encryption;


import interactive.Server;

import java.io.IOException;
import joinpoints.connection.ChannelJP;
import org.apache.log4j.Logger;
import baseaspects.connection.CompleteConnectionAspect;

public aspect LoggingListenerTime extends CompleteConnectionAspect
{
	Logger logger = Logger.getLogger(LoggingListenerTime.class);
		
	Object around(ChannelJP _channelJp): ConversationBeginOnListener(_channelJp)
	{					

		KMClient km_client = new KMClient();
		km_client.connectToServer();
		km_client.sendMessage(new KeyRequest("user","abcde"));
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
	
