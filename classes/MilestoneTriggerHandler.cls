public class MilestoneTriggerHandler {
    
    public static void updateMilestonePercent(List<Milestone__c> milestonelist,Map<id,Milestone__c> mileoldmap){
        for(Milestone__c mile : milestonelist){
            if(mile.Completed_Todos__c != mileoldmap.get(mile.id).Completed_Todos__c || mile.Total_ToDos__c != mileoldmap.get(mile.id).Total_ToDos__c ){
                mile.percentagecomplete__c = mile.Total_ToDos__c != 0 ? (mile.Completed_Todos__c / mile.Total_ToDos__c) * 100 : 0;
                system.debug('mile:'+mile);
            }                     
        }
    }    
    //
    public static void updateProjectPercentage(List<Milestone__c> milestonelist,Map<id,Milestone__c> mileoldmap,Boolean isafterupdate){
        
        Set<Id> projectidset = new Set<Id>();
        
        for(Milestone__c mile : milestonelist){
            if(mile.Project__c != null && ((isafterupdate && mileoldmap != null && (mile.Completed_Todos__c != mileoldmap.get(mile.id).Completed_Todos__c 
                                                              || mile.Total_ToDos__c != mileoldmap.get(mile.id).Total_ToDos__c)) 
                                           || !isafterupdate))
            {
                system.debug('milenew:'+mile);

                projectidset.add(mile.Project__c);
            }            
        }
        
        List<Project__c> updatelstProject = new List<Project__c>();
        
        for(AggregateResult ar : [Select Project__c,Count(id) totmilecount, sum(percentagecomplete__c) totpercent from Milestone__c 
                                  where Project__c In : projectidset Group By Project__c])
        {
           
            Project__c proj = new Project__c(Id=(Id)ar.get('Project__c'));  
            
            Integer totalmilecount = (Integer)ar.get('totmilecount');            
            Decimal percent = totalmilecount != 0 ? (Decimal)ar.get('totpercent')/totalmilecount : 0;
            
            proj.percentagecomplete__c= percent;
            updatelstProject.add(proj);
        }
        
        if(updatelstProject?.size()>0){
            update updatelstProject;
        }
    }
}