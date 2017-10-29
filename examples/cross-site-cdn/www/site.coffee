document.reveal = ->
  msg = "JavaScript works! The current time is #{moment().format('MMMM Do YYYY, h:mm:ss a')}"
  $("#timeLabel").html msg
