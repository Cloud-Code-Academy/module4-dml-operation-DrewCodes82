/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Drew Howard */

public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAcc = new Account(Name = 'Test Account 1234', Industry = 'Energy', Rating = 'Warm');

        // Set some fields on the Account

        // Insert the Account into the database
        if(Schema.sObjectType.Account.isCreateable()){
            insert newAcc;
        }
        // Return the Id of the newly created Account
        return newAcc.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAcc = new Account(Name = name, Industry = industry);
        // Insert the Account
        if(Schema.sObjectType.Account.isCreateable()){
            insert newAcc;
        }
        
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newCon = new Contact();

        // Set some fields on the Contact
        newCon.FirstName = 'Happy';
        newCon.LastName = 'Gilmore';
        newCon.Title = 'Pro Golfer and Angry Guy';
        // Set the AccountId field to the given accountId
        newCon.AccountId = accountId;

        // Insert the Contact into the database
        if(Schema.sObjectType.Contact.isCreateable()){
            insert newCon;
        }
        
        // Return the Id of the newly created Contact
        return newCon.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact con = [SELECT Id FROM Contact WHERE Id = :contactId WITH SECURITY_ENFORCED];

        // Update the Contact's last name
        con.LastName = newLastName;
        // Update the Contact in the database
        if(Schema.sObjectType.Contact.fields.LastName.isUpdateable()){
            update con;
        }
        

    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId WITH SECURITY_ENFORCED];

        // Update the Opportunity's stage
        opp.StageName = newStage;

        // Update the Opportunity in the database
        if(Schema.sObjectType.Opportunity.fields.StageName.isUpdateable()){
            update opp;
        }
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;

        if(Schema.sObjectType.Account.fields.Name.isUpdateable() && Schema.sObjectType.Account.fields.Industry.isUpdateable()){
            update acc;

        }
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for(Opportunity opp : opportunities){
            // Set the Opportunity's Stage to Qualification
            opp.StageName = 'Qualification';
            // Set the Opportunity's Close Date to 3 months from today
            opp.CloseDate = Date.today().addMonths(3);
            // Set the Opportunity's Amount to 50000
            opp.Amount = 50000;
        }   
        // Upsert the opportunities List so that records are either updated or created
        if(Schema.sObjectType.Opportunity.isCreateable() && Schema.sObjectType.Opportunity.isUpdateable()){
            upsert opportunities;
        }
    }

    /**
     * Question 8
     * Insert or update opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * HINT: There should not be duplicate opportunites based on the name
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Query to get Account where Name = accountName
        List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        // If an Account of that name doesn't exist, create one and commit to DB
        if(accList.isEmpty()){
            accList.add(new Account(Name = accountName));
            upsert accList;
            // Requery to get the AccountId
            accList = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
        }
        // Save the AccountId to a variable for later use in the Opps
        Id accId = accList[0].Id;
        // Create a map of Opps by Name
        Map<String, Opportunity> existingOppsByName = new Map<String, Opportunity>();
        // Check if Opps with the names in the oppNames List already exist, if so, add to the map.
        for (Opportunity opp : [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames AND AccountId = :accId]) {
            existingOppsByName.put(opp.Name, opp);
         }
        // Create a List of Opps to be Upserted
        List<Opportunity> oppsToUpsert = new List<Opportunity>();

        // Loop through each Opportunity name
        for(String name : oppNames){
            // Create an Opportunity with the given name
            Opportunity newOpp;
            if(existingOppsByName.containsKey(name)){
                // update existing opp if it exists
                newOpp = existingOppsByName.get(name);
            } else {
                // Create a new opp if they don't exist
                newOpp = new Opportunity(Name = name);
            }
            // Set values for required fields including the AccountId
            newOpp.StageName = 'Qualification';
            newOpp.CloseDate = Date.today().addMonths(3);
            newOpp.AccountId = accId;
            // Add the Opportunity to the list
            oppsToUpsert.add(newOpp);

        }
        // Commit the list of Opps to the DB
        upsert new List<Opportunity>(oppsToUpsert);
             
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];

		// if the Account exists, update the description
        if(!accounts.isEmpty()){
            accounts[0].Description = 'Updated Account';
        // otherwise, create a new Account and set the description
        } else {
            Account newAcc = new Account(Name = accountName, Description = 'New Account');
            accounts.add(newAcc);
        }
		// Upsert the Account
        upsert accounts;

		return accounts[0];
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact
        for (Contact con : contactsToUpsert){
            // Extract the Account Name from Contact's LastName
            String accName = con.LastName;
            // Get the account based on the name or create one if it doesn't exist
            Account acc = DMLOperations.upsertAccount(accName);
            // Link the Contact to its Account using the Account Id
            con.AccountId = acc.Id;
        }
		// Upsert the Contacts
        upsert contactsToUpsert;
	}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        List<Lead> leadsForInsert = new List<Lead>();
        // Loop through each Lead name
        for (String name : leadNames){
            Lead newLead = new Lead(LastName = name, Status = 'Open - Not Contacted', Company = 'TBD');
            leadsForInsert.add(newLead);
        }
        // Insert the Leads
        if(Schema.sObjectType.Lead.isCreateable()){
            insert leadsForInsert;
        }
        // Delete the Leads
        if(Schema.sObjectType.Lead.isDeletable()){
            delete leadsForInsert;
        }
        
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        List<Case> casesForInsert = new List<Case>();

        for (Integer i = 0; i < numOfCases; i++){
            Case newCase = new Case(AccountId = accountId, Status = 'New', Origin = 'Email');
            casesForInsert.add(newCase);
        }
        // Insert the cases
        if(Schema.sObjectType.Case.isCreateable()){
            insert casesForInsert;
        }
        
        // Delete the cases
        if(Schema.sObjectType.Case.isDeletable()){
            delete casesForInsert;
        }
    }
}