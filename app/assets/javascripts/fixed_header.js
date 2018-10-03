// https://www.w3schools.com/howto/howto_js_sticky_header.asp
$(document).ready(function(){
  window.onscroll = function() {
    fixHeader()
  };

  var sticky = 0;


  var header = document.getElementById("fixedHeader");
  if (header) {
    sticky = header.offsetTop;
  }

  function fixHeader() {
    if (header == null) {
      return true
    }

    if (window.pageYOffset >= sticky) {
      header.classList.add("fixed-header");
      header.style.zIndex = 1
    } else {
      header.classList.remove("fixed-header");
    }
  }

  $('#select_title').on('click', function(event){
    event.preventDefault();
    $('.dropdown-content').toggle();
  })

  $('#collection_search').on('click', function(event){
    event.preventDefault();
    $('#collection_search .select-options').toggle()
  })
})

