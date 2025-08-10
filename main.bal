import ballerina/ai;
import ballerina/http;

listener ai:Listener personalAsistantListener = new (listenOn = check http:getDefaultListener());

service /personalAsistant on personalAsistantListener {
    resource function post chat(@http:Payload ai:ChatReqMessage request) returns ai:ChatRespMessage|error {
        string result = check personalAsistantAgent.run(request.message, request.sessionId);
        return {message: result};
    }
}
