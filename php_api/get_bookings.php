<?php

header("Content-Type: application/json; charset=UTF-8");

include "condb.php";

try {

    // ตรวจสอบว่ามี room_id หรือไม่
    if(isset($_GET['room_id'])){

        $room_id = $_GET['room_id'];

        $sql = "SELECT 
                    b.id,
                    r.room_name,
                    r.image,
                    b.booking_date,
                    b.start_time,
                    b.end_time,
                    b.user_name
                FROM bookings b
                JOIN rooms r ON b.room_id = r.id
                WHERE b.room_id = ?
                AND b.booking_date >= CURDATE()
                ORDER BY b.booking_date ASC";

        $stmt = $conn->prepare($sql);
        $stmt->execute([$room_id]);

    }else{

        $sql = "SELECT 
                    b.id,
                    r.room_name,
                    r.image,
                    b.booking_date,
                    b.start_time,
                    b.end_time,
                    b.user_name
                FROM bookings b
                JOIN rooms r ON b.room_id = r.id
                WHERE b.booking_date >= CURDATE()
                ORDER BY b.booking_date ASC";

        $stmt = $conn->query($sql);

    }

    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($data, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {

    echo json_encode([
        "error" => $e->getMessage()
    ]);

}

?>