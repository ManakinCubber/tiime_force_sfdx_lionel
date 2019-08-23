({
	doInit : function(component, event, helper) {
		console.log("option left : "+component.get("v.showLeft"));
		if(component.get("v.showLeft")){
			var composant = component.find("composant")
			$A.util.removeClass(composant, "slds-align_absolute-center");
		}
	},
	removeValue : function(component, event, helper) {
		component.find("radioG").set("v.value", null);
	},
})