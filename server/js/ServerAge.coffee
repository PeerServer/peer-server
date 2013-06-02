
class window.ServerAge
  constructor: (@elem) ->
    ONE_SECOND = 1000
    ONE_MINUTE = ONE_SECOND * 60
    ONE_HOUR = ONE_MINUTE * 60
    ONE_DAY = ONE_HOUR * 24
    ONE_WEEK = ONE_DAY * 7
    timeElem = @elem.find(".server-age")
    timeElem.html("0 minutes")

    start = (new Date()).getTime() # Get time gives time in milliseconds
    setInterval =>
      curr = (new Date()).getTime()
      diff = curr - start
      time = ""
      first = true
      weeks = Math.floor(diff/ONE_WEEK)
      time += @convertToString(weeks, "week", first)
      diff = diff - (weeks * ONE_WEEK)
      first = if first then weeks < 1 else false  # Is this the first non-zero time?

      days = Math.floor(diff/ONE_DAY)
      time += @convertToString(days, "day", first)
      diff = diff - (days * ONE_DAY)
      first = if first then days < 1 else false  # Is this the first non-zero time?

      hours = Math.floor(diff/ONE_HOUR)
      time += @convertToString(hours, "hour", first)
      diff = diff - (hours * ONE_HOUR)
      first = if first then hours < 1 else false  # Is this the first non-zero time?

      minutes = Math.floor(diff/ONE_MINUTE)
      time += @convertToString(minutes, "minute", first)

      timeElem.html(time)

    , ONE_MINUTE

  convertToString: (number, name, first) =>
    if number < 1
      return ""
    if number > 1
      name += "s"
    start = if not first then ", " else ""
    return start + number + " " + name
