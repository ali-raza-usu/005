package aspects.encyption;

import java.security.Key;

import org.apache.log4j.Logger;

import joinpoints.communication.SendEventJP;
import universe.Conversation;
import utilities.Encoder;
import utilities.IMessage;
import utilities.Message;
import baseaspects.communication.OneWaySendAspect;
import interactive.Client;

public aspect EncryptionAspect extends OneWaySendAspect
{
	private Logger logger = Logger.getLogger(OneWaySendAspect.class);			
	public byte[] encryptedBytes;
	Encryption encryption = Encryption.getInstance();
	public static SharedKey sharedKey;

	
	
	Object around (SendEventJP _sendEventJp): ConversationBegin(_sendEventJp){
		/*
		 * 1. Get the message
		 * 2. Encrypt the message
		 * 3. Set the message to bytes
		 */
		
		//System.out.println("Encryption Ascpet");
		Message msg =  (Message)Encoder.decode(_sendEventJp.getBytes());
		encryptedBytes = encryption.Encrypt(msg, sharedKey.getSharedKey());
		//System.out.println(encryptedBytes);		
		_sendEventJp.setBytes(encryptedBytes);
		//System.out.println("EncryptionAs[pect no of bytes sent are " + encryptedBytes.length);
		return proceed(_sendEventJp);
	}
	
}
