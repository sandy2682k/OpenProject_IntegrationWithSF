public class OpenProjectQueueable implements Queueable, Database.AllowsCallouts {
    // This method is executed when the Queueable job is enqueued.
    public void execute(QueueableContext context) {
        // Create an instance of OpenProjectIntegration to call the external API.
        OpenProjectIntegration integration = new OpenProjectIntegration();

        // Fetch collected data from the external API.
        List<Map<String, String>> apiData = integration.getCollectedData();

        // Create a Set to store existing project identifiers from Project_Data__c.
        Set<String> existingIdentifiers = new Set<String>();
        for (Project_Data__c projectDataSet : [SELECT Identifier__c FROM Project_Data__c]) {
            existingIdentifiers.add(projectDataSet.Identifier__c);  // Add the identifiers to the Set.
        }

        // List to hold new records that need to be inserted into Project_Data__c.
        List<Project_Data__c> newDataToInsert = new List<Project_Data__c>();

        // Loop through the API data and check for new records.
        for (Map<String, String> project : apiData) {
            // If the identifier doesn't already exist, create a new record.
            if (!existingIdentifiers.contains(project.get('identifier'))) {
                Project_Data__c addNewProjectData = new Project_Data__c(
                    Name = project.get('name'),
                    Identifier__c = project.get('identifier'),
                    Description__c = project.get('description'),
                    Type__c = project.get('_type')
                );
                newDataToInsert.add(addNewProjectData);  // Add the new record to the list for insertion.
            }
        }

        // Insert new records if there are any, and log the results.
        if (!newDataToInsert.isEmpty()) {
            insert newDataToInsert;
        } 
    }


     // Method to update project data
     @AuraEnabled
     public static void updateProjectData(Project_Data__c project) {
         try {
             update project; // Update the record in the database
         } catch (Exception e) {
             throw new AuraHandledException('Error updating project data: ' + e.getMessage());
         }
     }
    // Method to enqueue a new instance of OpenProjectQueueable to refresh the project data.
    @AuraEnabled
    public static void refreshProjectData() {
        System.enqueueJob(new OpenProjectQueueable());  // Enqueue the Queueable job.
    }

    // Method to fetch project data without pagination.
    @AuraEnabled
    public static List<Project_Data__c> getProjectData() {
        return [SELECT Name, Identifier__c, Description__c,Type__c FROM Project_Data__c Limit 49999];
    }
}
