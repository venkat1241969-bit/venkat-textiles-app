import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const VenkatTextilesApp());
}

class VenkatTextilesApp extends StatelessWidget {
  const VenkatTextilesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VENKAT TEXTILES',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D3823),
        scaffoldBackgroundColor: const Color(0xFFFCFBF7),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // మీ అసలు WhatsApp నంబర్‌ను ఇక్కడ మార్చండి
  final String whatsappNumber = "919441447923";

  final List<Map<String, dynamic>> sarees = const [
    {
      'name': 'Kanchipuram Pure Silk',
      'price': 6499,
      'mrp': 9999,
      'image': 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=500'
    },
    {
      'name': 'Dharmavaram Gold Zari',
      'price': 4899,
      'mrp': 7500,
      'image': 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=500'
    },
    {
      'name': 'Pochampally Ikat Pattu',
      'price': 3999,
      'mrp': 5800,
      'image': 'https://images.unsplash.com/photo-1617627143750-d86bc21e42bb?w=500'
    },
    {
      'name': 'Pure Cotton Handloom',
      'price': 1299,
      'mrp': 1999,
      'image': 'https://images.unsplash.com/photo-1609357605129-26f69add5d6e?w=500'
    },
  ];

  Future<void> sendWhatsAppOrder(String sareeName, int price) async {
    final message = """
*VENKAT TEXTILES – కొత్త ఆర్డర్ విచారణ* 🛍️
GSTIN: 37ADGPY4978G1ZR
----------------------------------
*చీర వివరాలు:*
• చీర: $sareeName
• ధర: ₹$price

*డెలివరీ సమాచారం (దయచేసి పూరించండి):*
• పేరు: 
• ఫోన్ నంబర్: 
• ఊరు / నగరం: 
• పూర్తి చిరునామా: 
• పిన్‌కోడ్ (Pincode): 

*బ్లౌజ్ వివరాలు (అవసరమైతే):*
• అన్‌స్టిచ్డ్ (Unstitched) / స్టిచ్చింగ్ కావాలా?: 
----------------------------------
దయచేసి ఈ వివరాలను సరిచూసి పేమెంట్ & డెలివరీ సమయాన్ని నిర్ధారించండి.
""";

    final url = Uri.parse("https://wa.me/$whatsappNumber?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D3823),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VENKAT TEXTILES',
              style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('GST: 37ADGPY4978G1ZR', style: TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: sarees.length,
        itemBuilder: (context, index) {
          final item = sarees[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(item['image'], fit: BoxFit.cover, width: double.infinity),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D3823), fontSize: 14)),
                          const SizedBox(width: 6),
                          Text('₹${item['mrp']}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat, size: 14, color: Colors.white),
                          label: const Text('Order on WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          onPressed: () => sendWhatsAppOrder(item['name'], item['price']),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
