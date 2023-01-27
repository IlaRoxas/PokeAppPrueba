global class BatchPokemon implements Database.Batchable<integer>, Database.AllowsCallouts
{
    public List<Integer> counter;
    
    public BatchPokemon(List<Integer> counter){this.counter = counter;}
    
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
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://pokeapi.co/api/v2/pokemon/'+scope[0]);
            req.setMethod('GET');
            Http http = new Http();
            HttpResponse res = http.send(req);    
            if (res.getStatusCode() == 200) 
            {
                Map<String, Object> results = new Map<String, Object>();
                results = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        
                Pokemon__c poke = new Pokemon__c();
                
                Integer IdPoke = (Integer)results.get('id');
                poke.ExtId__c = IdPoke;
               
                insert poke;
                poke = [SELECT Id, Generacion__c FROM Pokemon__c WHERE Id = :poke.Id];
                
                Double AlturaPoke = (Double)results.get('height');
                poke.Altura__c = AlturaPoke/10;
        
                Double PesoPoke = (Double)results.get('weight');
                poke.Peso__c = PesoPoke/10;
        
                String NamePoke=(String)results.get('name');
                NamePoke = NamePoke.substring(0,1).toUpperCase() + NamePoke.substring(1);
                poke.Name = NamePoke;
                
                Map<String, Object> sprites = (Map<String, Object>) results.get('sprites');
                String front_default = (String) sprites.get('front_default');
                poke.Imagen__c = front_default;
                
                List<Object> stats = (List<Object>) results.get('stats');
                Integer hp = 0;
                Integer speed = 0;
                Integer attack = 0;
                Integer defense = 0;
                for(Object s : stats)
                {
                    Map<String, Object> stat = (Map<String, Object>) s;
                    if(stat.containsKey('stat')){
                        Map<String, Object> statChild = (Map<String, Object>) stat.get('stat');
                        if(statChild.containsKey('name'))
                        {
                            if(statChild.get('name').equals('hp')){
                                hp = (Integer) stat.get('base_stat');
                                poke.Vida__c=hp;
                            }
                            if(statChild.get('name').equals('speed')){
                                speed = (Integer) stat.get('base_stat');
                                poke.Velocidad__c=speed;
                            }
                            if(statChild.get('name').equals('attack')){
                                attack = (Integer) stat.get('base_stat');
                                poke.Ataque__c=attack;
                            }
                            if(statChild.get('name').equals('defense')){
                                defense = (Integer) stat.get('base_stat');
                                poke.Defensa__c=defense;
                            }
                        }
                    }
                } 
                     
                List<Object> moves = (List<Object>) results.get('moves');
                List<Object> subMoves = new List<Object>();
                for (Integer i = 0; i < moves.size() && i < 4; i++) 
                {
                    subMoves.add(moves[i]);
                    Map<String,Object> moveMap = (Map<String,Object>) subMoves.get(i);
                    Map<String,Object> move = (Map<String,Object>) moveMap.get('move');
                    String moveName = (String) move.get('name');
                    Movimiento__c movidick= new Movimiento__c();
                    movidick = [SELECT Id FROM Movimiento__c WHERE Name=:moveName];
                    Id movementId = (Id) movidick.get('id');
                    
                    if (i == 0) {
                        poke.Slot1__c=movementId;
                    }
                    if (i == 1) {
                        poke.Slot2__c=movementId;
                    }
                    if (i == 2) {
                        poke.Slot3__c=movementId;
                    }
                    if (i == 3) {
                        poke.Slot4__c=movementId;
                    }
                }
                
                List<Object> habilidades = (List<Object>) results.get('abilities');
                
                for(object habilidad:habilidades)
                {
                    Map<String,Object> hab = (Map<String,Object>) habilidad;
                    Map<String,Object> habi = (Map<String,Object>) hab.get('ability');
                    String hName = (String) habi.get('name');
                    Habilidad__c Habil= new Habilidad__c();
                    Habil = [SELECT Id FROM Habilidad__c WHERE Name=:hName];
                    Id habilidad3000 = (Id) Habil.get('id');
                    poke.Habilidad__c=habilidad3000;
                    break;
                }
                List<Object> types = (List<Object>) results.get('types');
                for(Integer i = 0; i< types.size(); i++)
                {
                    Map<String, Object> tipo = (Map<String, Object>) types.get(i);
                    Map<String, Object> typeInfo = (Map<String, Object>) tipo.get('type');
                    String name = (String) typeInfo.get('name');
                    poke.Tipos__c = name;
                }
                system.debug(poke);
                update poke;
            }
    }
    global void finish(Database.BatchableContext bc)
    {
        system.debug('termino');
    }
}