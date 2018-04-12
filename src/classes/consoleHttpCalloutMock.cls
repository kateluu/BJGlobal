@isTest
global class consoleHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/html');
        response.setBody('{"chart":{"type":"line"},"credits":false,"title":{"text":null},"legend":{"enabled":false},"plotOptions":{"series":{"lineWidth":2,"marker":{"symbol":"circle","radius":3},"pointPlacement":"on","connectNulls":true}},"yAxis":[{"min":1,"max":100,"reversed":true,"title":{"text":"Avg Rank","style":{"color":"#008800"}},"labels":{"style":{"color":"#008800"}},"tickAmount":3},{"title":{"text":"% keywords on page 1","style":{"color":"#000088"}},"labels":{"style":{"color":"#000088"}},"opposite":true,"min":0,"max":100,"tickAmount":3}],"series":[{"name":"Avg Rank","color":"#008800","yAxis":0,"data":[22.73,22.05,22.07,23.24,22.32,22.25,22.33,22.34,23.98,22.69,23.03,24.48,22.83,22.68,23.01,23.34,23.12,23.44,22.93,22.72,22.55,23.79,22.74,23.16,24.46,23.2,22.4,22.18,22.47,22.62,null,null,null,null,null,null,null,null,null,null,null,null,null]}],"xAxis":{"categories":["16 May","17 May","18 May","19 May","20 May","21 May","22 May","23 May","24 May","25 May","26 May","27 May","28 May","29 May","30 May","31 May","01 Jun","02 Jun","03 Jun","04 Jun","05 Jun","06 Jun","07 Jun","08 Jun","09 Jun","10 Jun","11 Jun","12 Jun","13 Jun","14 Jun","15 Jun","16 Jun","17 Jun","18 Jun","19 Jun","20 Jun","21 Jun","22 Jun","23 Jun","24 Jun","25 Jun","26 Jun","27 Jun"],"plotLines":[{"color":"#00C","dashStyle":"Dash","width":1,"value":4,"label":{"text":"Report","style":{"color":"#666666"}},"zIndex":2},{"color":"#00C","dashStyle":"Dash","width":1,"value":18,"label":{"text":"Report","style":{"color":"#666666"}},"zIndex":2}]}}');
        response.setStatusCode(200);
        return response; 
    }
}