import ballerina/ai;
import ballerina/io;
import ballerina/log;

// We do not need to ingest the knowledge base every time the application starts.
// Only do this when knowldge base is empty or when you want to update it.
public function main() returns error? {
    do {
        string content = check io:fileReadString("resources/hr_policies.md");
        ai:TextDocument doc = {content};
        ai:Chunk[] chunks = check ai:chunkDocumentRecursively(doc);
        check knowledgebase.ingest(chunks);
        io:println("Ingestion completed.");
    } on fail error e {
        log:printError("Error occurred", 'error = e);
        return e;
    }
}
