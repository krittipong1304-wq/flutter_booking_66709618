<?php
include 'condb.php';
header('Content-Type: application/json');

$id = intval($_GET['id']);

$stmt = $conn->prepare("DELETE FROM rooms WHERE id = ?");
$result = $stmt->execute([$id]);

echo json_encode(["success" => $result]);

?>