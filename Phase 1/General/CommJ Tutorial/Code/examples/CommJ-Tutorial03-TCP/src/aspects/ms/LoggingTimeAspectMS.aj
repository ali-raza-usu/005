package aspects.ms;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import joinpoints.communication.MultistepConversationJP;
import org.apache.log4j.Logger;
import utilities.Encoder;
import utilities.Message;
import baseaspects.communication.MultistepConversationAspect;

public aspect LoggingTimeAspectMS extends MultistepConversationAspect {

	private Logger logger = Logger.getLogger(LoggingTimeAspectMS.class);
	
	String sendTime="";
	String endTime="";

	before(MultistepConversationJP _multiStepJP): ConversationBegin(_multiStepJP){
		sendTime = getCurrentTime();
     	Message msg =  (Message)Encoder.decode(_multiStepJP.getBytes());
     	String logString = null;
     	if(_multiStepJP.getConversation() == null)
     		logString = "Multistep : MS Sender: "+getTargetClass() + " - Message "+ msg.getClass().getSimpleName() + " [ID = " +_multiStepJP.getConversation()+"] at time "+ sendTime;
     	else
     		logString = "Multistep: MS Sender: "+getTargetClass() + " - Message "+ msg.getClass().getSimpleName() + " [ID = " +_multiStepJP.getConversation().getId().toString()+"] at time "+ sendTime;
	logger.debug(logString);		
	System.out.println(logString);
	}

	after(MultistepConversationJP _multiStepJP): ConversationEnd(_multiStepJP){
		
		endTime = getCurrentTime();	
     	Message msg =  (Message)Encoder.decode(_multiStepJP.getBytes());
     	String logString = " Multistep: MS Receiver: "+getTargetClass() + " - Message "+ msg.getClass().getSimpleName() + " [ID = " +_multiStepJP.getConversation().getId().toString()+"] at time "+ endTime;
     	
     	
     	logger.debug(logString);		
		System.out.println(logString );
		
	System.out.println("===== This is to compute the time needed for the conversation ======");
	// based on the sendTime and endTime values, compute the difference time.
	DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
	Date startingTime=new Date();
	Date endingTime=new Date();
	long differenceTime = 0;
	try
	{
		startingTime = dateFormat.parse(sendTime);
		endingTime = dateFormat.parse(endTime);	
		differenceTime= endingTime.getTime() - startingTime.getTime(); // the difference time
	        System.out.println("The Time needed for this conversation is " + differenceTime/1000 + "  seconds.");
	}
	catch (ParseException e) 
	{
		e.printStackTrace();
	}
     }

	private String getCurrentTime(){
		DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
		Date date = new Date();
		return dateFormat.format(date);
	}
	
	public static String getTargetClass() {
		StackTraceElement[] elements = Thread.currentThread().getStackTrace();
		String[] classes = elements[elements.length - 1].getClassName().split("\\.");
		return classes[classes.length - 1];
	}
	

	

}
