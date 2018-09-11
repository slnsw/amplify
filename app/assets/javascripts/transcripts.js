$(document).ready(function(){
  $('input:radio').change(function() {
    toggleTranscriptUpload();
  });

  function toggleTranscriptUpload(){
    if ($("#transcript_transcript_type_voicebase").is(":checked")){
      $("#transcript_upload").hide();
    } else {
      $("#transcript_upload").show();
    }
  }
  toggleTranscriptUpload()
})
