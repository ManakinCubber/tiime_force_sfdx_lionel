public abstract class WS06_GoogleApi extends WS01_Generic {
    
    public WS06_GoogleApi() {
    	queryAuth = 'SELECT MethodeAppel__c, Parametres__c, WsEndpoint__c, StatutCodeSucces__c FROM WSParamGoogleApi__mdt';
    }
    
    public override void setRequest(SObject authObject) {
    	WSParamGoogleApi__mdt auth = (WSParamGoogleApi__mdt) authObject;
    	this.successCodeStatus = auth.StatutCodeSucces__c.intValue();
	    this.req.setMethod(auth.MethodeAppel__c);
	    this.req.setEndpoint(auth.WsEndpoint__c + auth.Parametres__c);
        this.req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    }
}