import times, strutils, httpclient, os, parsecsv, json, zip/zipfiles

type
  Smnar* = HttpClient ## Servicio Meteorologico Nacional Argentina API Client https://www.smn.gob.ar
  SmnarEndpoints* = enum  ## Servicio Meteorologico Nacional Argentina API Endpoints. NO FUNCIONAN Pron5D y DatoHorario???.
    TiePre = "tiepre", Pron5D = "pron5d", RadSolar = "radsolar", Estaciones = "estaciones", DatoHorario = "datohorario", RegTemp = "regtemp", Alertas = "alertas"

const meses2int = [
  ("enero", "01"), ("febrero", "02"), ("marzo", "03"), ("abril", "04"), ("mayo", "05"), ("junio", "06"),
  ("julio", "07"), ("agosto", "08"), ("septiembre", "09"), ("octubre", "10"), ("noviembre", "11"), ("diciembre", "12"),
]

template getLink*(this: Smnar, endpoint: SmnarEndpoints): string =
  "https://ssl.smn.gob.ar/dpd/zipopendata.php?dato=" & $endpoint

proc downloadFile*(this: Smnar, path: string, endpoint: SmnarEndpoints, unzip = true): string =
  result = path / $endpoint & ".zip"
  let client = newHttpClient()
  client.downloadFile(this.getLink(endpoint), result)
  if unzip:
    var z: ZipArchive
    doAssert z.open(result), "Error extracting ZIP; Corrupted ZIP or API error."
    z.extractAll(path)
    z.close()

proc getEstadoActual*(this: Smnar, fecha = now()): seq[JsonNode] =
  let f = getTempDir() / "estado_tiempo" & format(fecha, "yyyyMMdd") & ".txt"
  if not existsFile(f): echo this.downloadFile(getTempDir(), TiePre)
  var parser: CsvParser
  parser.open(f, separator = ';', skipInitialSpace = true)
  var counter: byte
  while parser.readRow():
    result.add %*{
      "id":          counter,
      "estacion":    parser.row[0].normalize,
      "datetime":    try: $parse(multiReplace(parser.row[1].normalize, meses2int) & parser.row[2].normalize, "dd-MM-yyyyH:m") except: $now(),
      "estado":      parser.row[3].normalize,
      "visibilidad": try: parseInt(parser.row[4].normalize.strip.replace(" km", "")) except: 0,
      "temperatura": try: parseFloat(parser.row[5].normalize) except: 0.0,
      "termica":     try: parseFloat(parser.row[6].normalize) except: 0.0,
      "humedad":     try: parseInt(parser.row[7].normalize)   except: 0,
      "velocidad":   try: parseInt(parser.row[8].split()[^1]) except: 0,
      "direccion":   try: parser.row[8].normalize.split()[0]  except: "?",
      "presion":     try: parseFloat(parser.row[9].replace("/", "").strip) except: 0.0,
    }
    inc counter
  parser.close()

proc getEstaciones*(this: Smnar): string =
  let f = getTempDir() / "estaciones_smn.txt"
  if not existsFile(f): echo this.downloadFile(getTempDir(), Estaciones)
  result = readFile(f).normalize.strip

proc getRadiacionSolar*(this: Smnar, fecha = now()): seq[JsonNode] =
  let f = getTempDir() / "radiacion_solar" & format(fecha, "yyyyMMdd") & ".txt"
  if not existsFile(f): echo this.downloadFile(getTempDir(), RadSolar)
  var parser: CsvParser
  parser.open(f, skipInitialSpace = true)
  var counter: byte
  parser.readHeaderRow()
  while parser.readRow():
    result.add %*{
      "id":          counter,
      "datetime":    try: $parse(parser.row[0].normalize, "yyyy-MM-dd H:m:ss") except: $now(),
      "global_bsas": try: parseFloat(parser.row[1].normalize) except: 0.0,
      "difusa_bsas": try: parseFloat(parser.row[2].normalize) except: 0.0,
      "global_ush":  try: parseFloat(parser.row[3].normalize) except: 0.0,
      "difusa_ush":  try: parseFloat(parser.row[4].normalize) except: 0.0,
    }
    inc counter
  parser.close()

proc getTemperatura365*(this: Smnar): seq[JsonNode] =
  let f = getTempDir() / "registro_temperatura365d_smn.txt"
  if not existsFile(f): echo this.downloadFile(getTempDir(), RegTemp)
  var counter: byte
  for line in readFile(f).normalize.strip.splitLines()[2..^1]:
    var columns = line.splitWhitespace()
    if columns.len >= 4:
      result.add %*{
        "id":       counter,
        "datetime": try: $parse(columns[0], "ddMMyyyy") except: $now(),
        "maxima":   try: parseFloat(columns[1].normalize.strip) except: 0.0,
        "minima":   try: parseFloat(columns[2].normalize.strip) except: 0.0,
        "nombre":   columns[3..^1].join" "
      }
    inc counter

proc getAlertas365*(this: Smnar): seq[string] =
  let f = getTempDir() / "alertas_meteorologicas_smn.txt"
  if not existsFile(f): echo this.downloadFile(getTempDir(), Alertas)
  readFile(f).normalize.strip.split("-----------------------------------------------------------------------------------")

when isMainModule:
  case paramStr(1).normalize.replace("-", "")
  of "licensia", "licence": quit("MIT", 0)
  of "estaciones": quit($Smnar().getEstaciones(), 0)
  of "radiacion":
    for item in Smnar().getRadiacionSolar(): echo item.pretty
  of "temperaturas365", "temperatura365":
    for item in Smnar().getTemperatura365(): echo item.pretty
  of "alertas365", "alerta365":
    for item in Smnar().getAlertas365(): echo item
  of "actual", "estadoactual":
    for item in Smnar().getEstadoActual(): echo item.pretty
  of "ayuda", "help":
    echo "\tsmnar actual\n\tsmnar alerta365\n\tsmnar temperatura365\n\tsmnar radiacion\n\tsmnar estaciones\n\tsmnar licensia\n"
  else: quit("Error, use:\n\ttsmnar ayuda", 1)
  quit()
