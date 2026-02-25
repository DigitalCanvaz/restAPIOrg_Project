public with sharing class BatchToInsertContentVersion implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    List<ContentVersion> cvList = new List<ContentVersion>();
    public BatchToInsertContentVersion(List<ContentVersion> cvList) {
        this.cvList = cvList;
    }

    public List<ContentVersion> start(Database.BatchableContext BC) {
        return cvList;
    }

    public void execute(Database.BatchableContext BC, List<ContentVersion> contentVersionList) {
        try {
            insert contentVersionList;
        } catch (Exception e) {
            System.debug('Error inserting ContentVersion: ' + e.getMessage());
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Insertion Completed');
    }
}