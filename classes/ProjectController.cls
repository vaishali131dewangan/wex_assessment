public class ProjectController {
    
    @AuraEnabled
    public static Id createProjectWithDetails(String payload) {

        ProjectPayload data = (ProjectPayload)JSON.deserialize(payload, ProjectPayload.class);
        
        insert data.project;
        
        List<Milestone__c> milestoneList = new List<Milestone__c>();
        List<To_Do_Items__c> todoList = new List<To_Do_Items__c>();
        
        for (MilestoneWrapper mw : data.milestones) {
            Milestone__c m = new Milestone__c(
                Name = mw.name,
                Project__c = data.project.Id,
                Due_Date__c = mw.dueDate
            );
            milestoneList.add(m);
        }        
        insert milestoneList;
        
        Integer index = 0;
        for (MilestoneWrapper mw : data.milestones) {
            Id milestoneId = milestoneList[index++].Id;
            if(mw.todos?.size()>0){
                for (ToDoWrapper todo : mw.todos) {
                    todoList.add(new To_Do_Items__c(
                        Name = todo.name,
                        Due_Date__c = todo.dueDate,
                        Status__c = todo.status,
                        Milestone__c = milestoneId
                    ));
                }
            }
            
        }        
        insert todoList;
        
        return data.project.Id;
    }
    
    public class MilestoneWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public List<ToDoWrapper> todos = new List<ToDoWrapper>();
    }
    
    public class ToDoWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public Date dueDate;
        @AuraEnabled public String status;
    }
    
	 public class ProjectPayload {
        public Project__c project;
        public List<MilestoneWrapper> milestones=new List<MilestoneWrapper>();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<MilestoneWrapper> getProjectDetail(Id projectId) {
        List<Milestone__c> milestones = [
            SELECT Id, Name, Due_Date__c,
            (SELECT Id, Name, Status__c, Due_Date__c FROM To_Do_Items__r)
            FROM Milestone__c
            WHERE Project__c = :projectId
        ];
        
        List<MilestoneWrapper> result = new List<MilestoneWrapper>();
        for (Milestone__c m : milestones) {
            MilestoneWrapper mw = new MilestoneWrapper();
            mw.name = m.Name;
            mw.dueDate = m.Due_Date__c;
            mw.todos = new List<ToDoWrapper>();
            
            for (To_Do_Items__c todo : m.To_Do_Items__r) {
                ToDoWrapper tw = new ToDoWrapper();
                tw.name = todo.Name;
                tw.status = todo.Status__c;
                tw.dueDate = todo.Due_Date__c;
                mw.todos.add(tw);
            }
            
            result.add(mw);
        }
        return result;
    }
}