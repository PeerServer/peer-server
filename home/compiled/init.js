// Generated by CoffeeScript 1.6.2
(function() {
  $(document).ready(function() {
    var ENTER_KEY;

    ENTER_KEY = 13;
    $("#serverName").keyup(function(evt) {
      var name;

      if (evt.keyCode === ENTER_KEY) {
        name = $('#serverName').val();
        return window.location.href = "/server/" + name;
      }
    });
    return $(".create-server").click(function(evt) {
      var name, newLink, template;

      name = $('#serverName').val();
      template = $(this).attr("data-tmpl");
      newLink = "/server/" + name + "?template=" + template;
      return this.href = newLink;
    });
  });

}).call(this);
