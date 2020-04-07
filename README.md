# SMNAR

- [Servicio Meteorologico Nacional Argentina](https://www.smn.gob.ar) API Client & GUI App, [powered by Nim](https://nim-lang.org)

![](https://raw.githubusercontent.com/juancarlospaco/nim-smnar/master/0.png "Servicio Meteorologico Nacional Argentina GUI App")


# Use

```nim
import smnar

let cliente = Smnar()
echo cliente.getEstadoActual()
echo cliente.getEstaciones()
echo cliente.getRadiacionSolar()
echo cliente.getTemperatura365()
echo cliente.getAlertas365()
```

Return data type is JSON.

```json
{
  "id": 122,
  "estacion": "base marambio",
  "datetime": "2020-01-09T23:00:00-03:00",
  "estado": "parcialmente nublado con neblina",
  "visibilidad": 10,
  "temperatura": 2.0,
  "termica": -3.0,
  "humedad": 80,
  "velocidad": 22,
  "direccion": "noroeste",
  "presion": 967.6
}
```


## Command line Use

```console
$ smnar actual
$ smnar alerta365
$ smnar temperatura365
$ tsmnar radiacion
$ tsmnar estaciones
$ tsmnar licensia
$ tsmnar ayuda
```

- All units are Metric. ~`111` Lines of code.
- Functions return JSON.
- Functions wont need arguments.
- Temperature is Celsius.
- `"velocidad"` is Wind Speed, `"direccion"` is Wind Direction.
- It is not documented when the data for current day becomes available, if you get errors use `fecha = now() - 1.days` for yesterdays data.
- At the time of writing some API endpoints wont work, then are not implemented on the code.


# Documentation

- https://juancarlospaco.github.io/nim-smnar


# SSL

- Compile with `-d:ssl` to use HTTPS and SSL.


# Install

- `nimble install smnar`


# See also

- https://github.com/juancarlospaco/nim-openweathermap#nim-openweathermap
- https://github.com/juancarlospaco/nim-open-elevation#nim-open-elevation
