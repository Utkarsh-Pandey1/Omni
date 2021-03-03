public class PossibleNowIntegrationHelper {
    public static Integration_Credentials__c getCredentials(String enquiryType) {
        return [Select id, Name , Endpoint__c , AuthProfileID__c, ClientID__c,UserID__c from Integration_Credentials__c 
                where Name =:enquiryType];
    }
    
    public static HttpResponse send(String endPoint){
        Http htp = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(endpoint);
        HttpResponse res = htp.send(req);
        return res;
    }
    public static LeadWrapperClass getGeneralEnquiryWrapper(Lead lead) {
        LeadWrapperClass enquiryWrapper = new LeadWrapperClass();
        enquiryWrapper.leadId = lead.Id;
        if(lead.Phone != null && lead.ConsenttoCallPhone__c != 'PEWC') {
            enquiryWrapper.Phone = lead.Phone;
            enquiryWrapper.PhoneConsent = lead.ConsenttoCallPhone__c;
        }
        if(lead.MobilePhone != null && lead.ConsenttoCallMobile__c != 'PEWC') {
            enquiryWrapper.Mobile = lead.MobilePhone;
            enquiryWrapper.MobileConsent = lead.ConsenttoCallMobile__c;
        }
        if(lead.Work_Phone__c != null && lead.ConsenttoCallWorkPhone__c != 'PEWC') {
            enquiryWrapper.WorkPhone = lead.Work_Phone__c;
            enquiryWrapper.WorkPhoneConsent = lead.ConsenttoCallWorkPhone__c;
        }
        return enquiryWrapper;
    }
    
    public static LeadWrapperClass getExpressEnquiryWrapper(Lead lead) {
        LeadWrapperClass enquiryWrapper = new LeadWrapperClass();
        enquiryWrapper.leadId = lead.Id;
        if(lead.Phone != null && lead.ConsenttoCallPhone__c == 'PEWC') {
            enquiryWrapper.Phone = lead.Phone;
            enquiryWrapper.PhoneConsent = lead.ConsenttoCallPhone__c;
        }
        if(lead.MobilePhone != null && lead.ConsenttoCallMobile__c == 'PEWC') {
            enquiryWrapper.Mobile = lead.MobilePhone;
            enquiryWrapper.MobileConsent = lead.ConsenttoCallMobile__c;
        }
        if(lead.Work_Phone__c != null && lead.ConsenttoCallWorkPhone__c == 'PEWC') {
            enquiryWrapper.WorkPhone = lead.Work_Phone__c;
            enquiryWrapper.WorkPhoneConsent = lead.ConsenttoCallWorkPhone__c;
        }
        return enquiryWrapper;
    }
    public static LeadWrapperClass getContactGeneralEnquiryWrapper(Contact contact) {
        system.debug('contact general Enquiry wrapper');
        
        LeadWrapperClass enquiryWrapper = new LeadWrapperClass();
        enquiryWrapper.leadId = contact.Id;
        if(contact.Phone != null && contact.ConsenttoCallPhone__c == 'PEC') {
            enquiryWrapper.Phone = contact.Phone;
            enquiryWrapper.PhoneConsent = contact.ConsenttoCallPhone__c;
        }
        if(contact.MobilePhone__c != null && contact.ConsenttoCallMobile__c == 'PEC') {
            enquiryWrapper.Mobile = contact.MobilePhone__c;
            enquiryWrapper.MobileConsent = contact.ConsenttoCallMobile__c;
        }
        if(contact.hed__WorkPhone__c != null && contact.ConsenttoCallWorkPhone__c == 'PEC') {
            enquiryWrapper.WorkPhone = contact.hed__WorkPhone__c;
            enquiryWrapper.WorkPhoneConsent = contact.ConsenttoCallWorkPhone__c;
        }
        return enquiryWrapper;
    }
    public static LeadWrapperClass getContactExpressEnquiryWrapper(Contact contact) {
        LeadWrapperClass enquiryWrapper = new LeadWrapperClass();
        enquiryWrapper.leadId = contact.Id;
        if(contact.Phone != null && contact.ConsenttoCallPhone__c == 'PEWC') {
            enquiryWrapper.Phone = contact.Phone;
            enquiryWrapper.PhoneConsent = contact.ConsenttoCallPhone__c;
        }
        if(contact.MobilePhone__c != null && contact.ConsenttoCallMobile__c == 'PEWC') {
            enquiryWrapper.Mobile = contact.MobilePhone__c;
            enquiryWrapper.MobileConsent = contact.ConsenttoCallMobile__c;
        }
        if(contact.hed__WorkPhone__c != null && contact.ConsenttoCallWorkPhone__c == 'PEWC') {
            enquiryWrapper.WorkPhone = contact.hed__WorkPhone__c;
            enquiryWrapper.WorkPhoneConsent = contact.ConsenttoCallWorkPhone__c;
        }
        return enquiryWrapper;
    }
    
}