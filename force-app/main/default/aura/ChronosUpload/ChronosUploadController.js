({
    doInit : function(cmp, evt, helper) {
    },
    handleFilesChange : function (cmp, event, helper) {
        var files = event.getParam("files");
        var docId = files[0].documentId;
        cmp.set("v.FileId", files[0].documentId);
        cmp.set("v.Filename",files[0].name);
        var checkFileAction = cmp.get("c.getContVersByDocId");
        checkFileAction.setParams({
            docId: docId
        });
        checkFileAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
            	var listInfo = response.getReturnValue();
        		helper.readFile(cmp, helper, listInfo);
            }
            else {
                console.log("Failed with state: " + state);
                this.GetErrors(cmp,response.getError());
            }
        });
        $A.enqueueAction(checkFileAction);
    },
    onCancel : function (cmp, event, helper) {
        cmp.set("v.FileId",null);
        cmp.set("v.Filename",null);
        cmp.set("v.TypeFile",null);
    },
    onSave : function (cmp, event, helper) {
        helper.upload(cmp, helper);
    },
})