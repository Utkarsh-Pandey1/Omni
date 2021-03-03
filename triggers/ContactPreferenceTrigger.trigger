trigger ContactPreferenceTrigger on Contact (after insert,after update) {
    
    list<Contact> ctslist =trigger.new;   
    if(Trigger.isAfter && Trigger.isInsert){                        // After Insert
        if(!System.Isbatch() || !System.isFuture()) {
            Profile pf = [Select Id, Name from Profile where id =:UserInfo.getProfileId()];   
           // datetime cd = ctslist.get(0).Lead_Created_Date__c;
           // Date myDate= cd.date();
            if(ctslist.size() == 1 
               && 
               (ctslist.get(0).Phone !=null || ctslist.get(0).MobilePhone__c !=null || ctslist.get(0).hed__WorkPhone__c !=null )
 
               &&
               (pf != null && (pf.Name == 'SRC Lead User' || pf.Name == 'Contact Center User'  || pf.Name == 'Student Response Center User' || pf.Name == 'System Administrator'))
              ) {
                  LeadWrapperClass generalEnquiryWrapper = PossibleNowIntegrationHelper.getContactGeneralEnquiryWrapper(ctslist.get(0));
                  LeadWrapperClass expressEnquiryWrapper = PossibleNowIntegrationHelper.getContactExpressEnquiryWrapper(ctslist.get(0));
                  
                  if(String.isNotBlank(generalEnquiryWrapper.Phone)
                     || 
                     String.isNotBlank(generalEnquiryWrapper.Mobile) 
                     || 
                     String.isNotBlank(generalEnquiryWrapper.WorkPhone)
                    )
                  {     
                       PossibleNowIntergrationCalls.validateFromPossibleNow(generalEnquiryWrapper,'GeneralEnquiry');
                  }   
                  if(String.isNotBlank(expressEnquiryWrapper.Phone)
                     || 
                     String.isNotBlank(expressEnquiryWrapper.Mobile) 
                     || 
                     String.isNotBlank(expressEnquiryWrapper.WorkPhone)
                    ) 
                  {
                     PossibleNowIntergrationCalls.validateFromPossibleNow(expressEnquiryWrapper,'ExpressEnquiry');
                  }
              }
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){     // After Update
        Map<ID,Contact> oldMap = Trigger.oldMap;
        Map<ID,Contact> newMap = Trigger.newMap;
        
        if(!System.Isbatch() || !System.isFuture()) {
            Profile pf = [Select Id, Name from Profile where id =:UserInfo.getProfileId()];    
            if(newMap.size() == 1 
               && 
               (
                   (newMap.values().get(0).Phone !=null && (newMap.values().get(0).Phone != oldMap.values().get(0).Phone))
                   || 
                   (newMap.values().get(0).Phone !=null && (newMap.values().get(0).ConsenttoCallPhone__c != oldMap.values().get(0).ConsenttoCallPhone__c))
                   ||
                   (newMap.values().get(0).MobilePhone__c !=null && (newMap.values().get(0).MobilePhone__c != oldMap.values().get(0).MobilePhone__c))
                   || 
                   (newMap.values().get(0).MobilePhone__c !=null && (newMap.values().get(0).ConsenttoCallMobile__c != oldMap.values().get(0).ConsenttoCallMobile__c))
                   ||
                   (newMap.values().get(0).hed__WorkPhone__c !=null && (newMap.values().get(0).hed__WorkPhone__c != oldMap.values().get(0).hed__WorkPhone__c))
                   || 
                   (newMap.values().get(0).hed__WorkPhone__c !=null && (newMap.values().get(0).ConsenttoCallWorkPhone__c != oldMap.values().get(0).ConsenttoCallWorkPhone__c))
               )
               &&
               (pf != null && (pf.Name == 'SRC Lead User' || pf.Name == 'Contact Center User'  || pf.Name == 'Student Response Center User' || pf.Name == 'System Administrator'))
              ) 
            {
                LeadWrapperClass generalEnquiryWrapper = PossibleNowIntegrationHelper.getContactGeneralEnquiryWrapper(newMap.values().get(0));
                LeadWrapperClass expressEnquiryWrapper = PossibleNowIntegrationHelper.getContactExpressEnquiryWrapper(newMap.values().get(0));
                if(String.isNotBlank(generalEnquiryWrapper.Phone) 
                   || 
                   String.isNotBlank(generalEnquiryWrapper.Mobile) 
                   || 
                   String.isNotBlank(generalEnquiryWrapper.WorkPhone)
                  ) {
                      PossibleNowIntergrationCalls.validateFromPossibleNow(generalEnquiryWrapper,'GeneralEnquiry');
                  }  
                if(String.isNotBlank(expressEnquiryWrapper.Phone) 
                   || 
                   String.isNotBlank(expressEnquiryWrapper.Mobile) 
                   || 
                   String.isNotBlank(expressEnquiryWrapper.WorkPhone)
                  ) {
                      PossibleNowIntergrationCalls.validateFromPossibleNow(expressEnquiryWrapper,'ExpressEnquiry');
                  }
            }
        }
    }
}