global class BatchMovimiento implements Database.Batchable<integer>,  Database.Stateful, Database.AllowsCallouts
{
    public List<Integer> counter;
    
    public BatchMovimiento(List<Integer> counter){this.counter = counter;}
    
    global List<Integer> start(Database.BatchableContext bc) 
    { 
        if(counter.isEmpty())
        {
            System.debug('Lista de contadores vacia');
            return null;
        }
        return counter;
    }
    
    global void execute(Database.BatchableContext bc, List<Integer> scope) 
    {
        
        try
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://pokeapi.co/api/v2/move/'+ scope[0]);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);    
            if (res.getStatusCode() == 200) 
            {
                Map<String, Object> results = new Map<String, Object>();
                results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Movimiento__c mov = new Movimiento__c();
                Integer IdMov = (Integer)results.get('id');
                mov.ExtId__c = IdMov;
                
                Integer punteriaMov = (Integer)results.get('accuracy');
                mov.Punteria__c = punteriaMov;
                
                Integer effectChanceMov=(Integer)results.get('effect_chance');
                mov.Chance_efecto__c = effectChanceMov;

                Map<String,Object> objetivoMov= (Map<String,Object>)results.get('target');
                mov.Objetivo__c = String.valueOf(objetivoMov.get('name'));

                Integer priorityMov = (Integer)results.get('priority');
                mov.Prioridad__c = priorityMov;
                
                String short_effect = null;
                List<Object> effect_entries = (List<Object>) results.get('effect_entries');
                for(Object entry: effect_entries) 
                {   
                    Map<String, Object> effect = (Map<String, Object>) entry;
                    Map<String, Object> language = (Map<String, Object>) effect.get('language');
                    
                    if (language.get('name').equals('en')) 
                    {
                        short_effect = (String) effect.get('short_effect');
                        mov.Efecto__c = short_effect;
                        break;
                    }
                }

                String nameMov=(String)results.get('name');
                nameMov = nameMov.substring(0,1).toUpperCase() + nameMov.substring(1);
                mov.Name = nameMov;

                Integer powerMov = (Integer)results.get('power');
                mov.Poder__c = powerMov;

                Integer ppMov = (Integer)results.get('pp');
                mov.Pp__c = ppMov;
                
                Map<String,Object> tipoMov= (Map<String,Object>)results.get('type');
                mov.Tipo__c = String.valueOf(tipoMov.get('name'));
                System.debug(mov);
                insert mov; 
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