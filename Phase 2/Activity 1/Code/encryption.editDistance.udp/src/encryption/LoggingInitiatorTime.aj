package encryption;
import interactive.Client;
import java.io.IOException;
import joinpoints.connection.ChannelJP;
import org.apache.log4j.Logger;
import baseaspects.connection.CompleteConnectionAspect;

public aspect LoggingInitiatorTime extends CompleteConnectionAspect{
	
	Logger logger = Logger.getLogger(LoggingInitiatorTime.class);
	
	Object around(ChannelJP _channelJp): ConversationBeginOnInitiator(_channelJp)
	{					
		KMClient km_client = new KMClient();
		km_client.connectToServer();
		km_client.sendMessage(new KeyRequest(Client.class.getSimpleName(),"abcdef"));
		try 
		{
			KeyResponse resp = (KeyResponse) km_client.receiveMessage();
			km_client.closeSocket();
			if (resp != null) {
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

				

