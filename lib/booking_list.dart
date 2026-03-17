import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = "http://localhost/flutter_booking_66709618/php_api/";
const String imageUrl = "http://localhost/flutter_booking_66709618/php_api/images/";

class BookingList extends StatefulWidget {

  final int? roomId;

  const BookingList({super.key, this.roomId});

  @override
  State<BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<BookingList> {

  List bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  ////////////////////////////////////////////////////////////
  // FETCH BOOKINGS
  ////////////////////////////////////////////////////////////

  Future fetchBookings() async {

    String url;

    if(widget.roomId != null){
      url = "${baseUrl}get_bookings.php?room_id=${widget.roomId}";
    }else{
      url = "${baseUrl}get_bookings.php";
    }

    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      setState(() {
        bookings = json.decode(response.body);
      });
    }

  }

  ////////////////////////////////////////////////////////////
  // UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.roomId == null
          ? "รายการจองทั้งหมด"
          : "รายการจองห้อง"
        ),
      ),

      body: bookings.isEmpty
      ? const Center(child: Text("ยังไม่มีการจอง"))
      : ListView.builder(

        itemCount: bookings.length,

        itemBuilder: (context,index){

          final b = bookings[index];

          return Card(

            margin: const EdgeInsets.all(10),

            child: ListTile(

              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  "$imageUrl${b['image']}",
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              title: Text(
                b['room_name'] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 5),

                  Text("ผู้จอง: ${b['user_name']}"),

                  Text("วันที่: ${b['booking_date']}"),

                  Text("เวลา: ${b['start_time']} - ${b['end_time']}"),

                ],
              ),

              isThreeLine: true,

            ),

          );

        },

      ),

    );

  }

}