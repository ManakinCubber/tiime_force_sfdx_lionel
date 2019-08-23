trigger trDocumentBeforeDelete on ContentDocument (before delete) {

	if (PAD.canTrigger('AP12_UploadFile')) {
		AP12_UploadFile.beforeDelete(Trigger.oldMap);
	}
}