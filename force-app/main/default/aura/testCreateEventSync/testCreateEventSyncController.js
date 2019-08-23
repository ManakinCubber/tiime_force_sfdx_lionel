({

   clickAnnuler: function(cmp, evt, helper) {
       cmp.set("v.isShowDialog", "false");
   },
    clickEdit: function(cmp, evt, helper) {
       cmp.find("edit").get("e.recordSave").fire();
       cmp.set("v.isShowDialog", "false");
   },

})