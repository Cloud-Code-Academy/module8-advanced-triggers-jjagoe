/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
    
    public static void setTypeProspect(List<Account> acctNull){
        for (Account acc : acctNull) {
            if (acc.Type == null) {
                acc.Type = 'Prospect';
            }
        }
    }

    public static void addressCopy(List<Account> acctAddress){
        for(Account account : acctAddress) {
            //Use null-coalescing operator ??, which returns the left-hand operand if it's not null, 
            //otherwise it returns the right-hand operand.
            account.BillingStreet = account.ShippingStreet ?? '';
            account.BillingCity = account.ShippingCity ?? '';
            account.BillingState = account.ShippingState ?? '';
            account.BillingPostalCode = account.ShippingPostalCode ?? '';
            account.BillingCountry = account.ShippingCountry ?? '';
    }
}

    public static void setRating (List<Account> acctRating) {
        for (Account acc : acctRating) {
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                acc.Rating = 'Hot';
            }
        }
    }

    public static void defaultContact (List<Account> acctContacts) {
        List<Contact> newContacts = new List<Contact>();
        for(Account acc : acctContacts) {
            // Create a new contact with default values
            newContacts.add(new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = acc.Id));
          
        }
       
       // Insert the new contacts
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.DuplicateRuleHeader.AllowSave = true;
        dml.DuplicateRuleHeader.RunAsCurrentUser = true;
        Database.insert(newContacts, dml);
      } 
    }
