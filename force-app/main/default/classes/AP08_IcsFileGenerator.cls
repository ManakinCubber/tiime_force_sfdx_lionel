/**
* author:		Kévin Melliand
* date:			22/01/2019
* description:	Classe appelée par la classe AP06_SendEmailFromLead. Elle génère un fichier de type ICS pour intégrer les RDV aux agendas.
* test:			AP06_SendEmailFromLead_TEST (100%).
*/
public with sharing class AP08_IcsFileGenerator {
    
    private static final String FILE_EXTENSION = '.ics';
    private static final String TIMEZONE = '"Europe/Paris"';
    
    
    public static List<Messaging.EmailFileAttachment> generateIcsAttachment(Datetime startDatetime, String organizerAddress, String subject) {
    	String vCal = 'BEGIN:VCALENDAR' + '\n' + 'VERSION:2.0' + '\n' + 
    	'PRODID:TiimeForce_Icalendar_RDV' + '\n' + 
    	'CALSCALE:GREGORIAN' + '\n' + 'METHOD:REQUEST'+ '\n'+ 
    	'BEGIN:VEVENT'+ '\n' +
		'DTSTART;TZID=' + TIMEZONE + ':' + formatDateToIcs(startDatetime) + '\n' + 
		'DTEND;TZID=' + TIMEZONE + ':' + formatDateToIcs(startDatetime.addHours(1)) + '\n' +
		//'LOCATION:Test' + '\n' +
		'SEQUENCE:0' +'\n' + 'SUMMARY:' + subject + '\n' + 'TRANSP:OPAQUE' + '\n' +
		'END:VEVENT'+ '\n' + 
		'END:VCALENDAR';
 
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(formatFileName(subject));
        efa.setContentType('text/calendar');
      	
        efa.setBody(blob.valueOf(vCal));
        System.debug(vCal);
        System.debug(efa);
        
        return new Messaging.EmailFileAttachment[] {efa};
    }
    
    private static String formatDateToIcs(Datetime srcDatetime) {
    	return formatYearForIcs(srcDatetime.year()) + checkZeroForIcs(srcDatetime.month()) + checkZeroForIcs(srcDatetime.day()) + 'T' 
    	+ checkZeroForIcs(srcDatetime.hour()) + checkZeroForIcs(srcDatetime.minute()) + checkZeroForIcs(srcDatetime.second());
    }
    
    private static String formatYearForIcs(Integer yearValue) {
    	return String.valueOf(yearValue);
    }
    
    private static String checkZeroForIcs(Integer value) {
    	return (value.format().length() == 1 ? '0' + value.format() : value.format());
    }
    
    private static String formatFileName(String srcFilename) {
    	return srcFilename.replace(' ', '_') + FILE_EXTENSION;
    }
}