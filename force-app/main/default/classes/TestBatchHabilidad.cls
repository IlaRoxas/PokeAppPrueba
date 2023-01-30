@isTest
global class TestBatchHabilidad implements HttpCalloutMock{
    static testMethod void testBatchHabilidad() {
        Test.startTest();
        List<Integer> counter = new List<Integer>{1, 2, 3};
        
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"id": 1, "name": "Test", "effect_entries": [{"language": {"name": "en"}, "short_effect": "Test short effect"}]}');
        
        TestBatchHabilidad mock = new TestBatchHabilidad();
        Test.setMock(HttpCalloutMock.class, mock);
        
        BatchHabilidad batch = new BatchHabilidad(counter);
        Id batchJobId = Database.executeBatch(batch, 2);
        
        Test.stopTest();
        
        List<Habilidad__c> habilidades = [SELECT Id, Name, ExtId__c, Efecto__c FROM Habilidad__c];
        System.assertEquals(counter.size(), habilidades.size(), 'Number of habilidades incorrect');
        for (Integer i = 0; i < counter.size(); i++) {
            System.assertEquals(counter[i], habilidades[i].ExtId__c, 'ExtId__c incorrect');
            System.assertEquals('Test', habilidades[i].Name, 'Name incorrect');
            System.assertEquals('Test short effect', habilidades[i].Efecto__c, 'Efecto__c incorrect');
        }
    }
    
    global HttpResponse respond(HttpRequest req) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"id": 1, "name": "Test", "effect_entries": [{"language": {"name": "en"}, "short_effect": "Test short effect"}]}');
        return response;
    }
}