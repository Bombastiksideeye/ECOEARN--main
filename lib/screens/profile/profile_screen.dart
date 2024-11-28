import 'package:ecoearn/screens/home/home_screen.dart';
import 'package:ecoearn/screens/learn/learn.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileService _profileService = ProfileService();

  Future<void> _redeemPoints(BuildContext context, int currentPoints) async {
    int? pointsToRedeem;
    final pointsController = TextEditingController();

    // Display dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star/coin icon at the top
                  Image.asset(
                    'assets/images/Group 36706.png',
                    height: 100,
                  ),
        
                  // "Points earned" title
                  const SizedBox(height: 16),
                  Text(
                    'Redeem Your Points',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
        
                  // Description text
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the number of points you want to redeem. Points must be a multiple of 10.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color.fromARGB(255, 95, 94, 94)),
                  ),
        
                  // Points input field
                  const SizedBox(height: 16),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.monetization_on),
                      hintText: 'Points (e.g., 10, 20)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      final int? points = int.tryParse(value);
                      setState(() => pointsToRedeem = points);
                    },
                  ),
        
                  // "You will receive X TrashCoins" feedback
                  const SizedBox(height: 8),
                  Text(
                    pointsToRedeem != null && pointsToRedeem! % 10 == 0
                        ? 'You will receive ${pointsToRedeem! ~/ 10} TrashCoins'
                        : 'Invalid points entered',
                    style: TextStyle(
                      color:
                          pointsToRedeem != null && pointsToRedeem! % 10 == 0
                              ? Colors.green
                              : Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            // Cancel Button
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.green,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        final points = int.tryParse(pointsController.text);
                        if (points != null &&
                            points <= currentPoints &&
                            points % 10 == 0) {
                          Navigator.pop(context, points);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Invalid points amount')),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Redeem'),
                    ),
                  ),
                ],
              ),
            ),
        
            // Confirm Button
          ],
        );
      },
    ).then((redeemedPoints) async {
      if (redeemedPoints == null) return;

      // Confirm redemption
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Redemption'),
            content: Text(
              'Are you sure you want to redeem $redeemedPoints points for ${redeemedPoints ~/ 10} TrashCoins?',
            ),
            actions: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.green,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final tcToAdd = redeemedPoints ~/ 10;

        // Update Firestore data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'totalPoints': FieldValue.increment(-redeemedPoints),
          'trashCoins': FieldValue.increment(tcToAdd),
        });

        // Add notification
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': user.uid,
          'type': 'redeem',
          'message':
              'Successfully redeemed $redeemedPoints points for $tcToAdd TC',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Successfully redeemed $tcToAdd TrashCoins!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to redeem points')),
        );
      }
    });
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Yes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (result == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/onboarding',
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions:  [
          GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: const Icon(
              Icons.logout_outlined,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StreamBuilder<Map<String, dynamic>>(
              stream: _profileService.getProfileStats(),
              builder: (context, profileSnapshot) {
                return StreamBuilder<Map<String, dynamic>>(
                  stream: _profileService.getRecyclingStats(),
                  builder: (context, recyclingSnapshot) {
                    final profileData = profileSnapshot.data ?? {};
                    final recyclingData = recyclingSnapshot.data ?? {};

                    final totalPoints = profileData['totalPoints'] ?? 0;

                    final monthlyData = {
                      'plastic': recyclingData['plastic_items_month'] ?? 0,
                      'glass': recyclingData['glass_items_month'] ?? 0,
                      'metal': recyclingData['metal_items_month'] ?? 0,
                      'electronics':
                          recyclingData['electronics_items_month'] ?? 0,
                    };

                    final totalData = {
                      'plastic': recyclingData['plastic_items_total'] ?? 0,
                      'glass': recyclingData['glass_items_total'] ?? 0,
                      'metal': recyclingData['metal_items_total'] ?? 0,
                      'electronics':
                          recyclingData['electronics_items_total'] ?? 0,
                    };

                    final monthlyTotal =
                        monthlyData.values.fold<int>(0, (sum, value) {
                      final intValue =
                          value is int ? value : (value as num).toInt();
                      return sum + intValue;
                    });

                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Image and Name
                        Container(
                          width: double.infinity,
                          color: Colors.green[100]?.withOpacity(0.3),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null,
                                  child: user?.photoURL == null
                                      ? const Icon(Icons.person,
                                          size: 50, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  user?.displayName ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Points Section
                        Container(
                          color: Colors.green[100]?.withOpacity(0.3),
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Earned Total Points: ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$totalPoints',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton(
                                  onPressed: () =>
                                      _redeemPoints(context, totalPoints),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF34A853),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  child: const Text(
                                    'redeem',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Recycled Materials Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Title
                              const Text(
                                'Recycled Materials',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Donut Chart with Center Text
                              SizedBox(
                                height: 160,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    PieChart(
                                      PieChartData(
                                        sectionsSpace: 4,
                                        centerSpaceRadius: 50,
                                        sections: [
                                          PieChartSectionData(
                                            value: monthlyData['plastic']!
                                                .toDouble(),
                                            color: Colors.green,
                                            title: '',
                                            radius: 20,
                                          ),
                                          PieChartSectionData(
                                            value: monthlyData['glass']!
                                                .toDouble(),
                                            color: Colors.blue,
                                            title: '',
                                            radius: 20,
                                          ),
                                          PieChartSectionData(
                                            value: monthlyData['metal']!
                                                .toDouble(),
                                            color: Colors.yellow,
                                            title: '',
                                            radius: 20,
                                          ),
                                          PieChartSectionData(
                                            value: monthlyData['electronics']!
                                                .toDouble(),
                                            color: Colors.orange,
                                            title: '',
                                            radius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$monthlyTotal items',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'This month',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Table Legend
                              Divider(
                                  color: Colors.grey.shade300, thickness: 1),
                              Table(
                                columnWidths: const {
                                  0: FlexColumnWidth(1),
                                  1: FlexColumnWidth(1),
                                  2: FlexColumnWidth(1),
                                },
                                children: [
                                  const TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'MATERIAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          'THIS MONTH',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 8, right: 35),
                                        child: Text(
                                          'TOTAL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  _buildTableRow(
                                    'Plastic',
                                    '${monthlyData['plastic']} items',
                                    '${totalData['plastic']} items',
                                    Colors.green,
                                  ),
                                  _buildTableRow(
                                    'Glass',
                                    '${monthlyData['glass']} items',
                                    '${totalData['glass']} items',
                                    Colors.blue,
                                  ),
                                  _buildTableRow(
                                    'Metal',
                                    '${monthlyData['metal']} items',
                                    '${totalData['metal']} items',
                                    Colors.yellow,
                                  ),
                                  _buildTableRow(
                                    'Electronics',
                                    '${monthlyData['electronics']} items',
                                    '${totalData['electronics']} items',
                                    Colors.orange,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Sets 'Learn' as active tab
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LearnScreen()),
            );
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline)),
            label: 'Profile',
          ),
        ],
        selectedItemColor: const Color(0xFF2E7D32),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  TableRow _buildTableRow(
      String material, String month, String total, Color color) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(material),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Text(month),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Text(total),
        ),
      ],
    );
  }
}
