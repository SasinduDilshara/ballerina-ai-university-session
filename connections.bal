// import ballerinax/googleapis.gcalendar;
import ballerinax/googleapis.gmail;

final gmail:Client gmailClient = check new ({
    auth: {
        refreshToken,
        clientId,
        clientSecret
    }
});

