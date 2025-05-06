import { LightningElement, api, wire } from 'lwc';
import getProjectOverview from '@salesforce/apex/ProjectController.getProjectDetail';

export default class ProjectOverview extends LightningElement {
    @api projectId;
    @api projectName;
    milestones;
    error;

    @wire(getProjectOverview, { projectId: '$projectId' })
    wiredOverview({ data, error }) {
        if (data) {
            this.milestones = data;
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.milestones = undefined;
        }
    }
}