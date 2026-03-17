import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingPage extends StatefulWidget {

  final Map room;
  final String name;

  const BookingPage({
    super.key, 
    required this.room, 
    required this.name});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late TextEditingController nameController;
  final dateController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
  }
  ////////////////////////////////////////////////////////////
  // DATE PICKER
  ////////////////////////// //////////////////////////////////
//เพิ่มใส่ชื่อคน



  Future pickDate() async {

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // ห้ามเลือกวันที่ย้อนหลัง
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2,'0')}-${picked.day.toString().padLeft(2,'0')}";
      });
    }

  }

  ////////////////////////////////////////////////////////////
  // TIME PICKER
  ////////////////////////////////////////////////////////////

  Future pickStartTime() async {

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        startController.text =
            "${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}";
      });
    }

  }

  Future pickEndTime() async {

    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        endController.text =
            "${picked.hour.toString().padLeft(2,'0')}:${picked.minute.toString().padLeft(2,'0')}";
      });
    }

  }

  ////////////////////////////////////////////////////////////
  // SAVE BOOKING
  ////////////////////////////////////////////////////////////

  Future saveBooking() async {

    // ตรวจสอบกรอกข้อมูลครบ
    if(nameController.text.isEmpty ||
        dateController.text.isEmpty ||
        startController.text.isEmpty ||
        endController.text.isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบ")),
      );
      return;
    }

    // ตรวจสอบเวลาเริ่ม < เวลาสิ้นสุด
    if(startController.text.compareTo(endController.text) >= 0){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เวลาเริ่มต้องน้อยกว่าเวลาสิ้นสุด")),
      );
      return;
    }

    var url = Uri.parse(
        "http://localhost/flutter_booking_66709618/php_api/add_booking.php");

    var response = await http.post(
      url,
      body: {

        "room_id": widget.room['id'].toString(),
        "user_name": nameController.text,
        "booking_date": dateController.text,
        "start_time": startController.text,
        "end_time": endController.text

      },
    );

    var data = jsonDecode(response.body);

    if (data['status'] == "success") {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("จองสำเร็จ")),
      );

      Navigator.pop(context);

    }
    else if(data['status']=="unavailable"){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ห้องไม่ว่าง เวลาชนกัน")),
      );

    }
    else{

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เกิดข้อผิดพลาด")),
      );

    }

  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    startController.dispose();
    endController.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

 @override
Widget build(BuildContext context) {

  String roomName = widget.room['room_name'] ?? "Meeting Room";
  String roomImage = widget.room['image'] ?? "";

  return Scaffold(

    appBar: AppBar(
      title: Text("จอง $roomName"),
    ),

    body: Padding(

      padding: const EdgeInsets.all(16),

      child: SingleChildScrollView(

        child: Column(

          children: [

            ////////////////////////////////////////////////////////////
            // ROOM IMAGE
            ////////////////////////////////////////////////////////////

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                "http://localhost/flutter_booking_66709618/php_api/images/$roomImage",
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 15),

            ////////////////////////////////////////////////////////////
            // ROOM NAME
            ////////////////////////////////////////////////////////////

            Text(
              roomName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ////////////////////////////////////////////////////////////
            // USER NAME
            ////////////////////////////////////////////////////////////

            TextField(
              controller: nameController,
              readOnly:true,
              decoration: const InputDecoration(
                labelText: "ชื่อผู้จอง",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            ////////////////////////////////////////////////////////////
            // DATE
            ////////////////////////////////////////////////////////////

            TextField(
              controller: dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "วันที่จอง",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: pickDate,
            ),

            const SizedBox(height: 15),

            ////////////////////////////////////////////////////////////
            // START TIME
            ////////////////////////////////////////////////////////////

            TextField(
              controller: startController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "เวลาเริ่ม",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: pickStartTime,
            ),

            const SizedBox(height: 15),

            ////////////////////////////////////////////////////////////
            // END TIME
            ////////////////////////////////////////////////////////////

            TextField(
              controller: endController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "เวลาสิ้นสุด",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.access_time),
              ),
              onTap: pickEndTime,
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveBooking,
                child: const Text("บันทึกการจอง"),
              ),
            )

          ],

        ),

      ),

    ),

  );

}


}