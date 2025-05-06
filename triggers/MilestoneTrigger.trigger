trigger MilestoneTrigger on Milestone__c (before update,after update, after delete, after undelete) {
    
    if(trigger.isdelete){
        MilestoneTriggerHandler.updateProjectPercentage(trigger.old,null,false);//after delete
    }
    else if(trigger.isupdate){
        if(trigger.isbefore){
            MilestoneTriggerHandler.updateMilestonePercent(trigger.new,trigger.oldmap);//before update
        }
        else{
            MilestoneTriggerHandler.updateProjectPercentage(trigger.new,trigger.oldmap,true);//after update
        }
    }
    else{
        MilestoneTriggerHandler.updateProjectPercentage(trigger.new,trigger.oldmap,false);// after undelete
    }
}