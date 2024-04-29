public with sharing class AccountTriggerHandler extends TriggerHandler {

    private Map<Id, Account> newAccMap;
    private Map<Id, Account> oldAccMap;
    private List<Account> newAccts;
    private List<Account> oldAccts;

    public AccountTriggerHandler() {
        this.newAccMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccMap = (Map<Id, Account>) Trigger.oldMap;
        this.newAccts = (List<Account>) Trigger.new;
        this.oldAccts = (List<Account>) Trigger.old;
    }

    public override void beforeInsert() {
        AccountHelper.setTypeProspect(newAccts);
        AccountHelper.addressCopy(newAccts);
        AccountHelper.setRating(newAccts);
    }

    public override void afterInsert() {
        AccountHelper.defaultContact(newAccts);
    }
}