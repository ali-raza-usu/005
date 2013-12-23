package utilities;

import java.util.UUID;

public class TranslationResponseMessage extends Message
{
	private static final long serialVersionUID = 1L;
	private String response = "";
		
	public TranslationResponseMessage(String _response) 
	{
		super();
		this.response = _response;
	}
	
	public String getResponse() 
	{
		return response;
	}

	public void setResponse(String response) 
	{
		this.response = response;
	}
	
}
