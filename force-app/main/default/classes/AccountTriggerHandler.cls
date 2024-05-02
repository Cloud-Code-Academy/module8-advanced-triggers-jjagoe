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
        //When an account is inserted change the account type to 'Prospect' if there is no value in the type field.
        //Trigger should only fire on insert.
        AccountHelper.setTypeProspect(newAccts);
        //When an account is inserted copy the shipping address to the billing address.
        //Trigger should only fire on insert.
        AccountHelper.addressCopy(newAccts);
        //When an account is inserted set the rating to 'Hot' if the Phone, Website, and Fax is not empty.
        //Trigger should only fire on insert.
        AccountHelper.setRating(newAccts);
    }

    public override void afterInsert() {
        //When an account is inserted create a contact related to the account with the following default values:
        //LastName = 'DefaultContact'
        //Email = 'default@email.com'
        //Trigger should only fire on insert. 
        AccountHelper.defaultContact(newAccts);
    }
}