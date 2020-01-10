# SMNAR

- [Servicio Meteorologico Nacional Argentina](http://smn.gob.ar) API Client.


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

**Returns** Return data type is JSON.

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


- Functions wont need arguments.
- It is not documented when the data for current day becomes available, if you get errors use `fecha = now() - 1.days` for yesterdays data.
- At the time of writing some API endpoints wont work, then are not implemented on the code.


# SSL

- Compile with `-d:ssl` to use HTTPS and SSL.


# Install

- `nimble install smnar`


# See also

- https://github.com/juancarlospaco/nim-openweathermap#nim-openweathermap
- https://github.com/juancarlospaco/nim-open-elevation#nim-open-elevation
