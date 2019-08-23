({
	getTasks : function(component) {
		var action  = component.get("c.getTasks");
        action.setParams({
            isToDay: component.get("v.isToDay")
        })
        action.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                var results = res.getReturnValue();
                var textTache = results.length == 1 ? 'Tâche' : 'Tâches';
                var titre = component.get("v.isToDay") ? results.length + ' ' +textTache+' du jour' : results.length + ' ' +textTache+' du jour';
                component.set("v.Titre", titre);
                results.forEach(function(task) {
                    task.ActivityDate = $A.localizationService.formatDate(task.ActivityDate, "dd/MM/yyyy");
                    task.LastModifiedDate = $A.localizationService.formatDate(task.LastModifiedDate, "dd/MM/yyyy hh:mm");
                });
                component.set("v.Tasks", results.slice(0, component.get("v.nbToDisplay")));
            }
        });
        $A.enqueueAction(action);
	},
    getLabels : function(component) {
        var action  = component.get("c.getLabels");
        action.setCallback(this, function(res) {
            if (res.getState() === "SUCCESS") {
                component.set("v.Labels", res.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})