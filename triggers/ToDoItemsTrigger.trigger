trigger ToDoItemsTrigger on To_Do_Items__c (after insert,after update, after delete, after undelete) {
    
    if(trigger.isdelete){
        Todoitemshandler.updateMilestonepercentagecomplete(trigger.old);
    }
    else{
        Todoitemshandler.updateMilestonepercentagecomplete(trigger.new);
    }
    
}