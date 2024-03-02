setInterval(function () {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", "index.php", true);
  xhr.send();

  xhr.onreadystatechange = function () {
    if (this.readyState != 4) return;

    if (this.status != 200) {
      return;
    }

    var i_face = document.getElementById("App_interface");
    if (i_face != null) {
      i_face.innerHTML = this.responseText;
    }
  };
  delete xhr;
}, 3000);
