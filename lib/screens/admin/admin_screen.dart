import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'admin_service.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminScreen extends StatelessWidget {
  final AdminService _adminService = AdminService();

  AdminScreen({super.key});

  Widget _buildImageWidget(BuildContext context, String? base64Image) {
    if (base64Image == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // Show full-screen image
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Stack(
              children: [
                Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.contain,
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: MemoryImage(base64Decode(base64Image)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final TextEditingController pointsController = TextEditingController();
    final timestamp = data['timestamp'] as Timestamp?;
    final dateStr = timestamp != null 
        ? DateFormat('MMM dd, yyyy HH:mm').format(timestamp.toDate())
        : 'No date';
    
    // Get material type and format it properly
    final materialType = (data['materialType'] ?? 'Unknown').toString().toUpperCase();
    final quantity = data['quantity']?.toString() ?? '0';
    
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text(data['userName'] ?? 'Unknown User'),
        subtitle: Text(
          materialType == 'METAL' 
              ? '$materialType - ${data['metalType'] ?? 'Unknown'} - $dateStr'
              : '$materialType - $dateStr',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${(data['status'] ?? 'Unknown').toUpperCase()}'),
                Text('Quantity: $quantity items'),
                if (materialType == 'METAL')
                  Text('Metal Type: ${data['metalType'] ?? 'Unknown'}'),
                if (data['weight'] != null && materialType != 'GLASS') 
                  Text('Weight: ${data['weight']} kg'),
                const SizedBox(height: 8),
                if (data['imageData'] != null) ...[
                  const Text('Image:'),
                  const SizedBox(height: 8),
                  _buildImageWidget(context, data['imageData']),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete Button
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Show confirmation dialog
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text('Are you sure you want to delete this request?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (shouldDelete == true) {
                          try {
                            await _adminService.deleteRequest(doc.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Request deleted successfully')),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error deleting request: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      icon: const Icon(Icons.delete, color: Colors.white),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    if (data['status'] == 'pending') ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          children: [
                            TextField(
                              controller: pointsController,
                              decoration: const InputDecoration(
                                labelText: 'Enter Points to Award',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () async {
                                if (pointsController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter points to award')),
                                  );
                                  return;
                                }

                                final points = int.tryParse(pointsController.text);
                                if (points == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter a valid number')),
                                  );
                                  return;
                                }

                                try {
                                  final userId = data['userId'];
                                  if (userId == null) {
                                    throw 'User ID not found';
                                  }

                                  await _adminService.approveRequest(
                                    doc.id,
                                    userId,
                                    points,
                                  );

                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Request approved successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                              child: const Text(
                                'Approve Request',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, int> data) {
    final totalItems = data.values.fold<int>(0, (sum, value) => sum + value);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Recycled Materials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Donut Chart
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    sections: [
                      PieChartSectionData(
                        value: data['plastic']?.toDouble() ?? 0,
                        color: Colors.green,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        value: data['glass']?.toDouble() ?? 0,
                        color: Colors.blue,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        value: data['metal']?.toDouble() ?? 0,
                        color: Colors.yellow,
                        title: '',
                        radius: 20,
                      ),
                      PieChartSectionData(
                        value: data['electronics']?.toDouble() ?? 0,
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
                      '$totalItems',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'items',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const Text(
                      'Total',
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
          const SizedBox(height: 24),

          // Legend Table
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              const TableRow(
                children: [
                  Text('MATERIAL', style: TextStyle(color: Colors.grey)),
                  Text('TOTAL', style: TextStyle(color: Colors.grey)),
                ],
              ),
              _buildTableRow('Plastic', '${data['plastic'] ?? 0} items', Colors.green),
              _buildTableRow('Glass', '${data['glass'] ?? 0} items', Colors.blue),
              _buildTableRow('Metal', '${data['metal'] ?? 0} items', Colors.yellow),
              _buildTableRow('Electronics', '${data['electronics'] ?? 0} items', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String material, String total, Color color) {
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(total),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Graph
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Map<String, int>>(
                future: _adminService.getTotalRecyclingStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 300,
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }
                  return _buildStatsCard(snapshot.data ?? {});
                },
              ),
            ),

            // Requests List
            StreamBuilder<QuerySnapshot>(
              stream: _adminService.getRecyclingRequests(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No recycling requests found'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return _buildRequestCard(context, doc);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
