/*
* Test class for PossibleNowIntergrationCalls
* */

@isTest
public class PossibleNowIntegrationTest {  
    @testSetup
    static void methodName(){

        Profile pf = [Select Id, Name from Profile where Name='Contact Center User' limit 1];
        User u = new User(Alias = 'standt', Email='ravikant@mirketa.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = pf.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='CCUserMirketa001@gmail.com');  
        insert u; 
        List<Integration_Credentials__c> iclist = new List<Integration_Credentials__c>();

        Integration_Credentials__c i=new Integration_Credentials__c(Name='GeneralEnquiry',Endpoint__c='https://staging.dncsolution.com/Rest'
                                                                    ,AuthProfileID__c='3067',
                                                                    ClientId__c='17774',
                                                                    userID__c='509273'
                                                                   );

        Integration_Credentials__c i1=new Integration_Credentials__c(Name='ExpressEnquiry',Endpoint__c='https://staging.dncsolution.com/Rest'
                                                                     ,AuthProfileID__c='3068',
                                                                     ClientId__c='17774',
                                                                     userID__c='509273'
                                                                    );
        Integration_Credentials__c i2=new Integration_Credentials__c(Name='Zovio Azure',Endpoint__c='https://devsalesforceappwussb.servicebus.windows.net'
                                                                     ,Key__c='dZCvW3If21A3QA3Zu3uHFd7IfufRQShXSxwQR1o0OM4=',KeyName__c='SalesForceEventAdapter',TopicOrQueueName__c='sfeventingleadtp'
                                                                    );
        iclist.add(i);
        iclist.add(i1);
        iclist.add(i2);

        insert iclist;
        List<lead> li=new List<Lead>();
        List<Contact> ci=new List<Contact>();

        Lead l=new Lead(Firstname='Mirketa',Lastname='Zovio',company='Zovio');
        l.Leadchannelcode__c='AGL';
        l.LeadTargetID__c='AU';
        l.Phone='5628880275';
        l.MobilePhone='6786027574';
        l.Work_Phone__c='7703391766';
        l.ConsenttoCallPhone__c='PEWC';
        l.ConsenttoCallMobile__c='PEWC';
        l.PhoneStatus__c='NEW';
        l.Phone_Good_Till__c=system.today();
        l.PhoneWireless__c=True;
        l.Mobile_Good_Till__c=System.today();
        l.WorkPhoneWireless__c=True;
        l.ConsenttoCallWorkPhone__c='PEWC';
        l.FirstName='leadFirstName';
        l.LastName='LastName';
        l.Company='Zovio';
        l.Email='test@mirketa.com'; 
        l.Area_of_Interest__c='Accounting & Finance';
        l.State='Arizona';
        l.Org_Code__c='Ashford';
        l.LeadSource='Live Chat';
        l.Program__c='Associates - Education';
        l.DSCORGPKG__DO_3yr_Employees_Growth__c='discovery';   
        l.OwnerId=u.Id;
        String srcRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SRC_Lead').getRecordTypeId();
        system.debug('Recordtype id'+srcRecordTypeId); 
        l.RecordTypeId=srcRecordTypeId; 
        li.add(l);
        insert li; 
        Contact c=new Contact(FirstName='Zovio', LastName='TestNew');
        c.Phone='5628880275';
        c.ConsenttoCallPhone__c='PEC';
        c.MobilePhone__c='6786027574';
        c.ConsenttoCallMobile__c='PEC';
        c.hed__WorkPhone__c='7703391766';
        c.ConsenttoCallWorkPhone__c='PEC';
        ci.add(c);
        insert ci;
    }
    @isTest
    public static void InsertLead() {

        test.startTest(); 
        Test.setMock(HttpcalloutMock.class, new PossibleNowIntegrationMockTest()); 
        Test.setMock(HttpcalloutMock.class, new SFDC2LFSIntegrationMockTest()); 
        user u2 = [SELECT id,profile.Name,profile.Id from User WHERE username = 'CCUserMirketa001@gmail.com' LIMIT 1]; 
        system.debug('user outside'+u2 + ' Profile name'+ u2.Profile.name);

        System.runAs(u2) { 

            Lead l=new Lead(Firstname='Ghanshyam',Lastname='Bhatt',company='MirketaInc');
            l.Leadchannelcode__c='AGL';
            l.LeadTargetID__c='AU';
            l.Phone='5628880275';
            l.MobilePhone='6786027574';
            l.Work_Phone__c='7703391766';
            l.ConsenttoCallPhone__c='PEWC';
        	l.ConsenttoCallMobile__c='PEWC';
            l.PhoneStatus__c='NEW';
            l.ConsenttoCallWorkPhone__c='PEWC';
            l.Email='test@mirketa.com'; 
            l.Area_of_Interest__c='Accounting & Finance';
            l.State='Arizona';
        	l.Org_Code__c='Ashford';
            l.LeadSource='Live Chat';
            l.Program__c='Associates - Education';
            l.DSCORGPKG__DO_3yr_Employees_Growth__c='discovery';   

            insert l;

            system.debug('user inside run as'+ u2 + ' -'+u2.Profile.Name);
            List<Lead> le=[select id,Name,phone,firstName,LastName,Work_Phone__c,ConsenttoCallMobile__c,Leadchannelcode__c,LeadTargetID__c,ConsenttoCallPhone__c,MobilePhone,WorkPhoneWireless__c,ConsenttoCallWorkPhone__c,company from Lead where LastName='LastName'];
            system.debug('iLi --> '+le); 
            le[0].company='Mirketa';
            update le;
            SaleforceToLFSCalls.sendDataToLFS(le[0].Id);
            le[0].lastname='lastnameUpdate';
            le[0].Phone='7703391766';
            le[0].MobilePhone='5628880275';
            le[0].Work_Phone__c='6786027574';

            update le;
            LeadWrapperClass generalEnquiryWrapper = PossibleNowIntegrationHelper.getGeneralEnquiryWrapper(le[0]);
            LeadWrapperClass expreeEnquiryWrapper = PossibleNowIntegrationHelper.getExpressEnquiryWrapper(le[0]);


        }
        Test.stopTest();

    }  
	public static testmethod void callPossiblemethod(){  
        test.startTest(); 
        Test.setMock(HttpcalloutMock.class, new PossibleNowIntegrationMockTest());
         List<Contact> cle=[select id,Name,phone,firstName,LastName,hed__WorkPhone__c,ConsenttoCallMobile__c,ConsenttoCallPhone__c,MobilePhone__c,WorkPhoneWireless__c,ConsenttoCallWorkPhone__c from Contact where LastName='TestNew'];
        List<Lead> le=[select id,Name,phone,firstName,LastName,Work_Phone__c,ConsenttoCallMobile__c,Leadchannelcode__c,LeadTargetID__c,ConsenttoCallPhone__c,MobilePhone,WorkPhoneWireless__c,ConsenttoCallWorkPhone__c,company from Lead where LastName='LastName'];
        system.debug('iLi --> '+le); 
        le[0].company='Mirketa';
        update le;  

        cle[0].lastname='lastnameUpdate';
        cle[0].Phone='7703391766';
        cle[0].MobilePhone__c='5628880275';
        cle[0].hed__WorkPhone__c='6786027574';
        update cle;

        LeadWrapperClass generalEnquiryWrapper = PossibleNowIntegrationHelper.getGeneralEnquiryWrapper(le[0]);
        LeadWrapperClass expreeEnquiryWrapper = PossibleNowIntegrationHelper.getExpressEnquiryWrapper(le[0]);

        PossibleNowIntergrationCalls.validateFromPossibleNow(generalEnquiryWrapper,'GeneralEnquiry');
        PossibleNowIntergrationCalls.validateFromPossibleNow(expreeEnquiryWrapper,'ExpressEnquiry'); 

        LeadWrapperClass generalEnquiryWrapper1 = PossibleNowIntegrationHelper.getContactGeneralEnquiryWrapper(cle[0]);
        LeadWrapperClass expreeEnquiryWrapper1 = PossibleNowIntegrationHelper.getContactExpressEnquiryWrapper(cle[0]);
        PossibleNowIntergrationCalls.validateFromPossibleNow(generalEnquiryWrapper1,'GeneralEnquiry');
        PossibleNowIntergrationCalls.validateFromPossibleNow(expreeEnquiryWrapper1,'ExpressEnquiry'); 

        test.stopTest();

    } 
    public static testmethod void testSend(){
        test.startTest();
        Test.setMock(HttpcalloutMock.class, new PossibleNowIntegrationMockTest());
        List<Lead> le=[select id,Name,phone,firstName,LastName,Work_Phone__c,ConsenttoCallMobile__c,Leadchannelcode__c,LeadTargetID__c,ConsenttoCallPhone__c,MobilePhone,WorkPhoneWireless__c,ConsenttoCallWorkPhone__c,company from Lead where LastName='LastName'];

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
        String serialPhoneFieldMapString = '{"6786027574":["Mobile_Good_Till__c","MobileWireless__c","ConsenttoCallMobile__c"],"5628880275":["Phone_Good_Till__c","PhoneWireless__c","ConsenttoCallPhone__c"],"7703391766":["Work_Phone_Good_Till__c","WorkPhoneWireless__c","ConsenttoCallWorkPhone__c"]}';
        String serialConsentMapString = '{"6786027574":"PEWC","5628880275":"PEWC","7703391766":"PEWC"}';
        String url='https://staging.dncsolution.com/Rest/17774/QuickCheckEBR/509273/3067/Phone?EBRDataList[0]=5628880275,'+stringDate+'&EBRDataList[1]=6786027574,'+stringDate+'&EBRDataList[2]=7703391766,'+stringDate+'';

        PossibleNowIntergrationCalls.sendRequest(le[0].Id,url,serialPhoneFieldMapString,serialConsentMapString);
        test.stopTest();
    }

}