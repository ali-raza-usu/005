package encryption;

import joinpoints.communication.ReceiveEventJP;
import utilities.Encoder;
import utilities.Message;
import baseaspects.communication.OneWayReceiveAspect;


public aspect DecryptionAspect extends OneWayReceiveAspect
{
	public Message decryptedMessage;
	Encryption encryption = Encryption.getInstance();
		
	Object around (ReceiveEventJP _receiveEventJp): ConversationEnd( _receiveEventJp)
	{
		if(_receiveEventJp.getBytes().length > 0)
			decryptedMessage = encryption.Decrypt(_receiveEventJp.getBytes(), EncryptionAspect.sharedKey.getSharedKey());
		
		_receiveEventJp.setBytes(Encoder.encode(decryptedMessage));
		return proceed(_receiveEventJp);
	}
}
