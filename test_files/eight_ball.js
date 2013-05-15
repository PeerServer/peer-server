function fetchAnswer() {
    onsuccess = function(res) {
        var elem = document.getElementById("answer");
        elem.innerHTML = res;
    };
    $.ajax("magic_eight_ball", {success: onsuccess});
}
