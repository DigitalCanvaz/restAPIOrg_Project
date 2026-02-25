public with sharing class AWSIntegrationController {

    public static ContentVersion fetchSingleS3File(String bucketName, String fileName){
        fileName = fileName.replace(' ', '%20');
        String endPoint = 'callout:AWS_S3/' + bucketName + '/' + fileName;
        System.debug('endPoint: ' + endPoint);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endPoint);
        Http http = new Http();
        HttpResponse response = http.send(request);

        System.debug('Body: ' + response.getBody());
        System.debug('StatusCode: ' + response.getStatusCode());

        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S';
        conVer.PathOnClient = fileName.replace('%20', ' ');
        conVer.Title = fileName.replace('%20', ' ');
        conVer.VersionData = response.getBodyAsBlob();
        return conVer;
    }

    public static void fetchAllS3FilesFromSingBucket(String bucketName){
        String endPoint = 'callout:AWS_S3/' + bucketName;
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/xml');
        request.setMethod('GET');
        request.setEndpoint(endPoint);
        Http http = new Http();
        HttpResponse response = http.send(request);

        System.debug('Body: ' + response.getBody());
        System.debug('StatusCode: ' + response.getStatusCode());

        Dom.Document doc = response.getBodyDocument();
        Dom.XmlNode listBucketResult = doc.getRootElement();
        List<String> allFileNameList = new List<String>();

        for(Dom.XmlNode child: listBucketResult.getChildElements()){
            if(child.getName().toString() == 'Contents'){
                for (Dom.XmlNode content : child.getChildElements()) {
                    if(content.getName() == 'Key'){
                        System.debug('Key: ' + content.getText());
                        allFileNameList.add(content.getText());
                    }
                }
            }
        }

        System.debug('allFileNameList: ' + allFileNameList);
        List<ContentVersion> cvList = new List<ContentVersion>();
        for(String fileName: allFileNameList){
            ContentVersion conVer = fetchSingleS3File(bucketName, fileName);
            cvList.add(conVer);
        }

        Database.executeBatch(new BatchToInsertContentVersion(cvList), 10);
    }
}