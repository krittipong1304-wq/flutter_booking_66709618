<?php
include "condb.php";

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

$sql = "SELECT * FROM employees WHERE username=:username AND password=:password";

$stmt = $conn->prepare($sql);
$stmt->bindParam(':username',$username);
$stmt->bindParam(':password',$password);
$stmt->execute();

$user = $stmt->fetch(PDO::FETCH_ASSOC);

if($user){

 echo json_encode([
  "status"=>"success",
  "username"=>$user["username"],
  "name"=>$user["name"] ?? ""
 ]);

}else{

 echo json_encode([
  "status"=>"error"
 ]);

}
?>