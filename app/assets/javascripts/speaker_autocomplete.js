$(document).ready(function(){
  $('#transcript_speakers').autocomplete({
    serviceUrl: "/admin/cms/transcripts/speaker_search?q" + $(this).val(),
    delimiter: ";"
  });
})

