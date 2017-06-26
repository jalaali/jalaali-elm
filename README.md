# jalaali-elm


### Usage
To convert Gregorian to Jalali:

```elm
to_jalali (Date 2017 6 25)
```

To convert Jalali to Gregorian:
```elm
to_gregorian (Date 1395 4 20)
```

More examples:

```elm
import Html exposing (text)

today = Date 2017 6 25
main = 
  [ to_jalali today
  , to_gregorian {year=1396, month=04, day=04}
  ] |> toString
    |> text
```
