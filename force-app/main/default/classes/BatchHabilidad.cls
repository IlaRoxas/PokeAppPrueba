global class BatchHabilidad implements Database.Batchable<integer>,  Database.Stateful, Database.AllowsCallouts
{
    public List<Integer> counter;
    
    public BatchHabilidad(List<Integer> counter)
    {
        this.counter = counter;
    }
    
    global List<Integer> start(Database.BatchableContext bc) 
    { 
        if(counter.isEmpty())
        {
            System.debug('Lista de contadores vacía');
            return null;
        }
        return counter;
    }
    
    global void execute(Database.BatchableContext bc, List<Integer> scope) 
    {
            try
            {
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://pokeapi.co/api/v2/ability/'+ scope[0]);
                req.setMethod('GET');
                Http http = new Http();
                HttpResponse res = http.send(req);    
                if (res.getStatusCode() == 200) 
                {
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                    Habilidad__c hab = new Habilidad__c();
                    hab.ExtId__c = (Integer)results.get('id');
                    
                    String short_effect = '';
                    List<Object> effect_entries = (List<Object>) results.get('effect_entries');
                    for(Object entry: effect_entries) 
                    {   
                        Map<String, Object> effect = (Map<String, Object>) entry;
                        Map<String, Object> language = (Map<String, Object>) effect.get('language');
                            
                        if (language.get('name').equals('en')) 
                        {
                            short_effect = (String) effect.get('short_effect');
                            break;
                        }
                    }
                    hab.Efecto__c = short_effect;
                    String nombreHabilidad = (String)results.get('name');
                    nombreHabilidad = nombreHabilidad.substring(0,1).toUpperCase() + nombreHabilidad.substring(1);
                    hab.Name = nombreHabilidad;
                    System.debug(hab);
                    insert hab;
                }
            }
            catch (Exception e) 
            {
            	System.debug(' ERROR: ' + e.getMessage());
        	}
    }
    
    global void finish(Database.BatchableContext bc)
    {
        system.debug('termino');
    }
}
/*
                    List<Integer>numeros=new List<Integer>();
                    for(integer i=0; i<826; i++){
                        numeros.add(i);
                    }
                    BatchHabilidad batch = new BatchHabilidad(numeros);
                    Id batchId = Database.executeBatch(batch,1);
 */