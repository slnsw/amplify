# This set of tests ensures consensus works as expected on the data model level. This does not test the views or controllers.
# Usage:
#   Run all the tests: rake test test/models/transcript_edit_test.rb
#   Run one test: rake test test/models/transcript_edit_test.rb test_consensus_one

require 'test_helper'

class TranscriptEditTest < ActiveSupport::TestCase
  # called before every single test
  def setup
    # Seed/update the database with test data
    Vendor.create!(uid: 'voice_base', name: 'VoiceBase')
    seedProject
    seedTranscript
    seedUsers

    # Retrieve transcript line statuses
    @status_initialized = TranscriptLineStatus.find_or_create_by name: 'initialized'
    @status_editing = TranscriptLineStatus.find_or_create_by name: 'editing'
    @status_reviewing = TranscriptLineStatus.find_or_create_by name: 'reviewing'
    @status_completed = TranscriptLineStatus.find_or_create_by name: 'completed'
  end

  # called after every single test
  def teardown; end

  def seedProject
    puts "Seeding project..."
    data = {
      name: 'Test Project',
      description: 'Project used for testing scripts found in ./test',
      consensus: {
        maxLineEdits: 5,
        minLinesForConsensus: 3,
        minLinesForConsensusNoEdits: 5,
        minPercentConsensus: 0.34,
        superUserHiearchy: 50
      }
    }
    data = JSON.parse(data.to_json)
    @project = { uid: 'test_project', data: data }
  end

  def seedTranscript
    puts "Seeding transcript..."
    attributes = {
      uid: 'lucy', title: 'Lucy in the Sky with Diamonds',
      vendor: Vendor.find_or_create_by(uid: 'voice_base', name: 'VoiceBase')
    }
    @transcript = Transcript.find_or_initialize_by(uid: attributes[:uid])
    @transcript.update(attributes)
  end

  def seedUsers
    puts "Seeding users..."

    # registered user
    user_role = UserRole.find_or_create_by name: 'user', hiearchy: 1
    @registered_user = User.new(email: 'registered_user_1@test.com', password: 'password', password_confirmation: 'password', user_role_id: user_role.id)
    @registered_user.save

    # admin user
    admin_role = UserRole.find_or_create_by name: 'admin', hiearchy: 5
    @admin_user = User.new(email: 'admin_user_1@test.com', password: 'password', password_confirmation: 'password', user_role_id: admin_role.id)
    @admin_user.save
  end

  def seedLine(attributes)
    line = TranscriptLine.find_or_initialize_by({ transcript_id: attributes[:transcript_id], sequence: attributes[:sequence] })
    line.update(attributes)
    line
  end

  def seedEdit(attributes)
    edit = TranscriptEdit.find_or_initialize_by({transcript_line_id: attributes[:transcript_line_id], session_id: attributes[:session_id]})
    edit.update(attributes)
    edit
  end

  def seedEdits(edits)
    the_edits = []
    edits.each do |attributes|
      the_edits << seedEdit(attributes)
    end
    the_edits
  end

  # Consensus: three edits, all agree
  test "consensus one" do
    line = seedLine({transcript_id: @transcript.id, sequence: 1, original_text: 'Picture yerself in a goat on a hiver', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'one_1', text: 'Picture yourself in a boat on a river'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'one_2', text: 'Picture yourself in a boat on a river'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'one_3', text: 'Picture yourself in a boat on a river'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Picture yourself in a boat on a river"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: four edits, one is original text, two agree; choose the one with two
  test "consensus two" do
    line = seedLine({transcript_id: @transcript.id, sequence: 2, original_text: 'With tanjereen treez and marmalade skyz', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'two_1', text: 'With tangerine trees and marmalade skies'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'two_2', text: 'With tangerine trees and marmalade skies'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'two_3', text: 'With tanjereen treez and marmalade skyz'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'two_4', text: 'With tanjereen trees and marmalade skies'}
    ])
    line.recalculate(nil, @project)
    correct_text = "With tangerine trees and marmalade skies"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, all agree (with normalized text); choose the one with registered user
  test "consensus three" do
    line = seedLine({transcript_id: @transcript.id, sequence: 3, original_text: 'Somebody callz u, u answer kwite slowly', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'three_1', text: 'Somebody calls you, you answer quite slowly.', user_id: @registered_user.id},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'three_2', text: 'somebody calls you you answer quite slowly'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'three_3', text: 'Somebody calls YOU; you answer quite slowly'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Somebody calls you, you answer quite slowly."

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, all agree (with normalized text); choose the one with capitalization and uhms
  test "consensus four" do
    line = seedLine({transcript_id: @transcript.id, sequence: 4, original_text: 'A gurl with kaleidoscope eyez', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'four_1', text: 'A girl with kaleidoscope--ummm--eyes'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'four_2', text: 'A girl with kaleidoscope eyes'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'four_3', text: 'a girl with kaleidoscope eyes'}
    ])
    line.recalculate(nil, @project)
    correct_text = "A girl with kaleidoscope--ummm--eyes"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, two agree (with normalized text); choose the one with punctuation
  test "consensus five" do
    line = seedLine({transcript_id: @transcript.id, sequence: 5, original_text: 'Sellophane flowerz of yellow and green', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'five_1', text: 'Cellophane flowers, of yellow and green.'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'five_2', text: 'Cellophane flowers, of yellow and green'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'five_3', text: 'Cellophane flowerz of yellow and green'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Cellophane flowers, of yellow and green."

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Guess: three edits, nobody agrees; choose the one with a registered user
  test "guess one" do
    line = seedLine({transcript_id: @transcript.id, sequence: 6, original_text: 'Towering over ure hed', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'six_1', text: 'Towering over your head', user_id: @registered_user.id},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'six_2', text: 'Towering over ure head'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'six_3', text: 'Towering over your hed'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Towering over your head"

    assert line.text.blank?, "Text is not yet final"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_editing.id, "Correct status: editing"
  end

  # Guess: three edits, nobody agrees; choose the one with punctuation
  test "guess two" do
    line = seedLine({transcript_id: @transcript.id, sequence: 7, original_text: 'Look fer the gurl with the son in her eyez', guess_text: '', text: '', transcript_line_status_id: 1})

    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seven_1', text: 'Look for the girl, with the sun in her eyes.'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seven_2', text: 'Look fer the girl with the son in her eyez'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seven_3', text: 'Look fer the gurl, with the sun in her eyes'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Look for the girl, with the sun in her eyes."

    assert line.text.blank?, "Text is not yet final"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_editing.id, "Correct status: editing"
  end

  # Guess: three edits, nobody agrees; choose the one with numbers
  test "guess three" do
    line = seedLine({transcript_id: @transcript.id, sequence: 8, original_text: 'And she\'s gawn', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eight_1', text: 'And shes 4 gone'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eight_2', text: 'And shes gun'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eight_3', text: 'And she is gawn'}
    ])
    line.recalculate(nil, @project)
    correct_text = "And shes 4 gone"

    assert line.text.blank?, "Text is not yet final"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_editing.id, "Correct status: editing"
  end

  # Review: five edits, nobody agrees; make into "review" status
  test "review one" do
    line = seedLine({transcript_id: @transcript.id, sequence: 9, original_text: 'Loosie in the skie wit diamondz', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'nine_1', text: 'Loosie in the sky wit diamondz'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'nine_2', text: 'Loosie in the skie with diamondz'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'nine_3', text: 'Loosie in the skie wit diamonds'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'nine_4', text: 'Lucy in the skie wit diamondz'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'nine_5', text: 'Lucy in the sky with diamonds'}
    ])
    line.recalculate(nil, @project)

    assert line.text.blank?, "Text is not yet final"
    assert !line.guess_text.blank?, "A guess has been made"
    assert line.transcript_line_status_id == @status_reviewing.id, "Correct status: reviewing"
  end

  # Consensus: three edits, two agree, one is an admin; choose the one by an admin
  test "consensus six" do
    line = seedLine({transcript_id: @transcript.id, sequence: 10, original_text: 'Follow er down to a bridge bye a fountane', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'ten_1', text: 'Follow her down to a bridge by a fountain', user_id: @admin_user.id},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'ten_2', text: 'Follow her down to a bridge, bye a fountane'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'ten_3', text: 'Follow her down to a bridge, bye a fountane'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Follow her down to a bridge by a fountain"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, nobody agrees, one is an admin; choose the one by an admin
  test "consensus seven" do
    line = seedLine({transcript_id: @transcript.id, sequence: 11, original_text: 'wear rocking horse ppl eat marshmellow piez', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eleven_1', text: 'Where rocking horse people eat marshmallow pies', user_id: @admin_user.id},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eleven_2', text: 'wear rocking horse pepole eat marshmellow pies?'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'eleven_3', text: 'Where rocking horse ppl eat marshmellow piez'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Where rocking horse people eat marshmallow pies"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Guess: one edit, the guess should be that one
  test "guess four" do
    line = seedLine({transcript_id: @transcript.id, sequence: 12, original_text: 'Every1 smiles as you drift passed da flowerz', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'twelve_1', text: 'Everyone smiles as you drift past the flowers'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Everyone smiles as you drift past the flowers"

    assert line.text.blank?, "Text is not yet final"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_editing.id, "Correct status: editing"
  end

  # Consensus: five edits, all are original text; choose the original text
  test "consensus eight" do
    line = seedLine({transcript_id: @transcript.id, sequence: 13, original_text: 'That grow so incredibly high', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'thirteen_1', text: 'That grow so incredibly high'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'thirteen_2', text: 'That grow so incredibly high'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'thirteen_3', text: 'That grow so incredibly high'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'thirteen_4', text: 'That grow so incredibly high'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'thirteen_5', text: 'That grow so incredibly high'}
    ])
    line.recalculate(nil, @project)
    correct_text = "That grow so incredibly high"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, one original text by admin, two others not original; choose the one by the admin
  test "consensus nine" do
    line = seedLine({transcript_id: @transcript.id, sequence: 14, original_text: 'Newspaper taxis appear on the shore', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'fourteen_1', text: 'Newspaper taxiz appear on the sure'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'fourteen_2', text: 'Newspaper taxiz appear on the sure'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'fourteen_3', text: 'Newspaper taxis appear on the shore', user_id: @admin_user.id}
    ])
    line.recalculate(nil, @project)
    correct_text = "Newspaper taxis appear on the shore"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Test normalization of text
  test "normalized text one" do
    line = seedLine({transcript_id: @transcript.id, sequence: 15, original_text: 'Waiting to take you away', guess_text: '', text: '', transcript_line_status_id: 1})
    edit = seedEdit({transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'fifteen_1', text: 'Waiting?  to, uhm, um--uhmm TAKE you awayum! '})
    correct_text = "waiting to take you awayum"

    assert edit.normalizedText == correct_text, "Normalized text correct"
  end

  # Consensus: two edits, both agree; choose that one (it doesn't matter what the third is)
  test "consensus ten" do
    line = seedLine({transcript_id: @transcript.id, sequence: 16, original_text: 'Waiting 2 take u away', guess_text: '', text: '', transcript_line_status_id: 1})
    seedEdits([
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'sixteen_1', text: 'Waiting to take you away'},
      {transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'sixteen_2', text: 'Waiting to take you away'}
    ])
    line.recalculate(nil, @project)
    correct_text = "Waiting to take you away"

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == correct_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_completed.id, "Correct status: completed"
  end

  # Consensus: three edits, all are original text; no consensus
  test "consensus eleven" do
    text = 'Climb in the back with your head in the clouds'
    line = seedLine({ transcript_id: @transcript.id, sequence: 17, original_text: text, guess_text: '', text: '', transcript_line_status_id: 1 })
    seedEdits(
      [
        { transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seventeen_1', text: text },
        { transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seventeen_2', text: text },
        { transcript_id: @transcript.id, transcript_line_id: line.id, session_id: 'seventeen_3', text: text }
      ]
    )
    line.recalculate(nil, @project)
    correct_text = ""

    assert line.text == correct_text, "Correct text chosen"
    assert line.guess_text == line.original_text, "Correct guess chosen"
    assert line.transcript_line_status_id == @status_initialized.id, "Correct status: initialized"
  end
end
