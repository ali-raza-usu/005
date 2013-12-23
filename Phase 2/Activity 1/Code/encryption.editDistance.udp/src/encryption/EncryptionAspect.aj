package encryption;


import joinpoints.communication.SendEventJP;
import utilities.Encoder;
import utilities.Message;
import baseaspects.communication.OneWaySendAspect;


public aspect EncryptionAspect extends OneWaySendAspect
{
	public byte[] encryptedBytes;
	Encryption encryption = Encryption.getInstance();
	public static SharedKey sharedKey;
		
	Object around (SendEventJP _sendEventJp): ConversationBegin(_sendEventJp)
	{
		Message msg =  (Message)Encoder.decode(_sendEventJp.getBytes());
		encryptedBytes = encryption.Encrypt(msg, sharedKey.getSharedKey());
		_sendEventJp.setBytes(encryptedBytes);
		return proceed(_sendEventJp);
	}
}
