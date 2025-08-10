import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

// Run with curl -X POST http://localhost:9090/query -H "Content-Type: application/json" -d '"Who should I contact for refund approval?"'

service / on httpDefaultListener {
    resource function post query(@http:Payload string userQuery) returns json|error {
        do {
            ai:QueryMatch[] context = check knowledgebase.retrieve(userQuery);
            ai:ChatUserMessage augmentedUserMsg = ai:augmentUserQuery(context, userQuery);
            string response = check defaultModel->generate(check augmentedUserMsg.content.ensureType());
            return response;
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
