public class HttpCalloutCtrl {
    
    @AuraEnabled
    public static Map<String,Object> getCalloutResponseContents(String url) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        HttpResponse res = h.send(req);
        System.debug('response-->: '+res.getBody());
        Map<String,Object> resultsMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
         System.debug(resultsMap);
         return resultsMap;
        
        
    }
}