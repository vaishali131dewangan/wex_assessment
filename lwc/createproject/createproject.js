import { LightningElement, track, wire } from 'lwc';
import createProjectWithDetails from '@salesforce/apex/ProjectController.createProjectWithDetails';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';    
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TODO_OBJECT from '@salesforce/schema/To_Do_Items__c';
import STATUS_FIELD from '@salesforce/schema/To_Do_Items__c.Status__c';

export default class ProjectCreator extends LightningElement {
    projectName = '';
    projectId;
    @track milestones = [];

    @wire(getObjectInfo, { objectApiName: TODO_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    statusPicklistValues;

    get statusOptions() {
        return this.statusPicklistValues?.data?.values || [];
    }

    handleProjectName(event) {
        this.projectName = event.target.value;
    }

    createMilestone() {
        this.milestones.push({ name: '', dueDate: '', todos: [] });
    }

    createToDo(event) {
        const index = event.target.dataset.index;
        this.milestones[index].todos.push({ name: '', dueDate: '', status: 'Not Started' });
    }

    handlemileChange(event) {
        const mIndex = event.target.dataset.mid;
        const label = event.target.label.toLowerCase();

        if (label.includes('name')) {
            this.milestones[mIndex].name = event.target.value;
        } else if (label.includes('date')) {
            this.milestones[mIndex].dueDate = event.target.value;
        }  
    }

    resetpage(){
        this.projectId='';
        this.projectName = '';
        this.milestones = [];
    }

    handleToDoChange(event) {
        const mIndex = event.target.dataset.mid;
        const tIndex = event.target.dataset.tid;
        const label = event.target.label.toLowerCase();

        if (label.includes('name')) {
            this.milestones[mIndex].todos[tIndex].name = event.target.value;
        } else if (label.includes('date')) {
            this.milestones[mIndex].todos[tIndex].dueDate = event.target.value;
        } else if (label.includes('status')) {
            this.milestones[mIndex].todos[tIndex].status = event.target.value;
        }
    }

    saveProject() {
        if(this.projectName.trim() === ''){
            console.log('insi');
           const toastEvt = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter Project name',
                variant: 'error',
            });
            this.dispatchEvent(toastEvt);
           return;
        }
        else{
            for (let i = 0; i < this.milestones.length; i++) {
                const milestone = this.milestones[i];

                if (!milestone.name || milestone.name.trim() === '') {
                    const toastEvt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please enter Milestone name',
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvt);
                    return;
                }

                for (let j = 0; j < milestone.todos.length; j++) {
                    const todo = milestone.todos[j];
                    if (!todo.name || todo.name.trim() === '') {
                        const toastEvt = new ShowToastEvent({
                            title: 'Error',
                            message: 'Please enter Todo name',
                            variant: 'error',
                        });
                        this.dispatchEvent(toastEvt);
                        return;
                    }
                }
            }

        }
            const project = { Name: this.projectName };

            const cleanMilestones = this.milestones.map(milestone => {
                const cleanedTodos = milestone.todos.map(todo => ({                   
                    name: todo.name,
                    dueDate: todo.dueDate ? todo.dueDate : null,
                    status: todo.status
                    
                    
                }));

                return {
                    name: milestone.name? milestone.name : null,
                    dueDate: milestone.dueDate ? milestone.dueDate : null,
                    todos: cleanedTodos
                };
            });

            const data={
                project,
                milestones: cleanMilestones
            };

            createProjectWithDetails({ payload: JSON.stringify(data) })
                .then(result => {
                    this.projectId = result;    
                    console.log('resultresult:'+this.projectId+'+'+this.projectName );                             
                    const toastEvt = new ShowToastEvent({
                        title: 'Success!',
                        message: 'Project Created Successfully!',
                        variant: 'success',
                    });
                    this.dispatchEvent(toastEvt);
                })
                .catch(error => {
                    console.error('Error:', error);
                    const toastEvt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to create project',
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvt);
                });
        
    }
}