import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(const FutureLensApp());

class FutureLensApp extends StatelessWidget {
  const FutureLensApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E272E),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController decisionController = TextEditingController();
  final TextEditingController option1Controller = TextEditingController();
  final TextEditingController option2Controller = TextEditingController();

  bool isLoading = false;
  String option1Risk = "";
  String option2Risk = "";
  String recommendation = "";
  
  // --- GEAR 8: MARSHALL TREND TRACKER VARIABLES ---
  int activeAgents = 1685;
  int threatUsers = 26;
  Map<String, dynamic> deepDive = {};
  List<dynamic> explanations = [];
  
  String chaosRank = "Risk Taker";
  String orderRank = "Life Saver";
  int chaosLevel = 1; 
  int orderLevel = 1; 
  double chaosXP = 0.2;
  double orderXP = 0.2;
  
  // 🔥 Profile Identifier
  String agentName = "Nithish J";

  // --- SKEUOMORPHIC UI DECORATIONS ---
  BoxDecoration neumorphicPop() => BoxDecoration(
    color: const Color(0xFF1E272E),
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(color: Color(0xFF12181C), offset: Offset(8, 8), blurRadius: 15),
      BoxShadow(color: Color(0xFF2A3640), offset: Offset(-8, -8), blurRadius: 15),
    ],
  );

  BoxDecoration neumorphicEngraved() => BoxDecoration(
    color: const Color(0xFF1A2228),
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: const Color(0xFF2A3640), width: 1.5),
  );

  // --- PROGRESS BAR BUILDER ---
  Widget _buildSkeuomorphicBar(String label, double percentage, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: double.infinity,
          decoration: neumorphicEngraved(), 
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MARSHALL XP LOGIC ---
  void processMarshallXP(String riskString) {
    double risk = double.tryParse(riskString.replaceAll('%', '')) ?? 0.0;
    setState(() {
      if (risk >= 70) {
        chaosXP += 0.2;
        if (chaosXP >= 1.0 && chaosLevel < 5) {
          chaosLevel++;
          chaosXP = 0.1;
        }
        chaosRank = ["Risk Taker", "Reckless", "Daredevil", "Boogeyman", "Ghost"][chaosLevel - 1];
      } else if (risk <= 30) {
        orderXP += 0.2;
        if (orderXP >= 1.0 && orderLevel < 5) {
          orderLevel++;
          orderXP = 0.1;
        }
        orderRank = ["Life Saver", "Sentinel", "Strategist", "Paladin", "Guardian"][orderLevel - 1];
      }
    });
  }

  // --- DYNAMIC PROFILE HEADER ---
  Widget _buildProfileHeader() {
    const mintColor = Color(0xFF55E6C1);
    
    // Determine the dominant path to set the main Profile Badge
    double totalChaos = chaosLevel + chaosXP;
    double totalOrder = orderLevel + orderXP;
    bool isChaosDominant = totalChaos > totalOrder;
    
    String currentBadge = isChaosDominant ? chaosRank : orderRank;
    Color badgeColor = isChaosDominant ? Colors.redAccent : mintColor;
    IconData badgeIcon = isChaosDominant ? Icons.local_fire_department : Icons.shield;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 50, width: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E272E),
                shape: BoxShape.circle,
                border: Border.all(color: badgeColor, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF12181C), offset: Offset(4, 4), blurRadius: 8),
                  BoxShadow(color: Color(0xFF2A3640), offset: Offset(-4, -4), blurRadius: 8),
                ]
              ),
              child: Icon(Icons.person, color: badgeColor),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome, $agentName", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const Text("FutureLens Active", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          child: Row(
            children: [
              Icon(badgeIcon, color: badgeColor, size: 14),
              const SizedBox(width: 6),
              Text(currentBadge.toUpperCase(), style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        )
      ],
    );
  }

  // --- MARSHALL DASHBOARD UI ---
  Widget _buildMarshallDashboard() {
    const mintColor = Color(0xFF55E6C1);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: neumorphicPop(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPathInfo("ORDER", orderRank, mintColor),
              const Icon(Icons.bolt, color: Colors.white24, size: 30),
              _buildPathInfo("CHAOS", chaosRank, Colors.redAccent, isRight: true),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildSkeuomorphicBar("", orderXP, mintColor)),
              const SizedBox(width: 25),
              Expanded(child: _buildSkeuomorphicBar("", chaosXP, Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPathInfo(String label, String rank, Color color, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        Text(rank, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const mintColor = Color(0xFF55E6C1);
    
    // 🔥 FIX 1: The App now knows these words mean it's a Trip!
    bool isStock = decisionController.text.toLowerCase().contains("stock") || 
                   decisionController.text.toLowerCase().contains("buy");
                   
    bool isTrip = decisionController.text.toLowerCase().contains("trip") || 
                  decisionController.text.toLowerCase().contains("japan") || 
                  decisionController.text.toLowerCase().contains("ooty") ||
                  decisionController.text.toLowerCase().contains("ship") ||
                  decisionController.text.toLowerCase().contains("plane") ||
                  decisionController.text.toLowerCase().contains("flight");

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧑‍🚀 DYNAMIC PROFILE HEADER
              _buildProfileHeader(),
              
              const SizedBox(height: 30),

              // 🏆 MARSHALL DASHBOARD
              _buildMarshallDashboard(),
              
              const SizedBox(height: 35),

              // 📝 MAIN INPUTS
              Container(
                decoration: neumorphicPop(),
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Container(decoration: neumorphicEngraved(), child: TextField(controller: decisionController, decoration: const InputDecoration(hintText: "Decision Context...", border: InputBorder.none, contentPadding: EdgeInsets.all(15)))),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: Container(decoration: neumorphicEngraved(), child: TextField(controller: option1Controller, decoration: const InputDecoration(hintText: "Option 1", border: InputBorder.none, contentPadding: EdgeInsets.all(15))))),
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("VS", style: TextStyle(color: mintColor, fontWeight: FontWeight.bold))),
                        Expanded(child: Container(decoration: neumorphicEngraved(), child: TextField(controller: option2Controller, decoration: const InputDecoration(hintText: "Option 2", border: InputBorder.none, contentPadding: EdgeInsets.all(15))))),
                      ],
                    ),
                    const SizedBox(height: 25),
                    GestureDetector(
                      onTap: () async {
                        if (isLoading) return;
                        setState(() => isLoading = true);
                        try {
                          final response = await http.post(
                            Uri.parse('http://127.0.0.1:3000/api/predict/route-safety'),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({"decision": decisionController.text, "option1": option1Controller.text, "option2": option2Controller.text}),
                          ).timeout(const Duration(seconds: 10)); 

                          if (response.statusCode == 200) {
                            final data = jsonDecode(response.body);
                            setState(() {
                              isLoading = false;
                              option1Risk = data['option1Risk'];
                              option2Risk = data['option2Risk'];
                              recommendation = data['recommendation'];
                              deepDive = data['deepDive'] ?? {"weather": 50, "traffic": 50, "terrain": 50};
                              explanations = data['explanations'] ?? [];
                              activeAgents = data['activeAgents'] ?? 1685;
                              threatUsers = data['threatUsers'] ?? 26;
                              
                              processMarshallXP(option1Risk); 
                            });
                          } else {
                            throw Exception("Server Error ${response.statusCode}");
                          }
                        } catch (e) { 
                          debugPrint("API Connection Failed: $e");
                          setState(() {
                            isLoading = false;
                            option1Risk = "ERR";
                            option2Risk = "ERR";
                            recommendation = "CONNECTION FAILED: Check if your Node.js backend is running!";
                            explanations = ["Network Timeout.", "Terminal must say 'Running on port 3000'."];
                            deepDive = {"weather": 0, "traffic": 0, "terrain": 0};
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(color: mintColor, borderRadius: BorderRadius.circular(20)),
                        alignment: Alignment.center,
                        child: isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text("EXECUTE ANALYSIS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // 📊 TACTICAL OUTPUT
              if (option1Risk.isNotEmpty && !isLoading) ...[
                const Text("Tactical Intelligence Output", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                
                if (isTrip) ...[
                  Container(
                    height: 200, width: double.infinity,
                    decoration: neumorphicPop(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(children: [
                        // 🔥 FIX 2: Bulletproof Unsplash Satellite Image!
                        Image.network(
                          "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1000&auto=format&fit=crop", 
                          fit: BoxFit.cover, 
                          width: double.infinity
                        ),
                        Container(color: Colors.black.withOpacity(0.4)), // Darkens it to look tactical
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Icon(Icons.gps_fixed, color: Color(0xFF55E6C1), size: 40), 
                              SizedBox(height: 8), 
                              Text("LIVE SATELLITE TELEMETRY ACTIVE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5))
                            ]
                          )
                        )
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                if (isStock) ...[
                  Container(height: 180, decoration: neumorphicPop(), padding: const EdgeInsets.all(20), child: LineChart(LineChartData(gridData: const FlGridData(show: false), titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false), lineBarsData: [LineChartBarData(spots: [const FlSpot(0, 3), const FlSpot(1, 1), const FlSpot(2, 4), const FlSpot(3, 5)], isCurved: true, color: mintColor, barWidth: 4)]))),
                  const SizedBox(height: 20),
                ],

                Container(
                  decoration: neumorphicPop(), padding: const EdgeInsets.all(25),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Option 1 Risk"), Text(option1Risk, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Option 2 Risk"), Text(option2Risk, style: const TextStyle(color: mintColor, fontWeight: FontWeight.bold))]),
                    const Divider(height: 30),
                    
                    Text("STRATEGIC ADVICE:", style: TextStyle(color: mintColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(recommendation, style: const TextStyle(color: mintColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    
                    const SizedBox(height: 20),

                    const Text("Intelligence Breakdown", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...explanations.map((exp) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [const Icon(Icons.bolt, color: mintColor, size: 16), const SizedBox(width: 10), Expanded(child: Text(exp.toString(), style: const TextStyle(color: Colors.white70, fontSize: 13)))]))),

                    const Divider(height: 30),
                    const Text("Deep Dive Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildSkeuomorphicBar("Weather Hazard", (deepDive['weather'] ?? 0) / 100, mintColor),
                    const SizedBox(height: 10),
                    _buildSkeuomorphicBar("Traffic Congestion", (deepDive['traffic'] ?? 0) / 100, Colors.orangeAccent),
                    const SizedBox(height: 10),
                    _buildSkeuomorphicBar("Terrain Security", (deepDive['terrain'] ?? 0) / 100, Colors.redAccent),
                    
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [const Icon(Icons.radar, color: mintColor, size: 18), const SizedBox(width: 5), Text("$activeAgents Online")]),
                      Row(children: [const Icon(Icons.warning, color: Colors.redAccent, size: 18), const SizedBox(width: 5), Text("$threatUsers Threats")]),
                    ]),
                  ]),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}