@isTest(isParallel=true)
public class LookupSearchResultTest{
    @isTest
    static void compareTo_should_work_with_two_null_titles() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(0, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_this_null_title() {
        LookupSearchResult r1 = getSearchResult(null);
        LookupSearchResult r2 = getSearchResult('a');

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(1, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_other_null_title() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult(null);

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(-1, compareResult);
    }

    @isTest
    static void compareTo_should_work_with_non_null_titles() {
        LookupSearchResult r1 = getSearchResult('a');
        LookupSearchResult r2 = getSearchResult('b');

        Integer compareResult = r1.compareTo(r2);

        Assert.areEqual(-1, compareResult);
    }

    @isTest
    static void getters_should_work() {
        // For the sake of code coverage
        LookupSearchResult r = new LookupSearchResult('0010R00000yvEyRQAU', 'name', 'recordTypeName', 'type', 'icon', 'title', 'subtitle', 'cmNumber', 'cmEmployerName', 'accountShippingStreet', 'accountEntityType');

        Assert.areEqual('0010R00000yvEyRQAU', r.getId());
        Assert.areEqual('type', r.getSObjectType());
        Assert.areEqual('icon', r.getIcon());
        Assert.areEqual('title', r.getTitle());
        Assert.areEqual('subtitle', r.getSubtitle());
        Assert.areEqual('cmNumber', r.getCmNumber());
        Assert.areEqual('cmEmployerName', r.getCmEmployerName());
        Assert.areEqual('accountShippingStreet', r.getAccountShippingStreet());
        Assert.areEqual('accountEntityType', r.getAccountEntityType());
    }

    private static LookupSearchResult getSearchResult(String title) {
        // LookupSearchResult(String id, String name, String recordTypeName, String sObjectType, String icon, String title, String subtitle, String cmNumber, String cmEmployerName, String accountShippingStreet, String accountEntityType)
        return new LookupSearchResult(null, null, null, null, null, title, null, null, null, null, null);
    }
}