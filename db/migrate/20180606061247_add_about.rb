class AddAbout < ActiveRecord::Migration[5.2]
  def self.up
    str =<<-HEREDOC
## About the platform

Amplify is a platform designed to deliver audio collections from the State Library of New South Wales’ sound archive alongside computer-generated transcripts. These transcripts can be edited by any user to improve their accuracy and ultimately enrich our sound collections for the benefit of all State Library patrons nationally and internationally.

## The problem? Unsearchable, inaccessible audio

As part of our Digital Excellence Program, the State Library has been focussed on the significant undertaking of digitising our world-class collections, aiming to not only preserve them but also provide greater access to broader audiences around the globe. To date the Library has digitised more than 10,000 hours of sound recordings from our collections but in order to make them truly accessible, searchable and valuable, each audio file also needs a corresponding transcript. Unfortunately human transcripts are a costly and time consuming undertaking, making it challenging for the Library to complete this mammoth task on our own.

Recent advances in speech-to-text technologies have meant we’ve seen great progress in computer-generated transcripts, making it easier to produce transcripts for our wonderful sound collections. While the accuracy of these transcripts are higher than ever before, they still tend to be error-prone and require careful human editing to reach full accuracy.

## The solution? You!

Correcting our computer-generated transcripts is a community effort and you can help us to improve the quality of each transcript by correcting just a single line or every single line in an entire audio recording – every bit counts! Listen along to our great sound collections and if you spot an error, click on the line with the mistake, make your correction and then continue listening on. It’s as easy as that!

## Access to our sound collections

If you are interested in getting access to our sound collections for research, media or personal interest purposes, please submit a request through our [Ask A Librarian](http://www.sl.nsw.gov.au/research-and-collections/ask-librarian) service.

## About the development

Amplify was developed using [New York Public Library’s](http://nypl.org) open source [codebase](https://github.com/nypl/transcript-editor) for their own [Transcript Editor](http://transcribe.oralhistory.nypl.org). Without the NYPL’s dedication to innovation and contribution to the open source community globally, the State Library’s Amplify project would not have been possible.

If you would like to create your own installation of Amplify, our customised codebase can be found in the State Library's [GitHub repository](https://github.com/slnswgithub/nsw-state-library-amplify).

Amplify’s development and customisation was done by the State Library of New South Wales in partnership with [Reinteractive](https://reinteractive.net), a Sydney based Ruby on Rails development agency.

The computer-generated transcripts used on our platform were produced by [VoiceBase](https://www.voicebase.com).

<div class="logo-strip">
  <a href="http://nypl.org"><img src="/nsw-state-library-amplify/assets/img/nypl_logo.jpg" alt="New York Public Library logo" title="New York Public Library"></a>
  <a href="https://reinteractive.net"><img src="/nsw-state-library-amplify/assets/img/reinteractive_logo.png" alt="Reinteractive logo" title="Reinteractive"></a>
  <a href="https://www.voicebase.com"><img src="/nsw-state-library-amplify/assets/img/voice_base_logo.png" alt="VoiceBase logo" title="VoiceBase"></a>
</div>

## Contacts

If you would like to know more about Amplify or find information about other digital volunteering projects, you can visit the [State Library website](http://www.sl.nsw.gov.au/research-and-collections-research-and-engagement/digital-volunteering) or send us an email at [digital.volunteering@sl.nsw.gov.au](mailto:digital.volunteering@sl.nsw.gov.au).

Media enquiries: [(02) 9273 1566](tel:+61292731566) or [media.library@sl.nsw.gov.au](media.library@sl.nsw.gov.au)

Technical/development enquiries: [web.development@sl.nsw.gov.au](mailto:web.development@sl.nsw.gov.au)

<div class="logo-strip">
  <a href="http://www.justice.nsw.gov.au/"><img class="lock-size" src="/nsw-state-library-amplify/assets/img/nsw-justice.png" alt="NSW Department of Justice logo" title="NSW Department of Justice"></a>
  <a href="http://www.sl.nsw.gov.au"><img class="lock-size" src="/nsw-state-library-amplify/assets/img/slnsw-175.png" alt="State Library of NSW logo" title="State Library of NSW"></a>
</div>
   HEREDOC
    page = Page.new(content: str, page_type: 'about')
    page.ignore_callbacks = true
    page.save
  end

  def self.down
    Page.where(page_type: 'about').delete_all
  end
end
