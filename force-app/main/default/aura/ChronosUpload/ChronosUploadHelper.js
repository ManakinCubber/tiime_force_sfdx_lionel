({
	toast: function(cmp,titre,filename,phraseEtat,etat){
		var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                title: titre,
                message: "Le fichier '"+filename+"' "+phraseEtat,
                key: 'info_alt',
                type: etat,
            });
            toastEvent.fire();
         }
	},

    upload: function(cmp, helper) {
        var sfdcId = cmp.get("v.recordId");
        var sendType = '';
        cmp.set("v.recordError",'');        

        var filename = cmp.get("v.Filename");
        var typeFile = cmp.get("v.TypeFile");
        var fileId = cmp.get("v.FileId");

        if(cmp.get("v.sObjectName") == 'Account'){
            sendType = 'companies';
        }else{
            sendType = 'users';
        }
        
        var action = cmp.get("c.uploadDocumentFile");
        action.setParams({
            docId: fileId,
            sfdcId:cmp.get("{!v.accountRecord.ChronosId__c}"),
            sendType:sendType,
            typeFile:typeFile
        });
        this.showSpinner(cmp);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        title: "Succès!",
                        message: "Le fichier '"+filename+"' a été uploadé.",
                        key: 'info_alt',
                        type: 'success',
                    });
                    toastEvent.fire();
                }
                cmp.set("v.TypeFile",null);
                
                 //helper.deleteFile(cmp);
            }
            else {
                console.log("Failed with state: " + state);
                this.GetErrors(cmp,response.getError());
            }
            this.showSpinner(cmp,'hide');
        });
        $A.enqueueAction(action);
    },
    GetErrors : function(cmp,errors) {
        console.log('GetErrors begin');
        console.log(errors);
        if (errors) {
            if (errors[0] && errors[0].message) {
                console.log("Error message: " + errors[0].message);
                cmp.set("v.recordError",errors[0].message);                
            }
        } else {
            console.log("Unknown error");
        }
        console.log('GetErrors end');
    },
    showSpinner : function(cmp,state) {
        var spinner = cmp.find("spinner");
        if(state=="hide"){
            $A.util.addClass(spinner, "slds-hide");
        } else {
            $A.util.removeClass(spinner, "slds-hide");
        }
    },
  	readFile: function(cmp, helper,listInfo){
        console.log("readFile Begin");
        
        if (listInfo[2] > cmp.get("v.MAX_FILE_SIZE")) {
        	helper.toast(cmp,'Erreur!',listInfo[1],' ne doit pas excéder '+ cmp.get("v.MAX_FILE_SIZE") +
        	'bytes!\nLa taille du fichier fournit est de '+listInfo[2]+' bytes!','error');
    	    helper.deleteFile(cmp);
    	    cmp.set("v.FileId",null);
    	    cmp.set("v.Filename",null);
        }
    },
    deleteFile : function(cmp) {
    	var fileId = cmp.get("v.FileId");
    	var deleteFileAction = cmp.get("{!c.deleteFile}");
        deleteFileAction.setParams({
          	docId : fileId
        });
        $A.enqueueAction(deleteFileAction);
    }
})