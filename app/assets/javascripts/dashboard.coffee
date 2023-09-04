# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'ready', ->
  $('.toggle-link').on 'click', (e) ->
    e.preventDefault()
    link = $(this)
    transcriptId = link.attr('id')
    collapsible = $('#collapsed-' + transcriptId)
    collapsible.toggle()
    text = if collapsible.is(':hidden') then 'Expand' else 'Collapse'
    link.text text
    return
  return
