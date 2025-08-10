import ballerina/ai;
import ballerinax/ai.pinecone;

final pinecone:VectorStore pineconeVectorstore = check new (pineconeServiceUrl, pineconeApiKey);
final ai:Wso2EmbeddingProvider aiWso2embeddingprovider = check ai:getDefaultEmbeddingProvider();
final ai:VectorKnowledgeBase knowledgebase = new (pineconeVectorstore, aiWso2embeddingprovider);
final ai:Wso2ModelProvider defaultModel = check ai:getDefaultModelProvider();
