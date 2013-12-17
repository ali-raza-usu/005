package aspects.encyption;
import interactive.Client;
import java.io.IOException;
import joinpoints.connection.ChannelJP;
import org.apache.log4j.Logger;
import baseaspects.connection.CompleteConnectionAspect;
import aspects.encyption.*;

public aspect LoggingInitiatorTime extends CompleteConnectionAspect{
	
	Logger logger = Logger.getLogger(LoggingInitiatorTime.class);
	
	Object around(ChannelJP _channelJp): ConversationBeginOnInitiator(_channelJp)
	{					
		//This code is about how the KMClient can communicate with the KeyManager to get the Key

		KMClient km_client = new KMClient();
		km_client.connectToServer(); //Connecting to KeyManager
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

				

