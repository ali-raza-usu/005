package aspects.encyption;

import java.io.IOException;
import joinpoints.connection.ChannelJP;
import org.apache.log4j.Logger;
import baseaspects.connection.CompleteConnectionAspect;


public aspect LoggingListenerTime extends CompleteConnectionAspect
{
	Logger logger = Logger.getLogger(LoggingListenerTime.class);
		
	Object around(ChannelJP _channelJp): ConversationBeginOnListener(_channelJp)
	{			
		logger.debug("started the key client");
		KMClient km_client = new KMClient();
		km_client.connectToServer();
		logger.debug("connected to the server");
		km_client.sendMessage(new KeyRequest("simulator","abcde"));
		
		try 
		{
			KeyResponse resp = (KeyResponse) km_client.receiveMessage();
			km_client.closeSocket();
			if (resp != null)
			{
				EncryptionAspect.sharedKey = resp.getKey();
				logger.debug("Client received the key " + EncryptionAspect.sharedKey);
				System.out.println("Client received the key " + EncryptionAspect.sharedKey);
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
	