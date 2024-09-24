public with sharing class OpenProjectIntegration {

    public List<Map<String, String>> getCollectedData() {
        List<Map<String, String>> collectedData = new List<Map<String, String>>();
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        // Fetch API endpoint and bearer token from custom metadata using getInstance
        API_Integration_Settings__mdt settings = API_Integration_Settings__mdt.getInstance('API_Integration_Settings'); 

        if (settings == null) {
            logError('Custom Metadata record not found.');
            return collectedData;
        }

        // Get API settings
        String apiEndpoint = settings.API_Endpoint_URL__c;
        String bearerToken = settings.Bearer_Token__c;

        if (String.isBlank(apiEndpoint) || String.isBlank(bearerToken)) {
            logError('API Endpoint or Bearer Token is missing.');
            return collectedData;
        }

        request.setEndpoint(apiEndpoint);
        request.setMethod('GET');
        request.setHeader('Authorization', 'Bearer ' + bearerToken);

        // Timeout is retrieved from custom metadata 
        request.setTimeout(settings.Timeout_Milliseconds__c != null ? (Integer) settings.Timeout_Milliseconds__c : 120000);

        try {
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                
                if (jsonResponse.containsKey('_embedded') && ((Map<String, Object>)jsonResponse.get('_embedded')).containsKey('elements')) {
                    List<Object> elements = (List<Object>) ((Map<String, Object>)jsonResponse.get('_embedded')).get('elements');
                    
                    for (Object element : elements) {
                        Map<String, Object> projectData = (Map<String, Object>) element;
                        Map<String, String> formattedProject = new Map<String, String>();
                        formattedProject.put('name', (String) projectData.get('name'));
                        formattedProject.put('identifier', (String) projectData.get('identifier'));
                        formattedProject.put('_type', (String) projectData.get('_type'));
                        formattedProject.put('description', 
                            (projectData.containsKey('description') && projectData.get('description') != null) ? 
                            (String) ((Map<String, Object>) projectData.get('description')).get('raw') : ''
                          
                        );
                        
                        collectedData.add(formattedProject);
                    }
                } else {
                    logError('"elements" key not found in the API response.');
                }
            } else {
                logError('Error: ' + response.getStatusCode() + ' - ' + response.getStatus());
                logError('Response Body: ' + response.getBody());
            }
        } catch (Exception e) {
            logError('Exception: ' + e.getMessage());
        }
        
        return collectedData;
    }

    
    // Utility method to log errors - Can be enhanced to log to a custom object or platform events for better tracking
    private void logError(String errorMessage) {
        // Log error appropriately (either via System.debug or a custom logging framework)
        System.debug('Error: ' + errorMessage);
        // Optionally, you can create a custom logging mechanism here instead of using System.debug in production
    }
}
