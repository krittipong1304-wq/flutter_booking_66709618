import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'add_room_page.dart';
import 'edit_room_page.dart';
import 'home_page.dart';

const String baseUrl = "http://127.0.0.1/flutter_booking_66709618/php_api/";

class roompage extends StatefulWidget {
  final String name;

  const roompage({super.key, required this.name});

  @override
  State<roompage> createState() => _roompageState();
}

class _roompageState extends State<roompage> {
  List rooms = [];
  List filteredRooms = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchRooms() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}show_data.php"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;

        if (!mounted) {
          return;
        }

        setState(() {
          rooms = data;
          filteredRooms = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  void filterRooms(String query) {
    final keyword = query.toLowerCase();

    setState(() {
      filteredRooms = rooms.where((room) {
        final name = room['room_name']?.toString().toLowerCase() ?? '';
        return name.contains(keyword);
      }).toList();
    });
  }

  Future<void> deleteRoom(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}delete_room.php?id=$id"),
      );

      final data = json.decode(response.body);

      if (!mounted) {
        return;
      }

      if (data["success"] == true) {
        await fetchRooms();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบข้อมูลห้องเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  void confirmDelete(dynamic room) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("ต้องการลบ ${room['room_name']} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteRoom(int.parse(room['id'].toString()));
            },
            child: const Text("ลบ"),
          ),
        ],
      ),
    );
  }

  Future<void> openEdit(dynamic room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditroomPage(room: room)),
    );

    if (!mounted || result == null) {
      return;
    }

    await fetchRooms();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "ออกจากระบบ",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search room',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: filterRooms,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRooms.isEmpty
                    ? const Center(child: Text('No rooms found'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredRooms.length,
                        itemBuilder: (context, index) {
                          final room = filteredRooms[index];
                          final imageUrl =
                              "${baseUrl}images/${room['image'] ?? ''}";

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                width: 70,
                                height: 70,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_not_supported,
                                  ),
                                ),
                              ),
                              title: Text(room['room_name'] ?? 'No Name'),
                              subtitle: Text(room['location'] ?? ''),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    openEdit(room);
                                  } else if (value == 'delete') {
                                    confirmDelete(room);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('แก้ไข'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text('ลบ'),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => roomDetail(room: room),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddroomPage()),
          );

          if (!mounted || result == null) {
            return;
          }

          await fetchRooms();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.toString())));
        },
      ),
    );
  }
}

class roomDetail extends StatelessWidget {
  final dynamic room;

  const roomDetail({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${baseUrl}images/${room['image'] ?? ''}";

    return Scaffold(
      appBar: AppBar(
        title: Text(room['room_name'] ?? 'Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              room['room_name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text('Location: ${room['location'] ?? '-'}'),
            const SizedBox(height: 10),
            Text(
              'Capacity: ${room['capacity'] ?? '-'} คน',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
