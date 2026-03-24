import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddroomPage extends StatefulWidget {
  const AddroomPage({super.key});

  @override
  State<AddroomPage> createState() => _AddroomPageState();
}

class _AddroomPageState extends State<AddroomPage> {
  final TextEditingController roomNameController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  XFile? selectedImage;
  bool isSaving = false;

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

  Future<void> saveroom() async {
    if (isSaving) {
      return;
    }

    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("กรุณาเลือกรูปภาพ")));
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final url = Uri.parse(
        "http://localhost/flutter_booking_66709618/php_api/insert_room.php",
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['room_name'] = roomNameController.text.trim();
      request.fields['capacity'] = capacityController.text.trim();
      request.fields['location'] = locationController.text.trim();

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

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);

      if (!mounted) {
        return;
      }

      if (data["success"] == true) {
        Navigator.pop(context, "เพิ่มห้องเรียบร้อย");
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
    return Scaffold(
      appBar: AppBar(title: const Text("เพิ่มสินค้า")),
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
                      ? const Center(child: Text("แตะเพื่อเลือกรูป"))
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
              const SizedBox(height: 15),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "จำนวน",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: locationController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "ชั้น/ห้อง",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : saveroom,
                  child: Text(isSaving ? "กำลังบันทึก..." : "บันทึกสินค้า"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
