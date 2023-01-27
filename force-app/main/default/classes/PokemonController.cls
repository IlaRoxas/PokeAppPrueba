public with sharing class PokemonController {
    @AuraEnabled(cacheable=true)
    public static List<Pokemon__c> getPokemons(String nombre, String generacion, String tipo)
    {
        String query;
        String condicion ='';
        if (String.isNotBlank(nombre))
        {
            condicion = 'Name LIKE \''+'%' + nombre + '%\'';
        }
        if (String.isNotBlank(generacion)) 
        {
            if (String.isNotBlank(condicion))
            {
                condicion +=' AND Generacion__c = ' + generacion +'';
            } else 
            {
                condicion +=' Generacion__c = ' + generacion +'';
            }
        }
        if (String.isNotBlank(tipo)) 
        {
            if(String.isNotBlank(condicion)) 
            {
                condicion += ' AND Tipos__c INCLUDES ' + '(\'' +tipo +'\')';
            } else 
            {
                condicion += ' Tipos__c INCLUDES ' + '(\'' +tipo +'\')';
            }
        }
        if (String.isNotBlank(condicion)) 
        {
            query = 'SELECT Name, ExtId__c, Generacion__c, Imagen__c, Peso__c, Altura__c, Tipos__c FROM Pokemon__c WHERE ' + condicion +' ORDER BY ExtId__c';
        } else 
        {
            query = 'SELECT Name, ExtId__c, Generacion__c, Imagen__c, Peso__c, Altura__c, Tipos__c FROM Pokemon__c ORDER BY ExtId__c';
        }
        List<Pokemon__c> pokemons = Database.query(query);

        return pokemons;
    }
}