<?php

header("Content-Type: application/json");
include "condb.php";

$room_id = $_POST['room_id'];
$user_name = $_POST['user_name'];
$booking_date = $_POST['booking_date'];
$start_time = $_POST['start_time'];
$end_time = $_POST['end_time'];

////////////////////////////////////////////////////
// CHECK TIME CONFLICT
////////////////////////////////////////////////////

$sql_check = "SELECT * FROM bookings
WHERE room_id = :room_id
AND booking_date = :booking_date
AND start_time < :end_time
AND end_time > :start_time";

$stmt = $conn->prepare($sql_check);

$stmt->bindParam(":room_id",$room_id);
$stmt->bindParam(":booking_date",$booking_date);
$stmt->bindParam(":start_time",$start_time);
$stmt->bindParam(":end_time",$end_time);

$stmt->execute();

if($stmt->rowCount() > 0){

    echo json_encode([
        "status"=>"unavailable",
        "message"=>"ห้องไม่ว่าง เวลาซ้อนกัน"
    ]);

    exit;
}

////////////////////////////////////////////////////
// INSERT BOOKING
////////////////////////////////////////////////////

$sql = "INSERT INTO bookings
(room_id,user_name,booking_date,start_time,end_time)
VALUES
(:room_id,:user_name,:booking_date,:start_time,:end_time)";

$stmt = $conn->prepare($sql);

$stmt->bindParam(":room_id",$room_id);
$stmt->bindParam(":user_name",$user_name);
$stmt->bindParam(":booking_date",$booking_date);
$stmt->bindParam(":start_time",$start_time);
$stmt->bindParam(":end_time",$end_time);

if($stmt->execute()){

    echo json_encode([
        "status"=>"success"
    ]);

}else{

    echo json_encode([
        "status"=>"error"
    ]);

}

?>