for ((i=1; i<=65; i++)); do
	curl --header "Connection: keep-alive" "http://localhost:8080/remote_device.php/?ID=2&Rele=1";
done
