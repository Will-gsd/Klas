public class S2SAssignExternalController 
{
	public Apexpages.StandardController ctrl;
    public String nameSearch {get;set;}
    public String selectedUser {get;set;}

	public S2SAssignExternalController(Apexpages.StandardController controller) 
	{
		this.ctrl = controller;
	}
    
    public void saveRecord()
    {
        if (!String.isBlank(selectedUser))
        {
            User u = [SELECT Id, Name, Other_Org_18_Digit_Id__c FROM User WHERE Id = : selectedUser];
            SObject obj = ctrl.getRecord();
        	obj.put('External_Owner_Id__c', u.Other_Org_18_Digit_Id__c);
            obj.put('External_Owner_Id_Local_Record__c', u.Id);
            obj.put('External_Owner_Name__c', u.Name);
            
            try
            {
                update obj;
            }
            catch (DMLException e)
            {
                ApexPages.addMessages(e);
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a valid user'));
        }
    }
    
    public List<SelectOption> getExternalUsers()
    {
        List<SelectOption> options = new List<SelectOption>();
        List<User> users = new List<User>();
        
        for (User u : Database.query(queryString()))
        {
            users.add(u);
        }
        
        if (users.size() == 0)
        {
            options.add(new SelectOption('', '--No users found--', true));
        }
        else
        {
            options.add(new SelectOption('', '--Select one--'));
            for (User u : users)
            {
                options.add(new SelectOption(u.Id, u.Name));
            }
        }
        
        return options;
    }
    
    private String queryString()
    {
        String qs = 'SELECT Id, Name, Other_Org_18_Digit_Id__c ' +
            		'FROM User ' +
            		'WHERE Other_Org_18_Digit_Id__c != null ' +
            		'AND UserType != \'Standard\'' ;
        
       	if (!String.isBlank(nameSearch))
        {
            qs += 'AND Name LIKE \'%' + nameSearch + '%\' ';
        }
        
        qs += 'ORDER BY Name ASC LIMIT 1000';
        return qs;
    }
}