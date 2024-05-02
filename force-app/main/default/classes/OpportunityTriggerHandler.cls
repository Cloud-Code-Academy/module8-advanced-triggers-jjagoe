public with sharing class OpportunityTriggerHandler extends TriggerHandler{
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> oldOppMap;
    private List<Opportunity> newOpps;
    private List<Opportunity> oldOpps;
           
    public OpportunityTriggerHandler() {
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOpps = (List<Opportunity>) Trigger.new;
        this.oldOpps = (List<Opportunity>) Trigger.old;


    }
    public override void beforeInsert() {
        OpportunityHelper.setDefaultType(newOpps);
    }

    public override void beforeUpdate() {
        OpportunityHelper.validateAmount(newOpps);
        OpportunityHelper.setPrimaryContact(newOpps);
        OpportunityHelper.appendStageChanges(newOpps, oldOppMap);
    }

    public override void beforeDelete() {
        OpportunityHelper.preventClosedWonOppDeletion(oldOpps);
    }
   
    public override void afterInsert() {
        OpportunityHelper.createNewTask(newOpps);
    }
    
   
    // Send email notifications when an Opportunity is deleted 
    public override void afterDelete() {
       OpportunityHelper.notifyOwnersOpportunityDeleted(this.oldOpps);
    }

    // Assign the primary contact to undeleted Opportunities
    public override void afterUndelete() {
        OpportunityHelper.assignPrimaryContact(this.newOppMap);
    }
}

