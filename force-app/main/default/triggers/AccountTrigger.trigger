trigger AccountTrigger on Account (before insert, before update, after update) {
    // Before context: set CustomerPriority__c to 'High' if NumberofLocations__c > 150
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            for (Account acc : Trigger.new) {
                if (acc != null && acc.NumberofLocations__c != null && acc.NumberofLocations__c > 150) {
                    acc.CustomerPriority__c = 'High';
                }
            }
        }
    }

    // Preserve existing after update platform event publish
    if (Trigger.isAfter && Trigger.isUpdate) {
        List<Account_Platform_Event__e> listOfAccount = new List<Account_Platform_Event__e>();
        for (Account a : Trigger.New) {
            Account_Platform_Event__e eve = new Account_Platform_Event__e();
            eve.Account_Name__c = a.Name;
            eve.Phone__c = a.Phone;
            eve.Salary__c = a.AnnualRevenue;
            listOfAccount.add(eve);
        }
        if (!listOfAccount.isEmpty()) {
            EventBus.publish(listOfAccount);
        }
    }
}
