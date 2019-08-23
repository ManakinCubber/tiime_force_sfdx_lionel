global class CronMajAccount implements Schedulable {
    /**
    * Cron récupérant les HistoryAccount dont la date effective est aujourd'hui et met à jour les valeurs des comptes liés à ces HistoryAccount
    * */
    global void execute(SchedulableContext SC) {
        BatchMajHA batch = new BatchMajHA();
        database.executebatch(batch);
    }
}