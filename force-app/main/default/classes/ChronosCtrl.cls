/*
 * @author LUA Wailly (Wailly.lua@carrenet.com)
 * @date 14/09/2018 (dd/mm/yyyy)
 * @description Apex controller for file upload
 */
 public class ChronosCtrl{
     
	@AuraEnabled
    public static List<String> getContVersByDocId(String docId){
        contentVersion cv = [SELECT Id,Title,ContentSize FROM contentVersion WHERE ContentDocumentId=:docId];
       String cvId = cv.Id;
       String cvTitle = cv.Title;
       String cvSize = String.valueOf(cv.ContentSize);
       List<String> listInfo = new List<String>();
       listInfo.add(cvId);
       listInfo.add(cvTitle);
       listInfo.add(cvSize);
       System.debug(listInfo);
        return listInfo;
    }
     
    @AuraEnabled
    public static void uploadDocumentFile(String docId, String sfdcId, String sendType, String typeFile){
        uploadFile(docId, sfdcId, sendType, typeFile);
    }
    
    @AuraEnabled
    public static void deleteFile(String docId) {
    	ContentDocument contentDoc = [SELECT Id FROM ContentDocument WHERE Id = :docId];
    	delete contentDoc;
    }

    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 14/09/2018 (dd/mm/yyyy)
     * @description : upload file to Chronos database 
     * Updated by Félix and Kévin (16/01/2019) 
     * NOTES : accountName and extension are useless !!!!!!!
     * @params :      
     *      accountName : Name of the Account  
     *      bodyEncoded : file
     *      sfdcId : Id of contact or account
     *      sendType {'users', 'companies'} : From contact or account
     *      typeFile {'id_certificate','address_proof','status_document','kbis','domiciliation_contract'} 
     */
    @future(callout=true) 
    private static void uploadFile(String docId, String sfdcId, String sendType, String typeFile){
        String boundary = '----WebKitFormBoundary7MA4YWxkTrZu0gW';
        contentVersion cv = [SELECT Id,versionData,Title FROM contentVersion WHERE ContentDocumentId = :docId];
        
        AuthChronos__mdt auth = null;
        AuthChronos__mdt[] authList = [SELECT audience__c,client_secret__c,client_id__c,grant_type__c,
                                        realm__c,scope__c,url_chronos_api__c
                                        FROM AuthChronos__mdt
                                        WHERE DeveloperName=:Label.ChronosEnvironement];
        System.debug('### ChronosCtrl.uploadFile authList='+authList);
        if(!authList.isEmpty()){
            auth = authList[0];
        }

        String fileName = cv.Title;
        String authToken = WS02_Chronos.getToken(auth);
        String cache = 'no-cache';
        String contentType = 'multipart/form-data; boundary="'+ boundary +'"'; 
        String contentDisposition = 'form-data; name="file"; fileName="'+fileName+'"';
        String endpoint = auth.url_chronos_api__c+'/v1/'+sendType+'/'+sfdcId+'/'+typeFile;
        Blob body = generateBody(boundary, fileName, cv.versionData);

        WS02_Chronos.sendFileChronos(authToken, cache, contentType, contentDisposition, endpoint, body);
        
        // Once the file is sent to Chronos, we delete it
        deleteFile(docId);
    }
    
    
    /*
     * @author LUA Wailly (Wailly.lua@carrenet.com)
     * @date 24/09/2018 (dd/mm/yyyy)
     * @description : Blob body to send to Chronos' API 
     * @params :      
     *      boundary : string defined in uploadFile method
     *      fileName : Name of the file uploaded
     *      bodyEncoded : file content
     */
     
    public static Blob generateBody(String boundary, String fileName, blob bodyEncoded3){

        Blob bodyBlob = null;
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+fileName+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }

        String bodyEncoded = EncodingUtil.base64Encode(bodyEncoded3);

        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
        	System.debug('== :');
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;          
        } else {
        	System.debug('else:');
            footer = '\r\n' + footer;
        }
        String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
        return EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
    }
}