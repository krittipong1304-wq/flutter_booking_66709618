<?php

header("Content-Type: application/json; charset=UTF-8");

include "condb.php";

try {

    $stmt = $conn->query("SELECT * FROM rooms");

    $data = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($data, JSON_UNESCAPED_UNICODE);

} catch (PDOException $e) {

    echo json_encode([
        "error" => $e->getMessage()
    ]);

}

?>