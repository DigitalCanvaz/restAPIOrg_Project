/**
 * @description Handler for Contact trigger events.
 * Sets Level__c to 'Primary' when LeadSource is 'Web' on insert/update.
 * Bulkified and uses early return pattern. Runs in user mode via DML-less before context.
 * @author Agentforce
 */
public with sharing class ContactTriggerHandler {
    /**
     * @description Enumerates supported trigger operations for clarity.
     */
    public enum OPERATION { BEFORE_INSERT, BEFORE_UPDATE }

    /**
     * @description Entry point for Contact trigger.
     * @param newList Trigger.new list of Contacts
     */
    public static void setLevelForWebLeadSource(List<Contact> newList) {
        if (newList == null || newList.isEmpty()) {
            return; // Return Early
        }

        if (Trigger.isInsert) {
            handleBeforeInsert(newList);
        } else if (Trigger.isUpdate) {
            handleBeforeUpdate(newList, (Map<Id, Contact>)Trigger.oldMap);
        }
    }

    /**
     * @description For new Contacts, if LeadSource == 'Web', set Level__c = 'Primary'.
     */
    private static void handleBeforeInsert(List<Contact> newList) {
        for (Contact c : newList) {
            // Only act when LeadSource is Web
            if (c.LeadSource == 'Web') {
                c.Level__c = 'Primary';
            }
        }
    }

    /**
     * @description For updates, if LeadSource is (or becomes) 'Web', set Level__c = 'Primary'.
     * Avoid unnecessary writes; only set when needed.
     */
    private static void handleBeforeUpdate(List<Contact> newList, Map<Id, Contact> oldMap) {
        if (oldMap == null || oldMap.isEmpty()) {
            return; // Safety
        }
        for (Contact c : newList) {
            Contact oldC = oldMap.get(c.Id);
            // When LeadSource becomes or remains Web, enforce Level__c = 'Primary'
            if (c.LeadSource == 'Web') {
                if (c.Level__c != 'Primary') {
                    c.Level__c = 'Primary';
                }
            }
        }
    }
}
