/**
 * Stolen and adapted from: https://github.com/pozil/sfdc-ui-lookup-lwc/blob/master/src-sample/main/default/classes/SampleLookupController.cls
 * Class used to serialize a single Lookup search result item
 * The Lookup controller returns a List<LookupSearchResult> when sending search result back to Lightning
 * Currently (Mar 2023) only used by the CashCustomLookupController.cls for Payee lookups on the CashPartyToPartyPayments LWC; NOT on the ICL.
 */
public virtual class LookupSearchResult implements Comparable {
    protected String id;
    protected String name;
    protected String recordTypeName;
    protected String sObjectType;
    protected String icon;
    protected String title;
    protected String subtitle;
    protected String cmNumber;
    protected String cmEmployerName;
    protected String accountShippingStreet;
    protected String accountEntityType;

    protected LookupSearchResult() {
    }

    /**
     * @param id the lookup entry identifier (generally a record ID)
     * @param sObjectType Optional - The sObject type of the selected record. This value is not used for lookup rendering. It's passed back to the selection handler in case you search on multiple object types.
     * @param icon Optional - A qualified SLDS icon name taken from https://www.lightningdesignsystem.com/icons. It defaults to standard:default.
     * @param title Required - The label of the lookup entry
     * @param subtitle Optional - A subtitle that is displayed under the lookup entry label
     */
    //TODO: For now this is DIR_Case__c focused. We may need to change parameter names to make this lookup more generic and reusable.
    public LookupSearchResult(String id, String name, String recordTypeName, String sObjectType, 
                String icon, String title, String subtitle,
                String cmNumber, String cmEmployerName, String accountShippingStreet, String accountEntityType) {
        this.id = id;
        this.name = name;
        this.recordTypeName = recordTypeName;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.cmNumber = cmNumber;
        this.cmEmployerName = cmEmployerName;
        this.accountShippingStreet = accountShippingStreet;
        this.accountEntityType = accountEntityType;
    }

    @AuraEnabled
    public String getId() {
        return id;
    }

    @AuraEnabled
    public String getName(){
        return name;
    }

    @AuraEnabled
    public String getRecordTypeName(){
        return recordTypeName;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }    
    
    @AuraEnabled
    public String getIcon() {
        return icon;
    }    
    
    @AuraEnabled
    public String getTitle() {
        return title;
    }    
    
    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }    
    
    @AuraEnabled
    public String getCmNumber(){
        return cmNumber;
    }    

    @AuraEnabled
    public String getCmEmployerName(){
        return cmEmployerName;
    }

    @AuraEnabled
    public String getAccountShippingStreet(){
        return accountShippingStreet;
    }

    @AuraEnabled
    public String getAccountEntityType(){
        return accountEntityType;
    }



    /**
     * Allow to sort search results based on title
     */
    public Integer compareTo(Object compareTo) {
        LookupSearchResult other = (LookupSearchResult) compareTo;
        if (this.getTitle() == null) {
            return (other.getTitle() == null) ? 0 : 1;
        }
        if (other.getTitle() == null) {
            return -1;
        }
        return this.getTitle().compareTo(other.getTitle());
    }
}