<?php
include "condb.php";

try {

    $stmt = $conn->query("SELECT * FROM rooms");
    $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($users);
    
} catch (PDOException $e) {
    echo json_encode(["error" => $e->getMessage()]);
}
?>
