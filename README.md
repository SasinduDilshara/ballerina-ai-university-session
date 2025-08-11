# Ballerina AI Capabilities

This repository showcases **Ballerina's AI integrations**, including direct LLM calls, RAG applications, AI agents, and Copilot-generated demos. Each feature is available in a separate branch for easy exploration.

## Available Samples

| Sample | Branch | Description |
|--------|--------|-------------|
| **Direct LLM Invocation** | [`direct-llm-calls-with-ballerina-demo`](https://github.com/SasinduDilshara/ballerina-ai-university-session/blob/direct-llm-calls-with-ballerina-demo-completed/main.bal) | Stateless LLM calls with structured, type-safe responses (e.g., JSON/Ballerina records). |
| **RAG Applications** | [`rag-demo`](https://github.com/SasinduDilshara/ballerina-ai-university-session/blob/rag-demo-completed/main.bal) | Retrieval-Augmented Generation (RAG) pipelines with Ballerina and vector databases. |
| **AI Agent Application** | [`agent-demo`](https://github.com/SasinduDilshara/ballerina-ai-university-session/blob/agent-demo-completed/main.bal) | Ballerina-based AI agents for multi-step task automation. |
| **Copilot-Generated Demo** | [`ballerina-copilot-demo`](https://github.com/SasinduDilshara/ballerina-ai-university-session/blob/ballerina-copilot-demo/main.bal) | Generated Ballerina code using Ballerina Copilot. |

---

## ⚙️ Prerequisites

### 1. **Google API Credentials** (For Gmail/OAuth2)  
   - Sign in to [Google Cloud Console](https://console.cloud.google.com/).  
   - Create a project → Enable **Gmail API**.  
   - Generate:  
     - `Client ID`  
     - `Client Secret`  
     - `Refresh Token`  
   - Follow: [Google OAuth2 Guide](https://developers.google.com/identity/protocols/oauth2).  

### 2. **Pinecone Vector Database**  
   - Sign up at [Pinecone](https://www.pinecone.io/start/).  
   - Create an **index** in the [Pinecone Console](https://app.pinecone.io/).  
   - Need to collect the API key and service url.
---
