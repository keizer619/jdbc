import ballerina/io;
import ballerina/mime;
import ballerina/http;
import ballerina/websub;

endpoint websub:Listener websubEP {
    port:8181
};

@websub:SubscriberServiceConfig {
    path:"/websub",
    subscribeOnStartUp:true,
    topic: "http://www.websubpubtopic.com",
    hub: "https://localhost:9292/websub/hub"
}
service<websub:Service> websubSubscriber bind websubEP {

    onNotification (websub:Notification notification) {
        io:println("WebSub Notification Received: " + notification.payload.toString());
        json jsonPayload = check notification.request.getJsonPayload();
        io:println("WebSub Notification from Request: " + jsonPayload.toString());
    }

}

