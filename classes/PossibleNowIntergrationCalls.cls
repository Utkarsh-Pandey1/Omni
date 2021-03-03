public class PossibleNowIntergrationCalls {
    public static void validateFromPossibleNow(LeadWrapperClass lead,String enquiryType) {
        Integration_Credentials__c creds = PossibleNowIntegrationHelper.getCredentials(enquiryType);
        String endPoint = creds.Endpoint__c+'/'+creds.ClientID__c+'/QuickCheckEBR/'+creds.UserID__c
            +'/'+creds.AuthProfileID__c+'/Phone?';
        String month = ''+Date.today().month();
        String day = ''+Date.today().day();
        String year = ''+Date.today().year();
        if(day.length() == 1) {
            day = '0'+day;
        }
        if(month.length() == 1) {
            month = '0'+month;
        }
        String stringDate = month+day+year;
        Map<String,String> requestParameter = new Map<String,String>();
        String serializedMap = '';
        String serializedMapforDNCStatus = '';
        
        Map<String,List<String>> phoneFieldMap = new Map<String,List<String>>();
        Map<String,String> phoneTODNCMap = new Map<String,String>();
        
        if(lead.Phone != null) {
            requestParameter.put(lead.Phone,lead.Phone+','+stringDate);
            List<String> phoneList = new List<String>();
            phoneList.add('Phone_Good_Till__c');
            phoneList.add('PhoneWireless__c');
            phoneList.add('ConsenttoCallPhone__c');
            
            phoneFieldMap.put(lead.Phone,phoneList);
            phoneToDNCMap.put(lead.Phone,lead.PhoneConsent);
        }
        if(lead.Mobile != null) {
            requestParameter.put(lead.Mobile, lead.Mobile +','+stringDate);
            List<String> mobileList = new List<String>();
            mobileList.add('Mobile_Good_Till__c');
            mobileList.add('MobileWireless__c');
            mobileList.add('ConsenttoCallMobile__c');
            
            phoneFieldMap.put(lead.Mobile,mobileList);
            phoneToDNCMap.put(lead.Mobile,lead.MobileConsent);
        }
        if(lead.WorkPhone != null) {
            requestParameter.put(lead.WorkPhone, lead.WorkPhone+','+stringDate);
            List<String> workphoneList = new List<String>();
            workphoneList.add('Work_Phone_Good_Till__c');
            workphoneList.add('WorkPhoneWireless__c');
            workphoneList.add('ConsenttoCallWorkPhone__c');
            
            phoneFieldMap.put(lead.WorkPhone,workphoneList);
            phoneToDNCMap.put(lead.WorkPhone,lead.WorkPhoneConsent);
        }
        
        String endPointFilter='';
        if(requestParameter.values().size() > 0) {
            Integer i = 0;
            for(String str : requestParameter.values()) {
                str = str.removeEnd(',');
                endPointFilter = endPointFilter + 'EBRDataList['+i+']='+str;
                endPointFilter = endPointFilter + '&';
                i++;
            }
            endPointFilter = endPointFilter.removeEnd('&');
        }
        endPoint = endPoint + endPointFilter;
        if(phoneFieldMap.size() > 0) {
            serializedMap = JSON.serialize(phoneFieldMap);
        }
        if(phoneToDNCMap.size() > 0) {
            serializedMapforDNCStatus = JSON.serialize(phoneToDNCMap);
        }
        System.enqueueJob(new PossibleNowRESTAPIQueueable(lead.leadId,endPoint,serializedMap,SerializedMapforDNCStatus));
    }
    
    public static void sendRequest(Id leadId, String endPoint,String serializedMapofList,String serializedMapforDNCStatus){
        sObject newLead = null;
        try {
            HttpResponse res = PossibleNowIntegrationHelper.send(endPoint);
            String body = res.getBody();
            Date newDate = null;
            String DNCStatus = '';
            boolean wirelessFlag = false;
            String phoneNumber = null;
            Map<String,List<String>> phoneMapList = null;
            Map<String,String> phoneToDNCMap = null;
            if(String.isNotBlank(serializedMapofList)) {
                phoneMapList = (Map<String,List<String>>)JSON.deserialize(serializedMapofList,
                                                                          Map<String,List<String>>.class);
            }
            if(String.isNotBlank(serializedMapforDNCStatus)) {
                phoneToDNCMap = (Map<String,String>)JSON.deserialize(serializedMapforDNCStatus,Map<String,String>.class);
            }
            
            if(res.getStatusCode() == 200){
                
                body = body.removeStart('{"EBRScrubbedResults":');
                body = body.removeEnd('}');
                String sobjectType = leadId.getSObjectType().getDescribe().getName();
                Schema.sObjectType objectDef = Schema.getGlobalDescribe().get(sobjectType).getDescribe().getSObjectType();
                newLead = objectDef.newSobject(leadId);
                //newLead = sObject.put('id',leadId);
                
                List<PossibleNowBean> pnList = (List<PossibleNowBean>)JSON.deserialize(body, List<PossibleNowBean>.class);
                for(PossibleNowBean pnb : pnList){
                    wirelessFlag = false;
                    phoneNumber = pnb.PhoneNumber;
                    String goodThruDate = pnb.EBRStatus.GoodThruDate;
                    DNCStatus = '';
                    if(phoneToDNCMap.size()>0) {
                        DNCStatus = phoneToDNCMap.get(phoneNumber);
                    }
                    if(String.isNotBlank(pnb.Status) && pnb.Status == 'DNC'){
                        DNCStatus = 'No';
                    }
                    List<Filters> filterList = pnb.Filters;
                    if(filterList != null && filterList.Size() > 0) {
                        for(Filters f : filterList) {
                            if(f.Flag != null && f.Flag == 'WIR' ) {
                                wirelessFlag = true;
                            }
                        }
                    }
                    if(String.isNotBlank(goodThruDate)) {
                        List<String> dateComponent = goodThruDate.split('/');
                        newDate = Date.newInstance(Integer.valueOf(dateComponent.get(2)), Integer.valueOf(dateComponent.get(0)),
                                                   Integer.valueOf(dateComponent.get(1)));
                    }
                    if(phoneMapList.size() > 0) {
                        List<String> tempList =  phoneMapList.get(phoneNumber);       
                        if(tempList !=  null && tempList.size() > 0) {
                            newLead.put(tempList.get(0),newDate);
                            newLead.put(tempList.get(1),wirelessFlag);
                            newLead.put(tempList.get(2),DNCStatus);
                        }
                    }
                }
                System.debug('Lead for Update :' + newLead);
                if(newLead != null || newLead.id != null) {
                    update newLead;  
                }
            }
            else if(res.getStatusCode() == 400){ 
                body = res.getBody();
                System.debug('Some numbers are detected as Invalid. Please put correct phone number.');
            }
        }
        catch(Exception ex) {
            System.debug('Exception Occurred :' + ex);
        }
    }

}