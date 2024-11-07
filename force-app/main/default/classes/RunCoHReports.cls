//Scheduled by the ScheduleCoHReports class, q.v.
public class RunCoHReports{
    
    public List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
    
    public void RunCoHReports(){
        
        Id orgWideEmailAddressId = [SELECT Id, DisplayName
                                    FROM OrgWideEmailAddress
                                    WHERE DisplayName = 'DIR SFDCdonotreply@dir.ca.gov'][0].Id;

        List<Office_Account__c> officeAccounts = [SELECT Id, Name, Deprecated__c, Office__c, Office__r.Name
                                                    FROM Office_Account__c
                                                    WHERE Deprecated__c = FALSE];
        
        //Map of CoH public group names to a list of Users' emails who receive that OA's CoH report.
        Map<String, List<String>> publicGroupEmails = new Map<String, List<String>>();
        
        // Get all Users in all the CoH public groups.
        List<User> users = [SELECT Id, Name, Email
                                FROM User
                                WHERE Id IN (SELECT UserOrGroupId 
                                                FROM GroupMember
                                                WHERE Group.Name LIKE '%CoH Report%')]; //all Public Groups are named "CoH Report - ****"
        // Get their Ids.
        List<Id> userIds = new List<Id>(new Map<Id, User>(users).keySet());
        
        // And now get Groupmember records.
        List<GroupMember> groupMembers = [SELECT Group.Name, UserOrGroupId
                                            FROM GroupMember
                                            WHERE UserOrGroupId IN :userIds];
        
        //Match User emails with the group they belong to.
        for(GroupMember groupMember : groupMembers){
            for(User cohUser : users){
                if(cohUser.Id == groupMember.UserOrGroupId){
                    if(publicGroupEmails.containsKey(groupMember.Group.Name)){
                        publicGroupEmails.get(groupMember.Group.Name).add(cohUser.Email);
                    }else{
                        publicGroupEmails.put(groupMember.Group.Name, new List<String>{cohUser.Email});
                    }
                }
            }
        }
        System.debug('publicGroupEmails: '+publicGroupEmails);
        
        
        for(Office_Account__c oa : officeAccounts){
            
            ApexPages.PageReference report = new ApexPages.PageReference('/apex/CashOnHandReportVFP?Id=' + oa.Id);
            
            List<String> emailAddresses = new List<String>();
            
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            
            attachment.setFileName('CoH ' + oa.Name + ' ' + oa.Office__r.Name + ' ' + Datetime.now().format('MMM yyyy') + '.pdf');
            
            if(!Test.isRunningTest()){
                attachment.setBody(report.getContentAsPDF());
            }else{
                attachment.setBody(Blob.valueOf('Unit.Test'));
            }
            
            attachment.setContentType('application/pdf');
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
            message.setSubject('CoH ' + oa.Name + ' ' + oa.Office__r.Name + ' ' + Datetime.now().format('MMM yyyy'));
            
            if(!Test.isRunningTest()){
                message.setHtmlBody(report.getContent().toString());
            }else{
                message.setHtmlBody('Unit.Test');
            }
            
            for(String groupName : publicGroupEmails.keySet()){
                if(groupName.contains(oa.Name)){
                    emailAddresses.addAll(publicGroupEmails.get(groupName));
                }
            }
            emailAddresses.addAll(publicGroupEmails.get('CoH Report - Base'));
            
            message.setToAddresses(emailAddresses);
            message.setOrgWideEmailAddressId(orgWideEmailAddressId);
            emailsToSend.add(message);
            
        }
        
        
        //and one last report for Cases that my not have an Office or Office Account
        ApexPages.PageReference report = new ApexPages.PageReference('/apex/CashOnHandReportOtherVFP');
        
        List<String> emailAddresses = new List<String>();
        
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        
        attachment.setFileName('CoH Other ' + Datetime.now().format('MMM yyyy') + '.pdf');
        
        if(!Test.isRunningTest()){
            attachment.setBody(report.getContentAsPDF());
        }else{
            attachment.setBody(Blob.valueOf('Unit.Test'));
        }
        
        attachment.setContentType('application/pdf');
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        message.setSubject('CoH Other ' + Datetime.now().format('MMM yyyy'));
        
        if(!Test.isRunningTest()){
            message.setHtmlBody(report.getContent().toString());
        }else{
            message.setHtmlBody('Unit.Test');
        }
        
        emailAddresses.addAll(publicGroupEmails.get('CoH Report - Base'));
        
        message.setToAddresses(emailAddresses);
        message.setOrgWideEmailAddressId(orgWideEmailAddressId);
        emailsToSend.add(message);
        
        
        if(!Test.isRunningTest()){
            Messaging.sendEmail(emailsToSend);
        }
        
    }
}