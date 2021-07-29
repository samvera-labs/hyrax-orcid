//= require_tree .

  $(document).ready(function(){
    $("body").on("click", ".js-orcid-sync-work-toggle", function(){
      let attr = $(this).prop("checked") ? "on" : "off"

      $.ajax({
        dataType: "json",
        url: $(this).data(`toggle-${attr}`),
      });
    });
  })
