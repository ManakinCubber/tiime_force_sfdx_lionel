({
	openSingleFile: function(cmp, event, helper) {
		$A.get('e.lightning:openFiles').fire({
			recordIds: [cmp.get("v.documentId")]
		});
	},
	handleUploadFinished: function(cmp, event, helper) {
		const uploadedFiles = event.getParam("files");
		const action        = cmp.get("c.updateDocumentId");
		const documentId    = uploadedFiles[0].documentId;
		console.log("Upload successful");
		helper.updateStatusIcon(cmp, 1);

		action.setParams({
			parentId: cmp.get("v.recordId"),
			field: cmp.get("v.fieldName"),
			documentId: documentId
		});

		action.setCallback(this, function(result) {
			if(result.getState() === "SUCCESS") {
				console.log("Update Id successful");
				helper.updateStatusIcon(cmp, 2);
				cmp.set("v.documentId", documentId);
			} else {
				console.log("Failed file Id update with state: " + result.getState());
				helper.showToast('error', 'Erreur', result.getError()[0].message);
			}
		});
		$A.enqueueAction(action);
	}
})