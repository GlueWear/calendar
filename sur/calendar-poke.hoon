::  sur/calendar-poke — cross-ship Calendar poke vocabulary.
::  Shared by app/calendar and mar/calendar-poke so both ships agree on the
::  wire type. Remote pokes use mark %calendar-poke (not %noun) so the mark's
::  grab molds the incoming noun into cal-poke instead of nest-failing.
|%
+$  cal-poke
  $%  [%follow event-key=@t raw=@t kind=?(%save %ref)]
      [%unfollow event-key=@t]
      [%event-update event-key=@t raw=@t]
      [%sync-update event-key=@t raw=@t]
      [%sync-request event-key=@t]
  ==
--
