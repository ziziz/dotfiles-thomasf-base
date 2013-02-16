K = KeyboardJS


K.on "e", ->
  editFile("index.html")

K.on "g", ->
  window.location = window.location

for element in document.querySelectorAll "a[kb]"
  binding = element.attributes['kb'].value
  url = element.attributes['href'].value
  K.on binding, (-> window.location = this).bind(url)

editFile = (file) ->
  r = new XMLHttpRequest()
  r.open "POST", "/files/#{file}"
  r.setRequestHeader "Content-Type", "application/json;charset=UTF-8"
  r.send("")


# Local Variables:
# eval: (coffee-cos-mode 1)
# End: