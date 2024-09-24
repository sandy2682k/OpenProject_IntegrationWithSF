import { LightningElement, track } from 'lwc';
import getProjectData from '@salesforce/apex/OpenProjectQueueable.getProjectData';
import refreshProjectData from '@salesforce/apex/OpenProjectQueueable.refreshProjectData';
import updateProjectRecord from '@salesforce/apex/OpenProjectQueueable.updateProjectData';  // APEX Method to update the project

export default class OpenProjectDataTable extends LightningElement {
    @track columns = [
        { label: 'Project Name', fieldName: 'Name', type: 'text' },
        { label: 'Description', fieldName: 'Description__c', type: 'text' },
        { label: 'Type', fieldName: 'Type__c', type: 'text' },
        {
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                title: 'View',
                variant: 'bare',
                alternativeText: 'View Details',
                name: 'view_details',
            }
        }
    ];

    @track projectList = [];
    @track paginatedProjectList = [];
    @track totalRecords = 0;
    @track isLoading = false;
    @track selectedRecord = {};  // For storing selected record
    @track isModalOpen = false;  // To control the modal visibility
    @track objDisabled = {
        "descDisabled" : true,
        "projectDisabled" : true
    }

    currentPage = 1;
    pageSize = 3;

    connectedCallback() {
        console.log('Component initialized');
        this.getData();  // Fetch all project data when the component is initialized
    }

    // Fetches all records from Apex
    getData() {
        this.isLoading = true;
        getProjectData()
            .then(result => {
                this.projectList = result;
                this.totalRecords = result.length;
                this.paginateData();
                this.isLoading = false;
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    paginateData() {
        const startIdx = (this.currentPage - 1) * this.pageSize;
        const endIdx = this.currentPage * this.pageSize;
        this.paginatedProjectList = this.projectList.slice(startIdx, endIdx);
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.paginateData();
        }
    }

    handleNext() {
        if (this.currentPage < Math.ceil(this.totalRecords / this.pageSize)) {
            this.currentPage++;
            this.paginateData();
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'view_details') {
            this.selectedRecord = { ...row };  // Clone the selected record for editing
            this.isModalOpen = true;  // Open modal popup
            this.doubleClickCount = 0;  // Reset double-click count when a new record is selected
            this.isDisabled = true;  // Disable fields initially
        }
    }

    clickHandler(event){
        if(event.target.name == "description"){
            this.objDisabled.descDisabled = false;
        }
        else if(event.target.name == "projectName"){
            this.objDisabled.projectDisabled = false;
        }
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this.selectedRecord[field] = event.target.value;  // Update selected record dynamically
    }

    closeModal() {
        this.objDisabled.descDisabled = true;
        this.objDisabled.projectDisabled = true;
        this.isModalOpen = false;  // Close modal popup
        this.doubleClickCount = 0;  // Reset double-click count when modal is closed
        this.isDisabled = true;  // Disable fields when modal is closed
    }

    saveChanges() {
        updateProjectRecord({ project: this.selectedRecord })  // Apex method to update the project
            .then(() => {
                this.isModalOpen = false;  // Close the modal after save
                this.getData();  // Refresh the project data after saving changes
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleRefresh() {
        this.isLoading = true;
        refreshProjectData()
            .then(() => {
                setTimeout(() => {
                    this.getData();
                }, 2500);
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
            });
    }

    get disablePrevious() {
        return this.currentPage === 1;
    }

    get disableNext() {
        return this.currentPage >= Math.ceil(this.totalRecords / this.pageSize);
    }
}
