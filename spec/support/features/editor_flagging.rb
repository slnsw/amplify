# frozen_string_literal: true

# The flag control of a transcript line, shared by the editor page object.
#
# Flagging goes through the modal gulp/js/views/transcripts/_flag.js renders: the
# line's flag control loads the line's flags, the modal posts a new one to
# `/flags.json`, and the line's `flag_count` is what makes the editor show it as
# flagged again after a reload.
#
# Including page objects need `click_line_button`, `texts_for`, `line` and `page`.
module EditorFlagging
  FLAG_BUTTON = '.button.flag'
  FLAG_MODAL = '#transcript-line-flag .modal.active'
  FLAG_OPTION = "#{FLAG_MODAL} #flag-add .option".freeze
  FLAG_COMMENT = "#{FLAG_MODAL} #flag-add .input-text".freeze
  FLAG_SUBMIT = "#{FLAG_MODAL} .submit".freeze
  FLAG_MESSAGE = "#{FLAG_MODAL} .message.active".freeze

  def line_flagged?(index) = line(index).all(FLAG_BUTTON, visible: :all).any? { |b| b[:class].include?('active') }

  # Opens the line's flag modal, chooses `type_label` and submits it. Returns
  # once the view's confirmation is on screen, which it only writes from the
  # POST's success callback.
  def flag_line(index, type_label, comment: nil)
    click_line_button(index, FLAG_BUTTON)
    page.find(FLAG_OPTION, text: type_label, exact_text: true).click
    page.find(FLAG_COMMENT).click.send_keys(comment) if comment
    page.find(FLAG_SUBMIT).click
    flag_confirmation
    self
  end

  def flag_confirmation = page.find(FLAG_MESSAGE).text

  # Opens the line's flag modal and reads the entries it renders from the flags it
  # was given (`#flag-index .flag`, one per flag, from Flag.getByLine). This is the
  # browser's copy of the saved flags, which the line's flag icon only counts.
  def flag_entries(index)
    click_line_button(index, FLAG_BUTTON)
    page.find("#{FLAG_MODAL} .view-flags").click
    texts_for("#{FLAG_MODAL} #flag-index .flag", within: page.find(FLAG_MODAL))
  end
end
