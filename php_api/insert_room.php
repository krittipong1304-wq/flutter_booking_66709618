<?php
include 'condb.php';

header('Content-Type: application/json');

$room_name = $_POST['room_name'];
$capacity = $_POST['capacity'];
$location = $_POST['location'];

////////////////////////////////////////////////////////////
// ✅ รับรูปภาพ
////////////////////////////////////////////////////////////

$imageName = "";

if (isset($_FILES['image'])) {

    $targetDir = "images/";   // ✅ โฟลเดอร์เก็บรูป
    $imageName = time() . "_" . basename($_FILES["image"]["name"]);
    $targetFile = $targetDir . $imageName;

    if (!move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
        echo json_encode([
            "success" => false,
            "error" => "Upload image failed"
        ]);
        exit;
    }
}

////////////////////////////////////////////////////////////
// ✅ Insert DB
////////////////////////////////////////////////////////////

try {

    $stmt = $conn->prepare("
        INSERT INTO rooms (room_name, capacity, location, image)
        VALUES (:room_name, :capacity, :location, :image)
    ");

    $stmt->bindParam(":room_name", $room_name);
    $stmt->bindParam(":capacity", $capacity);
    $stmt->bindParam(":location", $location);
    $stmt->bindParam(":image", $imageName);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
