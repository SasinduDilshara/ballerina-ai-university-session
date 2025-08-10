import ballerina/ai;
import ballerinax/googleapis.gmail;
import ballerina/log;

final ai:Wso2ModelProvider personalAsistantModel = check ai:getDefaultModelProvider();
final ai:Agent personalAsistantAgent = check new (
    systemPrompt = {
        role: "Personal AI Assistant",
        instructions: string `You are Nova, a smart AI assistant helping me stay organized and efficient.

Your primary responsibilities include:
- Email Assistance: Reading, summarizing, composing, and sending emails while ensuring clarity and professionalism.

Guidelines:
- Respond in a natural, friendly, and professional tone.
- Always confirm before making changes to the mailbox.
- Provide concise summaries when retrieving information unless the user requests details.
- Prioritize clarity, efficiency, and user convenience in all tasks.`
    }, model = personalAsistantModel, tools = [listUnreadEmails, readSpecificEmail, sendEmail, getEmailsByLabels]
);

# This tool is using to list the unread messages in the users mailbox
# + return - List of unread emails 
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.1.0.png"}
isolated function listUnreadEmails() returns gmail:ListMessagesResponse|error {
    gmail:ListMessagesResponse|error gmailListmessagesresponse = gmailClient->/users/["me"]/messages.get(q = "is:unread");
    if (gmailListmessagesresponse is error) {
        log:printError("Error retrieving unread emails: ", gmailListmessagesresponse);
        return gmailListmessagesresponse;
    }

    log:printInfo("Unread emails retrieved successfully: ");
    return gmailListmessagesresponse;
}

# Gets the specified email message.
# + id - The ID of the email message to retrieve. This ID is usually retrieved using `messages.list`. The ID is also contained in the result when a message is inserted (`messages.insert`) or imported (`messages.import`).
# + return - Specified email message or error
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.1.0.png"}
isolated function readSpecificEmail(string id) returns gmail:Message|error {
    gmail:Message|error message = gmailClient->/users/["me"]/messages/[id].get(format = "full");
    if (message is error) {
        log:printError("Error retrieving email: ", message);
        return message;
    }

    log:printInfo("Email retrieved successfully: ");
    return message;
}

# Retrieves email messages that match specific labels.
# + labelIds - Only return messages with labels that match all of the specified label IDs. Messages in a thread might have labels that other messages in the same thread don't have. To learn more, see [Manage labels on messages and threads](https://developers.google.com/gmail/api/guides/labels#manage_labels_on_messages_threads).
# + return - Email messages that match specific labels or error
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.1.0.png"}
isolated function getEmailsByLabels(string[] labelIds) returns gmail:ListMessagesResponse|error {
    gmail:ListMessagesResponse|error messages = gmailClient->/users/["me"]/messages.get(labelIds = labelIds);
    if (messages is error) {
        log:printError("Error retrieving emails: ", messages);
        return messages;
    }

    log:printInfo("Emaisl retrieved successfully: ");
    return messages;
}

# Sends the specified message to the recipients in the `To`, `Cc`, and `Bcc` headers. For example usage, see [Sending email](https://developers.google.com/gmail/api/guides/sending). 
# + payload - The message to be sent. 
# + return - The sent message or an error if the operation fails.
@ai:AgentTool
@display {label: "", iconPath: "https://bcentral-packageicons.azureedge.net/images/ballerinax_googleapis.gmail_4.1.0.png"}
isolated function sendEmail(gmail:MessageRequest payload) returns gmail:Message|error {
    gmail:Message|error gmailMessage = gmailClient->/users/["me"]/messages/send.post(payload);
    if (gmailMessage is error) {
        log:printError("Error sending email: ", gmailMessage);
        return gmailMessage;
    }

    return gmailMessage;
}
