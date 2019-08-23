global with sharing class Sched_PlannedActivities implements Schedulable {
    
    global static final String PLANNED_TASK_NAME = 'Contrôle des tâches planifiées';
    
    global void execute(SchedulableContext sc) {
      	Batch_PlannedActivities batch = new Batch_PlannedActivities();
      	Database.executeBatch(batch);
	}
	
	global static void scheduleMe() {
    	String sch = '0 0 0,13 ? * MON-FRI';
    	Sched_PlannedActivities scheduler = new Sched_PlannedActivities();
    	String jobID = system.schedule(PLANNED_TASK_NAME, sch, scheduler);

    }
}