import webgui, smnar, json, os, re  # Esta App es Beta WIP.

const htmlui = currentSourcePath().splitPath.head / "index.html"
var estado, temperatura, radiacion, alertas {.noInit.}: string
let clientito = Smnar()

proc updateEstado() {.inline.} = estado = sanitizer($(%clientito.getEstadoActual()))
proc updateTemperatura() {.inline.} = temperatura = sanitizer($(%clientito.getTemperatura365()))
proc updateRadiacion() {.inline.} = radiacion = sanitizer($(%clientito.getRadiacionSolar()))
proc updateAlertas() {.inline.} = alertas = sanitizer($(%clientito.getAlertas365()))
proc updateAll() =
  updateEstado()
  updateTemperatura()
  updateRadiacion()
  updateAlertas()
updateAll()

var app = newWebView(path = htmlui, title = "Servicio Meteorologico Nacional de Argentina")
app.bindProcs("api"):
  proc getEstadoActual() =
    app.js("document.querySelector('#estado').value = `" & estado & "`")
    updateEstado()
  proc getTemperatura365() =
    app.js("document.querySelector('#temperatura').value = `" & temperatura & "`")
    updateTemperatura()
  proc getRadiacionSolar() =
    app.js("document.querySelector('#radiacion').value = `" & radiacion & "`")
    updateRadiacion()
  proc getAlertas365() =
    app.js("document.querySelector('#alertas').value = `" & alertas & "`")
    updateAlertas()
app.run()
app.exit()
