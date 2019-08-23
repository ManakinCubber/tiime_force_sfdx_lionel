public abstract class WS01_Generic {
    
    @TestVisible
    protected HttpRequest req;
    protected Integer successCodeStatus;
    protected String queryAuth;
    protected boolean isFromAuraComponent;
    protected boolean mustLogError = false;
    
    private SObject retrieveAuthParameters(String wsName) {
    	List<SObject> authList = Database.query(queryAuth + ' WHERE DeveloperName = \'' + wsName + '\'');
    	return (authList.isEmpty() ? null : authList.get(0));
    }
    
    public void prepareRequest(String wsName) {
    	this.req = new HttpRequest();
    	
    	SObject auth = retrieveAuthParameters(wsName);
    	if(auth != null) {
	    	setRequest(auth);
	    	
	    	this.req.setTimeout(60000);
    	}   	
    	//System.debug(req);
    }
    
    public HttpResponse sendRequest() {
    	Http http = new Http();
    	HttpResponse resp;
    	if(!Test.isRunningTest()) {
    		resp = http.send(this.req);
    	} else {
    		resp = callMock(this.req);
    	}
    	//System.debug(resp);
    	//System.debug(resp.getBody());
    	if(resp.getStatusCode() != this.successCodeStatus) {
    		//System.debug(resp);
    		//System.debug(resp.getBody());
    		throwException(resp.getStatus() + resp.getStatusCode() + resp.getBody());
    	}
    	return resp;
    }
    
    public abstract void setRequest(Sobject authObject);
    
    public abstract HttpResponse callMock(HttpRequest req);
    
    private void throwException(String errorMessage) {
    	if(System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled()) {
    		Utils.createLogError(errorMessage);
        } else {
			if(this.mustLogError) {
				Utils.createLogError(errorMessage);
			}
			if(isFromAuraComponent) {
				throw new AuraHandledException(errorMessage);
			} else {
				throw new WS_Exception(errorMessage);
			}
		}    
    }
    
    private class WS_Exception extends Exception {}
}