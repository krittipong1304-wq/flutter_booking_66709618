<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include 'condb.php';
header('Content-Type: application/json');

try {

    $id = $_POST['id'];
    $room_name = $_POST['room_name'];
    $capacity = $_POST['capacity'];
    $location = $_POST['location'];
    $oldImage = $_POST['old_image'];

    $imageName = $oldImage;

    if (isset($_FILES['image'])) {

        $targetDir = "images/";
        $imageName = time() . "_" . basename($_FILES["image"]["name"]);
        $targetFile = $targetDir . $imageName;

        if (move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {

            if ($oldImage != "" && file_exists($targetDir . $oldImage)) {
                unlink($targetDir . $oldImage);
            }

        } else {
            echo json_encode([
                "success" => false,
                "error" => "Upload failed"
            ]);
            exit;
        }
    }

    $sql = "UPDATE rooms 
            SET room_name = :room_name,
                capacity = :capacity,
                location = :location,
                image = :image
            WHERE id = :id";

    $stmt = $conn->prepare($sql);

    $stmt->bindParam(':id', $id);
    $stmt->bindParam(':room_name', $room_name);
    $stmt->bindParam(':capacity', $capacity);
    $stmt->bindParam(':location', $location);
    $stmt->bindParam(':image', $imageName);

    $stmt->execute();

    echo json_encode(["success" => true]);

} catch (PDOException $e) {

    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
?>