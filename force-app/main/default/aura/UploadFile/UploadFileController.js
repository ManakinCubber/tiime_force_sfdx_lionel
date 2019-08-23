({
    recordUpdated: function(cmp, event, helper) {
        const action = cmp.get("c.getFiles");
        const inputs = cmp.get("v.inputs");
        action.setParams({
            record: cmp.get("v.recordId")
        });
        action.setCallback(this, function(result) {
            if(result.getState() === "SUCCESS") {
                const list = result.getReturnValue();
                helper.resetInputs(cmp, inputs);
                for(let i = 0 ; i < list.length ; i++) {
                    let index = helper.find(inputs, list[i].ContentDocument.Title);
                    if(index != -1) {
                        inputs[index].valid = 2;
                        inputs[index].documentId = list[i].ContentDocumentId;
                    }
                }
                cmp.set("v.inputs", inputs);
            } else {
                console.log("Failed retrieving files, with state: " + result.getState());
                helper.showToast('error', 'Erreur', result.getError()[0].message);
            }
        });
        $A.enqueueAction(action);

        helper.checkConditions(cmp, inputs);
        cmp.set("v.inputs", inputs);
    }
})