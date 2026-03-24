import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

const String baseUrl = "http://127.0.0.1/flutter_booking_66709618/php_api/";

class EditroomPage extends StatefulWidget {
  final dynamic room;

  const EditroomPage({super.key, required this.room});

  @override
  State<EditroomPage> createState() => _EditroomPageState();
}

class _EditroomPageState extends State<EditroomPage> {
  late TextEditingController roomNameController;
  late TextEditingController capacityController;
  late TextEditingController locationController;

  XFile? selectedImage;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    roomNameController = TextEditingController(text: widget.room['room_name']);
    capacityController = TextEditingController(
      text: widget.room['capacity']?.toString() ?? '',
    );
    locationController = TextEditingController(
      text: widget.room['location']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    roomNameController.dispose();
    capacityController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  Future<void> updateroom() async {
    if (isSaving) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("${baseUrl}update_room_with_image.php"),
      );

      request.fields['id'] = widget.room['id'].toString();
      request.fields['room_name'] = roomNameController.text.trim();
      request.fields['capacity'] = capacityController.text.trim();
      request.fields['location'] = locationController.text.trim();
      request.fields['old_image'] = widget.room['image']?.toString() ?? '';

      if (selectedImage != null) {
        if (kIsWeb) {
          final bytes = await selectedImage!.readAsBytes();
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              bytes,
              filename: selectedImage!.name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath('image', selectedImage!.path),
          );
        }
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (!mounted) {
        return;
      }

      if (data["success"] == true) {
        Navigator.pop(context, "แก้ไขห้องเรียบร้อย");
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${data["error"] ?? 'บันทึกไม่สำเร็จ'}")),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("เกิดข้อผิดพลาด: $e")));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${baseUrl}images/${widget.room['image'] ?? ''}";

    return Scaffold(
      appBar: AppBar(title: const Text("แก้ไขข้อมูล")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: isSaving ? null : pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all()),
                  child: selectedImage == null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        )
                      : kIsWeb
                      ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                      : Image.file(
                          File(selectedImage!.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: roomNameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อห้องพัก",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวน",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: "ชั้น/ห้อง",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : updateroom,
                  child: Text(isSaving ? "กำลังบันทึก..." : "บันทึก"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
