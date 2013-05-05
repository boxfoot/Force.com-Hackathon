public with sharing class ToolSearchPageController {


  // the soql without the order and limit
  public String soql {get;set;}
  private String qlisoql {get;set;}
  // the collection of tools to display
  public List<User> tools {get;set;}
 
  // the current sort direction. defaults to asc
  public String sortDir {
    get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
    set;
  }
  
  public String sortField {
    get  { if (sortField == null) {sortField = 'Id'; } return sortField;  }
    set;
  }
  
  public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 10'; }
    set;
  }
 
  // init the controller and display some sample data when the page loads
  public ToolSearchPageController() {
    soql = 'select Id, Active2__c, Username, LastName, FirstName, IsActive, SmallPhotoUrl, Contact.Account.Name, UserRole.Name from User where IsActive=false and Profile.Name LIKE \'%'+String.escapeSingleQuotes('Portal')+'%\'';
    
    runQuery();
  }
 
  // toggles the sorting of query from asc<-->desc
  public void toggleSort() {
    // simply toggle the direction
    sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
    // run the query again
    runQuery();
  }
 
  // runs the actual query
  public void runQuery() {
 
    try {
      setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql + ' order by ' + sortField + ' ' + sortDir + ' limit 10'));

      getUsers();
      
    } catch (Exception e) {
      
    }
  }

 
 
  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
 
    String acctname = Apexpages.currentPage().getParameters().get('acctname');
    
    System.debug('Account Name: '+ acctname);

    String ProfileValues = Apexpages.currentPage().getParameters().get('ProfileValues');

    if (ProfileValues=='InActive')
        btnName = 'Activate Users';
    else if (ProfileValues=='Active')
        btnName = 'Deactivate Users';
    
    String RoleValues = Apexpages.currentPage().getParameters().get('RoleValues');
    
    soql = 'select Id, Active__c, Username, LastName, FirstName, IsActive, SmallPhotoUrl, Contact.Account.Name, UserRole.Name from User where Profile.Name LIKE ' +  '\'%'+String.escapeSingleQuotes('Portal')+'%\'';
         
    if (!acctname.equals(''))
      soql += ' and Contact.Account.Name like \'%'+String.escapeSingleQuotes(acctname)+'%\'';
    if (ProfileValues.equals('InActive'))
      soql += ' and IsActive = FALSE';
    else
      soql += ' and IsActive = TRUE';
             
      if (!RoleValues.equals(''))
      soql += ' and UserRole.Name like \''+String.escapeSingleQuotes(RoleValues)+'%\'';
 
    runQuery();
 
    return null;
  }
 
  // use apex describe to build the picklist values
  public List<String> StatusToolValues {
    get {
      if (StatusToolValues == null) {
 
        StatusToolValues = new List<String>();
        Schema.DescribeFieldResult field = Tools__c.Status__c.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          StatusToolValues.add(f.getLabel());
 
      }
      return StatusToolValues;          
    }
    set;
  }
  
  // use apex describe to build the User Profile picklist values
  public List<String> ProfileValues {
    get {
      if (ProfileValues == null) {
 
        ProfileValues = new List<String>();
        Schema.DescribeFieldResult field = Profile.Name.getDescribe();
 
        for (Schema.PicklistEntry f : field.getPicklistValues())
          ProfileValues.add(f.getLabel());
 
      }
      return ProfileValues;          
    }
    set;
  }
  
  // use apex describe to build the User Role picklist values
  public List<String> RoleValues {
    get {
      List<String> listOfUserRoles = new List<String>();
      if (RoleValues == null) 
      {         
        for (UserRole userRoleName : [select Name from UserRole])
        {
            listOfUserRoles.add(userRoleName.Name);
        }
         
      }
      return listOfUserRoles;          
    }
    set;
  }

  public pageReference refresh() 
  {
       setCon = null;
       setCon.setPageSize(100);
       noOfRecords = setCon.getResultSize();
       return null;
  }

  public PageReference disableSelectedUsers() 
  {
      List<User> updatedUsers = new List<User>();
      for (User u : (List<User>) setCon.getRecords())
      {
          if (u.IsActive == true)
          {
            u.IsActive = true;
            updatedUsers.add(u);
          }
          else if (u.isActive == false)
          {
            u.IsActive = false;
            updatedUsers.add(u);
          }
      }
      update updatedUsers;
      setCon = null;
      return null;
  }

  Public Integer noOfRecords{get; set;}

  private String btnName = 'Activate Users';
  public String buttonName
  {
    get
    {
      return btnName;
    }
    set
    {
       btnName = value; 
    }

  }

  public ApexPages.StandardSetController setCon {
        get {
                if (setCon == null)
                {
                  setCon = new ApexPages.StandardSetController(Database.getQueryLocator(soql));
                
                  setCon.setPageSize(100);
                  noOfRecords = setCon.getResultSize();
                }

                return setCon;
        }
        set;
    }   

    public List<User> getUsers() {
        return (List<User>) setCon.getRecords();
    }
}