require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { BedrockRuntimeClient, InvokeModelCommand } = require('@aws-sdk/client-bedrock-runtime');

const app = express();
app.use(cors());
app.use(express.json());

const bedrockClient = new BedrockRuntimeClient({ region: process.env.AWS_REGION });

// 🌐 DYNAMIC MICRO-RAG: Live Data Simulator
// Now it actually reads the context to supply the correct telemetry!
async function fetchLiveContext(decision, option1, option2) {
    console.log(`[RAG Engine] Fetching dynamic telemetry for context...`);
    await new Promise(resolve => setTimeout(resolve, 500)); // Simulate network delay
    
    const combinedText = `${decision} ${option1} ${option2}`.toLowerCase();

    // 📈 Stock / Finance Telemetry
    if (combinedText.includes("stock") || combinedText.includes("buy") || combinedText.includes("invest")) {
        return {
            marketAlert: "High volatility detected in global markets.",
            trend: "Bearish momentum expected over the next 24 hours.",
            tradingVolume: "Unusually high"
        };
    } 
    // ✈️🚢 Aviation & Maritime Telemetry (The Ship/Plane Fix!)
    else if (combinedText.includes("jet") || combinedText.includes("su-57") || combinedText.includes("f-35") || combinedText.includes("flight") || combinedText.includes("plane") || combinedText.includes("ship") || combinedText.includes("sea") || combinedText.includes("boat")) {
        return {
            weatherAlert: "High altitude crosswinds and turbulent sea states detected.",
            airspace: "Commercial air corridors clear. Maritime routes experiencing mild swells.",
            radarStatus: "Optimal conditions for long-range transit."
        };
    }
    // 🚗 Default Travel / Road Telemetry
    else {
        return {
            weatherAlert: "High probability of localized rain and slippery roads.",
            trafficCondition: "Moderate congestion detected on main routes.",
            recentIncidents: 1
        };
    }
}

// 🛣️ FEATURE 1: Prediction Engine (NOVA + Dynamic RAG + XAI)
app.post('/api/predict/route-safety', async (req, res) => {
    const { decision, option1, option2 } = req.body;

    console.log(`[FutureLens] Infusing Nova AI (Gear 8) for: ${decision}`);

    // 1. EXECUTE RAG: Get the context-aware live data!
    const liveData = await fetchLiveContext(decision, option1, option2);
    const liveContextString = JSON.stringify(liveData);

    // 2. THE MASTER PROMPT: Injecting RAG and demanding XAI bullet points
    const systemPrompt = `You are FutureLens AI, a decision intelligence system. 
    The user is deciding: "${decision}".
    Option 1: "${option1}". Option 2: "${option2}".
    
    REAL-TIME RAG TELEMETRY: ${liveContextString}
    
    Analyze the risks incorporating the real-time telemetry above.
    You MUST respond EXACTLY in this JSON format and nothing else:
    {
        "option1Risk": "XX%",
        "option2Risk": "YY%",
        "recommendation": "One brief sentence.",
        "explanations": [
            "Short technical reason 1 based on the telemetry.",
            "Short technical reason 2.",
            "Short technical reason 3."
        ],
        "deepDive": {
            "weather": <number 10-90>,
            "traffic": <number 10-90>,
            "terrain": <number 10-90>
        }
    }`;

    try {
        const payload = {
            schemaVersion: "messages-v1",
            messages: [{ role: "user", content: [{ text: systemPrompt }] }],
            inferenceConfig: { maxTokens: 400, temperature: 0.7 }
        };

        const command = new InvokeModelCommand({
            modelId: 'amazon.nova-lite-v1:0',
            contentType: 'application/json',
            accept: 'application/json',
            body: JSON.stringify(payload)
        });

        const response = await bedrockClient.send(command);
        const aiText = JSON.parse(new TextDecoder().decode(response.body)).output.message.content[0].text;
        const cleanJson = aiText.replace(/```json/g, '').replace(/```/g, '').trim();
        
        let aiAnalysis = JSON.parse(cleanJson);

        // Add Active Agents & Threats for the frontend radar
        aiAnalysis.activeAgents = Math.floor(Math.random() * 800) + 1200;
        aiAnalysis.threatUsers = Math.floor(Math.random() * 30) + 5;

        console.log("[FutureLens] Gear 8 Success with Dynamic RAG!");
        res.json(aiAnalysis);

    } catch (error) {
        console.error("Nova AI Engine Error:", error);
        res.status(500).json({ error: "Intelligence Engine Offline" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 FutureLens AI Engine (DYNAMIC RAG INFUSED) running on port ${PORT}`);
});