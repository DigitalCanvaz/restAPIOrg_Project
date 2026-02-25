trigger AccountTrigger on Account (after update)
{
	If(Trigger.isAfter && Trigger.isUpdate)
    {
        List<Account_Platform_Event__e> listOfAccount = new List<Account_Platform_Event__e>();
        for(Account a : Trigger.New)
        {
        	Account_Platform_Event__e eve = new Account_Platform_Event__e();
            eve.Account_Name__c = a.Name;
            eve.Phone__c = a.Phone;
            eve.Salary__c = a.AnnualRevenue;
            listOfAccount.add(eve);
        }
        if(listOfAccount.size() > 0)
        {
            EventBus.publish(listOfAccount);
        }
    }
}