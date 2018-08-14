class AddFaqs < ActiveRecord::Migration[5.2]
  def self.up
    str =<<-HEREDOC
## Do I have to correct a transcription to be able to listen to an audio file?

No! While we would love you to jump in and get involved in correcting our computer-generated transcripts, you can also just simply listen to and enjoy an audio file by clicking the “Play All” button. The Amplify player will run through the transcript as you listen along and if you like you can begin correcting at any point within an audio file.

## Do I need to be logged in to contribute?

No! Anyone can contribute at any time without logging in. If you do choose to log in, you’ll be able to see all the edits you’ve made when you return the next time. This can be useful if you’re working on a long transcript and would like to return to it later. Your work is always automatically saved regardless of whether or not you’re logged in. If you chose to login, it's best to do so at the start of your editing session.

## I want to leave the page how do I save my work?

All your work is automatically saved. When you come to a stopping point, you don’t need to do anything extra to save your work!

## Why are there different progress bars?

This is a community effort. We display total progress made by the community in the transcript. Since we require several people to edit each transcript, the overall progress will appear less than your individual progress. Log in at the "Track Progress" to keep track of your individual progress through interviews.

## What happens if I make a mistake?

Don't worry! Edit the transcript as best you can from what you hear. Several people will edit each transcript to help ensure accuracy.

## The audio repeats on two lines. Which line should I transcribe it on?

Listen closely. If a word is cut off on one line, transcribe it on the line where you can hear it completely. If a word is spoken in its entirety on two lines, use your best judgment to transcribe it on just one line. These tricky transcriptions will be smoothed out during the verify stage.

## What happens if the line is correct and we don't need to make any edits?

Sometimes the computer-generated process hits it out of the park and transcribes a line perfectly. In that case, no edits are needed. When enough volunteers pass over a line without editing it, the line will reach consensus in the same manner as edited lines.

## What to do when a line is locked and still contains errors?

Sometimes a mistake will slip through and a line locked for editing may still contain an error. In this case, please use the flagging mechanism. By clicking on the flag symbol at the end of an incorrect line, you will be prompted to classify the error and to add an optional, explanatory note. Staff at the State Library will be periodically reviewing and correcting these flagged errors.

## Where can I see the completed transcripts?

At this time the transcripts will remain available here on Amplify – you can download a copy of each individual transcript by clicking “Download this transcript” at the top of each page. The State Library will be working on ingesting these transcripts into our Library catalogue, meaning that in the long term each transcript will be available through the official Library record of each collection.

## Do I need to come to the Library to help transcribe these audio collections?

Not at all! You can start transcribing on Amplify whenever and wherever suits you best. This is an online project and all you need to participate is a desktop or tablet and an internet connection.

## Can I delete and/or create a new line in the transcript?

No. Transcript lines are synced with clips of audio. For audio clips where the interviewer and/or interviewee are silent, we want to retain the empty line to show this.

## Several people are speaking in one line. What should I do?

Transcribe the audio as you hear it and tag the line as having multiple speakers by using the person icon at the beginning of each line.

## Can I use the tool on my phone?

You can access Amplify on your phone to listen to audio files, but editing is best done on a tablet or desktop.

## When will you be adding more collections to this platform?

We will be adding new collections from our sound archive periodically to Amplify for you to listen to and correct. If there is a particular collection you would like to be made available, please feel free to contact us.

## Still have a question?

If you would like to know more about Amplify or find information about other digital volunteering projects, you can visit the [State Library website](http://www.sl.nsw.gov.au) or send us an email at [digital.volunteering@sl.nsw.gov.au](mailto:digital.volunteering@sl.nsw.gov.au).
    HEREDOC
    page = Page.new(content: str, page_type: 'faq')
    page.ignore_callbacks = true
    page.save
  end

  def self.down
    Page.where(page_type: 'faq').delete_all
  end
end
