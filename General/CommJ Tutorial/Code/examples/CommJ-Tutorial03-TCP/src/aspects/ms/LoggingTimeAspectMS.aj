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
		//hi
     	logger.debug(logString);		
		System.out.println(logString);
	}

	after(MultistepConversationJP _multiStepJP): ConversationEnd(_multiStepJP){
		
		endTime = getCurrentTime();	
     	Message msg =  (Message)Encoder.decode(_multiStepJP.getBytes());
     	String logString = " Multistep: MS Receiver: "+getTargetClass() + " - Message "+ msg.getClass().getSimpleName() + " [ID = " +_multiStepJP.getConversation().getId().toString()+"] at time "+ endTime;
     	
     	
     	logger.debug(logString);		
		System.out.println(logString );
		
		System.out.println("================================");
     	DifferenceTime(sendTime, endTime, getTargetClass());
     	System.out.println("================================");
     	
		
	
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
	
	private void DifferenceTime(String sTime, String eTime, String target) {
		
		DateFormat dateFormat = new SimpleDateFormat("HH:mm:ss");
		Date Stime=new Date();
		Date Etime=new Date();
		String difTime="";
		try {
			 Stime = dateFormat.parse(sTime);
			 Etime = dateFormat.parse(eTime);	
			 long diffTime= Etime.getTime()-Stime.getTime();
			 System.out.println(" The Time for the"+ target + ": (sec) " + diffTime/1000);
			 //difTime= dateFormat.format(diffTime);
			
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}
	

}
