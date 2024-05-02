public with sharing class OpportunityHelper {

     // Set the default Type for new opportunities
    public static void setDefaultType(List<Opportunity> newOpps){
        for (Opportunity opp : newOpps) {
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }
    }

    // When an opportunity is updated validate that the amount is greater than 5000.
    public static void validateAmount(List<Opportunity> newOpps) {
        for(Opportunity opp : newOpps){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    // When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.
    public static void setPrimaryContact(List<Opportunity> newOpps) {
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : newOpps){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId
                                                            FROM Contact
                                                            WHERE AccountId IN :accountIds AND Title = 'CEO'
                                                            ORDER BY FirstName ASC]);
        
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();
        
        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }
        
        for(Opportunity opp : newOpps){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }

    // Append Stage changes in Opportunity Description
    public static void appendStageChanges(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap) {
        for (Opportunity opp : newOpps) {
            // Get old Opportunity
            Opportunity oldOpp = oldOppsMap.get(opp.Id);
            if (opp.StageName != null && oldOpp.StageName != opp.StageName){
                opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
            }
        }
    }

    public static void preventClosedWonOppDeletion(List<Opportunity> oldOpps) {
        for(Opportunity opp : oldOpps) {
            if (opp.IsClosed) {
                opp.addError('Cannot delete closed opportunity');
            }
        }
    }

    // Create a new Task for newly inserted Opportunities
    public static void createNewTask(List<Opportunity> newOpps) {
        List<Task> newTasks = new List<Task>();
        for (Opportunity opp : newOpps){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            newTasks.add(tsk);
        }
        insert(newTasks);
    }
    
    //notifyOwnersOpportunityDeleted:
    // Sends an email notification to the owner of the Opportunity when it gets deleted.
    // Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    
    public static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Set<Id> userIds = new Set<Id>();

        for (Opportunity oppDeleted : opps) {
            userIds.add(oppDeleted.OwnerId);
        }

        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Email FROM User WHERE Id IN :userIds]);

        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> toAddresses = new List<String>();
            toAddresses.add(UserMap.get(opp.OwnerId).Email);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    
    // assignPrimaryContact:
    // Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    // Only updates the Opportunities that don't already have a primary contact.
    
    public static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {

        Set<Id> accIds = new Set<Id>();
        for (Opportunity opp : oppNewMap.values()) {
            accIds.add(opp.AccountId);
        }

        List<Contact> primaryContacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Title = 'VP Sales' AND AccountId
            IN :accIds
            ];
        Map<Id,Contact> accIdContactMap = new Map<Id,Contact>();
        for (Contact cont : primaryContacts) {
            accIdContactMap.put(cont.AccountId, cont);
        }
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Opportunity opp : oppNewMap.values()){            
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = accIdContactMap.get(opp.AccountId).Id;
                oppsToUpdate.add(oppToUpdate);
            }
        }
        update oppsToUpdate;
    }
}
    

