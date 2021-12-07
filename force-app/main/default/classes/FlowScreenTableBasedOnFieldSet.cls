/**
*  Invocable generic methods to be called LWC
*  29/10/2021	Hugo Lemos  Created class.
*/
public without sharing class FlowScreenTableBasedOnFieldSet {

    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecordsWithFieldSetById(List<Id> ids, String objectName, String fieldSetName) {
        
        String fieldList = '';
        for(Schema.FieldSetMember f : readFieldSet(objectName, fieldSetName)) {
            fieldList += f.getFieldPath() + ', ';
        }
        fieldList += 'Id';
        
        List<SObject> records = getRecordsById(ids, objectName, fieldList);
        System.debug(records);
        return records;
    }

    @AuraEnabled(cacheable=true)
    public static List<FieldSetWrapper> convertFieldSetToDTColumns(String objectName, String fieldSetName) {
        
        List<FieldSetWrapper> columns = new List<FieldSetWrapper>();
        
        for(Schema.FieldSetMember f : readFieldSet(objectName, fieldSetName)) {
            FieldSetWrapper fieldWrapper = new FieldSetWrapper();
            fieldWrapper.label = f.getLabel();
            fieldWrapper.fieldName = f.getFieldPath();
            fieldWrapper.type = getColumnType(f.getType());
            fieldWrapper.sortable = true;
            columns.add(fieldWrapper);
        }
        
        return columns;
    }


    public static List<SObject> getRecordsById(List<Id> ids, String objectName, String fieldList) {
        return Database.query('SELECT ' + fieldList + ' FROM ' + objectName + ' WHERE Id IN :ids');        
    }


    public static List<Schema.FieldSetMember> readFieldSet(String ObjectName, String fieldSetName)
    {
        Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType sObjectTypeObj = globalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult describeSObjectResultObj = sObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = describeSObjectResultObj.FieldSets.getMap().get(fieldSetName);

        return fieldSetObj.getFields(); 
    }

    public static String getColumnType(Schema.DisplayType dt) {
        switch on dt {
            when INTEGER { return 'number'; }	
            when Double { return 'number'; }
            when Boolean { return 'boolean'; }
            when Date { return 'date'; }
            when DateTime { return 'date'; }
            when Currency { return 'currency'; }
            when Phone { return 'phone'; }
            when URL { return 'url'; }
            when Email { return 'email'; }
            when Percent { return 'percent'; }
            when else { return 'text'; }
        }
    }

    // Inner Apex Class
    public class FieldSetWrapper {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String type {get; set;}
        @AuraEnabled public String fieldName {get; set;}
        @AuraEnabled public Boolean sortable {get; set;}
    }
    
}
