::  mar/calendar-poke — transferable mark for cross-ship Calendar pokes.
::  grad %noun makes it sendable over ames; grab/noun molds the wire noun into
::  cal-poke so remote pokes decode cleanly (unlike a raw %noun poke).
/-  calendar-poke
|_  msg=cal-poke:calendar-poke
++  grab
  |%
  ++  noun  cal-poke:calendar-poke
  --
++  grow
  |%
  ++  noun  msg
  --
++  grad  %noun
--
