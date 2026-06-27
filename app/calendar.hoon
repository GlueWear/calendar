::  calendar -- Noltbook Calendar plugin.
/-  calendar-poke
/+  default-agent, dbug, server
|%
+$  state-0  [%0 events=(map @t @t)]
+$  state-1
  [%1 events=(map @t @t) followers=(map @t (set @p)) refs=(map @t (set @ta)) ref-following=(set @t) ref-events=(map @t @t)]
+$  versioned-state  $%  state-0  state-1  ==
+$  cal-poke  cal-poke:calendar-poke
+$  card  card:agent:gall
++  json-str-field
  |=  [key=@t blob=tape]
  ^-  (unit @t)
  =/  needle=tape  :(weld "\"" (trip key) "\":\"")
  =/  start  (find needle blob)
  ?~  start  ~
  =/  tail=tape  (slag (add u.start (lent needle)) blob)
  =/  end  (find "\"" tail)
  ?~  end  ~
  `(crip (scag u.end tail))
++  json-true-field
  |=  [key=@t blob=tape]
  ^-  ?
  =/  needle=tape  :(weld "\"" (trip key) "\":true")
  ?=(^ (find needle blob))
++  event-key
  |=  [our=@p raw=@t]
  ^-  @t
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  creator=@t  (fall (json-str-field 'creator' blob) (scot %p our))
  (crip :(weld (trip creator) ":" (trip id)))
++  event-creator
  |=  [our=@p raw=@t]
  ^-  @p
  =/  blob=tape  (trip raw)
  =/  creator=@t  (fall (json-str-field 'creator' blob) (scot %p our))
  (slav %p creator)
++  event-by-id
  |=  [id=@t items=(list @t)]
  ^-  (unit @t)
  ?~  items  ~
  =/  blob=tape  (trip i.items)
  =/  item-id=@t  (fall (json-str-field 'id' blob) '')
  ?:  =(id item-id)  `i.items
  $(items t.items)
++  reminder-card
  |=  [our=@p now=@da raw=@t]
  ^-  (list card)
  =/  blob=tape  (trip raw)
  =/  delay=(unit @t)  (json-str-field 'notifyInSec' blob)
  ?~  delay  ~
  ?:  =(0 (met 3 u.delay))  ~
  =/  sec=@ud  (rash u.delay dem)
  ?:  =(0 sec)  ~
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  updated=@t  (fall (json-str-field 'updatedAt' blob) '')
  =/  deadline=@da  (add now (mul sec ~s1))
  ~[[%pass /reminder/[id]/[updated] %arvo %b %wait deadline]]
++  clear-notification-card
  |=  [our=@p id=@t]
  ^-  card
  =/  notif-id=@t  (crip :(weld "event-" (trip id)))
  [%pass /noltbook-clear/[id] %agent [our %noltbook] %poke %noltbook-api !>([%clear-app-notification ~ `[%calendar `'Calendar' ~] notif-id])]
++  set-notification-card
  |=  [our=@p raw=@t]
  ^-  card
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  notif-id=@t  (crip :(weld "event-" (trip id)))
  =/  title=@t  (fall (json-str-field 'title' blob) 'Calendar event')
  =/  date=@t  (fall (json-str-field 'date' blob) '')
  =/  time=@t  (fall (json-str-field 'time' blob) '')
  =/  loc=@t  (fall (json-str-field 'location' blob) '')
  =/  body=@t  (crip :(weld "Starts " (trip date) " " (trip time) ?:(=(0 (met 3 loc)) "" " at ") (trip loc)))
  [%pass /noltbook-notify/[id] %agent [our %noltbook] %poke %noltbook-api !>([%set-app-notification ~ `[%calendar `'Calendar' ~] notif-id title `body `'/apps/calendar' ~ ~ `'warning' `604.800])]
++  event-changed-card
  |=  [our=@p raw=@t]
  ^-  card
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  updated=@t  (fall (json-str-field 'updatedAt' blob) '')
  =/  title=@t  (fall (json-str-field 'title' blob) 'Calendar event')
  =/  notif-id=@t  (crip :(weld "event-change-" (trip id) "-" (trip updated)))
  =/  msg=@t  (crip :(weld (trip title) " was changed"))
  =/  body=@t  'Open Calendar to review the new event details.'
  [%pass /noltbook-event-changed/[id] %agent [our %noltbook] %poke %noltbook-api !>([%set-app-notification ~ `[%calendar `'Calendar' ~] notif-id msg `body `'/apps/calendar' ~ ~ `'warning' `604.800])]
++  event-cancelled-card
  |=  [our=@p raw=@t]
  ^-  card
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  updated=@t  (fall (json-str-field 'updatedAt' blob) '')
  =/  title=@t  (fall (json-str-field 'title' blob) 'Calendar event')
  =/  notif-id=@t  (crip :(weld "event-cancel-" (trip id) "-" (trip updated)))
  =/  msg=@t  (crip :(weld (trip title) " has been cancelled"))
  =/  body=@t  'This event was removed from your Calendar reminders.'
  [%pass /noltbook-event-cancelled/[id] %agent [our %noltbook] %poke %noltbook-api !>([%set-app-notification ~ `[%calendar `'Calendar' ~] notif-id msg `body `'/apps/calendar' ~ ~ `'warning' `604.800])]
++  json-list
  |=  items=(list @t)
  ^-  @t
  =/  body=tape
    |-  ^-  tape
    ?~  items  ~
    ?~  t.items  (trip i.items)
    :(weld (trip i.items) "," $(items t.items))
  (crip :(weld "[" body "]"))
++  json-str-list
  |=  items=(list @t)
  ^-  @t
  =/  body=tape
    |-  ^-  tape
    ?~  items  ~
    =/  item=tape  :(weld "\"" (trip i.items) "\"")
    ?~  t.items  item
    :(weld item "," $(items t.items))
  (crip :(weld "[" body "]"))
++  json-ship-list
  |=  ships=(list @p)
  ^-  @t
  =/  body=tape
    |-  ^-  tape
    ?~  ships  ~
    =/  item=tape  :(weld "\"" (trip (scot %p i.ships)) "\"")
    ?~  t.ships  item
    :(weld item "," $(ships t.ships))
  (crip :(weld "[" body "]"))
++  json-followers
  |=  folmap=(map @t (set @p))
  ^-  @t
  =/  pairs=(list [@t (set @p)])  ~(tap by folmap)
  =/  body=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  row=tape  :(weld "\"" (trip -.i.pairs) "\":" (trip (json-ship-list ~(tap in +.i.pairs))))
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "{" body "}"))
++  json-refs
  |=  refmap=(map @t (set @ta))
  ^-  @t
  =/  pairs=(list [@t (set @ta)])  ~(tap by refmap)
  =/  body=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  row=tape  :(weld "\"" (trip -.i.pairs) "\":" (trip (json-str-list ~(tap in +.i.pairs))))
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "{" body "}"))
++  json-raw-map
  |=  rawmap=(map @t @t)
  ^-  @t
  =/  pairs=(list [@t @t])  ~(tap by rawmap)
  =/  body=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  row=tape  :(weld "\"" (trip -.i.pairs) "\":" (trip +.i.pairs))
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "{" body "}"))
++  json-followers-flat
  |=  folmap=(map @t (set @p))
  ^-  @t
  =/  pairs=(list [@t (set @p)])  ~(tap by folmap)
  =/  out=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  ships=(list @p)  ~(tap in +.i.pairs)
    =/  ships-json=@t  (json-ship-list ships)
    =/  row=tape  :(weld (trip '{"eventKey":"') (trip -.i.pairs) (trip '","ships":') (trip ships-json) "}")
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "[" out "]"))
++  json-refs-flat
  |=  refmap=(map @t (set @ta))
  ^-  @t
  =/  pairs=(list [@t (set @ta)])  ~(tap by refmap)
  =/  out=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  ids=(list @t)  ~(tap in +.i.pairs)
    =/  ids-json=@t  (json-str-list ids)
    =/  row=tape  :(weld (trip '{"eventKey":"') (trip -.i.pairs) (trip '","artifactIds":') (trip ids-json) "}")
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "[" out "]"))
++  json-raw-flat
  |=  rawmap=(map @t @t)
  ^-  @t
  =/  pairs=(list [@t @t])  ~(tap by rawmap)
  =/  out=tape
    |-  ^-  tape
    ?~  pairs  ~
    =/  row=tape  :(weld (trip '{"eventKey":"') (trip -.i.pairs) (trip '","event":') (trip +.i.pairs) "}")
    ?~  t.pairs  row
    :(weld row "," $(pairs t.pairs))
  (crip :(weld "[" out "]"))
++  json-follow-targets
  |=  [our=@p evmap=(map @t @t) refmap=(map @t @t)]
  ^-  @t
  =/  saved=(list [@t @t])  ~(tap by evmap)
  =/  refs=(list [@t @t])  ~(tap by refmap)
  =/  rows=tape
    =+  xs=saved
    |-  ^-  tape
    ?~  xs  ~
    =/  who=@p  (event-creator our +.i.xs)
    =/  rest=tape  $(xs t.xs)
    ?:  =(who our)  rest
    =/  row=tape  :(weld (trip '{"eventKey":"') (trip -.i.xs) (trip '","creator":"') (trip (scot %p who)) (trip '","kind":"save"}'))
    ?~  rest  row
    :(weld row "," rest)
  =/  ref-rows=tape
    =+  xs=refs
    |-  ^-  tape
    ?~  xs  ~
    =/  who=@p  (event-creator our +.i.xs)
    =/  rest=tape  $(xs t.xs)
    ?:  =(who our)  rest
    =/  row=tape  :(weld (trip '{"eventKey":"') (trip -.i.xs) (trip '","creator":"') (trip (scot %p who)) (trip '","kind":"ref"}'))
    ?~  rest  row
    :(weld row "," rest)
  =/  all=tape
    ?~  rows
      ref-rows
    ?~  ref-rows
      rows
    :(weld rows "," ref-rows)
  (crip :(weld "[" all "]"))
++  artifact-content
  |=  raw=@t
  ^-  @t
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  creator=@t  (fall (json-str-field 'creator' blob) '')
  (crip :(weld (trip '{"noltbookApp":1,"app":{"desk":"calendar","publisher":null},"ref":{"kind":"calendar-event","ship":"') (trip creator) (trip '","eventId":"') (trip id) (trip '"},"data":{"kind":"calendar-event","event":') (trip raw) "}}"))
++  edit-artifact-card
  |=  [our=@p art-id=@ta raw=@t]
  ^-  card
  [%pass /noltbook-edit/[art-id] %agent [our %noltbook] %poke %noltbook-api !>([%edit-artifact ~ art-id (artifact-content raw)])]
++  local-artifact-cards
  |=  [our=@p event-key=@t raw=@t refmap=(map @t (set @ta))]
  ^-  (list card)
  =/  ids=(set @ta)  (fall (~(get by refmap) event-key) *(set @ta))
  (turn ~(tap in ids) |=(id=@ta (edit-artifact-card our id raw)))
++  follow-card
  |=  [our=@p event-key=@t raw=@t kind=?(%save %ref)]
  ^-  (list card)
  =/  who=@p  (event-creator our raw)
  ?:  =(who our)  ~
  ~[[%pass /calendar-follow/(scot %p who) %agent [who %calendar] %poke %calendar-poke !>(`cal-poke`[%follow event-key raw kind])]]
++  unfollow-card
  |=  [our=@p event-key=@t raw=@t keep=?]
  ^-  (list card)
  ?:  keep  ~
  =/  who=@p  (event-creator our raw)
  ?:  =(who our)  ~
  ~[[%pass /calendar-unfollow/(scot %p who) %agent [who %calendar] %poke %calendar-poke !>(`cal-poke`[%unfollow event-key])]]
++  fanout-cards
  |=  [event-key=@t raw=@t folmap=(map @t (set @p))]
  ^-  (list card)
  =/  whos=(set @p)  (fall (~(get by folmap) event-key) *(set @p))
  (turn ~(tap in whos) |=(who=@p [%pass /calendar-update/(scot %p who) %agent [who %calendar] %poke %calendar-poke !>(`cal-poke`[%event-update event-key raw])]))
++  startup-sync-cards
  |=  [our=@p evmap=(map @t @t) refmap=(map @t @t)]
  ^-  (list card)
  =/  saved=(list [@t @t])  ~(tap by evmap)
  =/  refs=(list [@t @t])  ~(tap by refmap)
  =/  saved-cards=(list card)
    =+  xs=saved
    |-  ^-  (list card)
    ?~  xs  ~
    (weld (follow-card our -.i.xs +.i.xs %save) $(xs t.xs))
  =/  ref-cards=(list card)
    =+  xs=refs
    |-  ^-  (list card)
    ?~  xs  ~
    (weld (follow-card our -.i.xs +.i.xs %ref) $(xs t.xs))
  (weld saved-cards ref-cards)
--
%-  agent:dbug
=|  state-1
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  :_  this
  ~[[%pass /eyre-bind %arvo %e %connect [~ /apps/calendar] %calendar]]
++  on-save   !>(state)
++  on-load
  |=  =vase
  ^-  (quip card _this)
  =/  old=versioned-state  !<(versioned-state vase)
  =/  next=_this
    ?-    -.old
      %0
      this(events events.old, followers *(map @t (set @p)), refs *(map @t (set @ta)), ref-following *(set @t), ref-events *(map @t @t))
        %1
      this(events events.old, followers followers.old, refs refs.old, ref-following ref-following.old, ref-events ref-events.old)
    ==
  :_  next
  (weld ~[[%pass /eyre-bind %arvo %e %connect [~ /apps/calendar] %calendar]] (startup-sync-cards our.bowl events.next ref-events.next))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
      %calendar-poke
    =/  msg=cal-poke  !<(cal-poke vase)
    ?-    -.msg
        %follow
      ~&  [%calendar-follow-rcvd from=src.bowl key=event-key.msg kind=kind.msg]
      =/  old=(set @p)  (fall (~(get by followers.state) event-key.msg) *(set @p))
      =/  next=(set @p)  (~(put in old) src.bowl)
      =/  ev=(unit @t)  (~(get by events.state) event-key.msg)
      :_  this(followers (~(put by followers.state) event-key.msg next))
      ?~  ev  ~
      ~[[%pass /calendar-sync/(scot %p src.bowl) %agent [src.bowl %calendar] %poke %calendar-poke !>(`cal-poke`[%event-update event-key.msg u.ev])]]
        %unfollow
      =/  old=(set @p)  (fall (~(get by followers.state) event-key.msg) *(set @p))
      =/  next=(set @p)  (~(del in old) src.bowl)
      :_  this(followers (~(put by followers.state) event-key.msg next))
      ~
        %event-update
      ~&  [%calendar-update-rcvd from=src.bowl key=event-key.msg]
      =/  old-raw=(unit @t)  (~(get by events.state) event-key.msg)
      =/  was-saved=?  ?=(^ old-raw)
      =/  was-ref=?  (~(has in ref-following.state) event-key.msg)
      =/  blob=tape  (trip raw.msg)
      =/  cancelled=?  (json-true-field 'cancelled' blob)
      =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
      =/  changed=?
        ?~  old-raw  %.n
        ?.  =(u.old-raw raw.msg)  %.y
        %.n
      =/  cards=(list card)  (local-artifact-cards our.bowl event-key.msg raw.msg refs.state)
      =?  cards  changed
        (weld cards ~[?:(cancelled (event-cancelled-card our.bowl raw.msg) (event-changed-card our.bowl raw.msg))])
      =?  cards  &(was-saved cancelled)
        (weld cards ~[(clear-notification-card our.bowl id)])
      =?  cards  was-saved
        ?:  cancelled
          cards
        (weld cards (reminder-card our.bowl now.bowl raw.msg))
      :_  ?:  was-saved
            ?:  cancelled
              this(events (~(del by events.state) event-key.msg), ref-events ?:(was-ref (~(put by ref-events.state) event-key.msg raw.msg) ref-events.state))
            this(events (~(put by events.state) event-key.msg raw.msg))
          ?:  was-ref
            this(ref-events (~(put by ref-events.state) event-key.msg raw.msg))
          this
      cards
        %sync-request
      ~&  [%calendar-sync-rcvd from=src.bowl key=event-key.msg]
      =/  ev=(unit @t)  (~(get by events.state) event-key.msg)
      :_  this
      ?~  ev  ~
      ~[[%pass /calendar-sync/(scot %p src.bowl) %agent [src.bowl %calendar] %poke %calendar-poke !>(`cal-poke`[%event-update event-key.msg u.ev])]]
    ==
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    ?.  authenticated.inbound-request
      :_  this
      %+  give-simple-payload:app:server  eyre-id
      (login-redirect:gen:server request.inbound-request)
    =/  url-tape=tape  (trip url.request.inbound-request)
    =/  path-tape=tape
      =/  q  (find "?" url-tape)
      ?~  q  url-tape
      (scag u.q url-tape)
    ?:  =(path-tape "/apps/calendar/noltbook.json")
      =/  manifest=@t
        '{"noltbookVersion":"365K","version":"365K","title":"Calendar","summary":"A Noltbook-native calendar for private reminders and shareable event artifacts.","launch":{"href":"/apps/calendar","target":"embedded","width":680,"height":720},"artifact":{"label":"Calendar","href":"/apps/calendar/embed","width":340,"height":220},"actions":[{"id":"open","kind":"open","label":"Open Calendar","description":"Open your private Calendar month view.","href":"/apps/calendar","target":"embedded","width":680,"height":720}]}'
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html manifest)
      [(give-simple-payload:app:server eyre-id simple-payload) this]
    ?:  =(path-tape "/apps/calendar/api/ping")
      =/  pong=@t  '{"ok":true,"source":"%calendar","version":"365K"}'
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html pong)
      [(give-simple-payload:app:server eyre-id simple-payload) this]
    ?:  &(=(%'GET' method.request.inbound-request) =(path-tape "/apps/calendar/api/events"))
      =/  evs=@t  (json-list ~(val by events.state))
      =/  body=@t  (crip :(weld (trip '{"ok":true,"events":') (trip evs) "}"))
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html body)
      [(give-simple-payload:app:server eyre-id simple-payload) this]
    ?:  &(=(%'POST' method.request.inbound-request) =(path-tape "/apps/calendar/api/resolve"))
      =/  bod  body.request.inbound-request
      ?~  bod
        =/  =simple-payload:http
          :-  [400 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html '{"ok":false,"error":"missing body"}')
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  raw=@t  q.u.bod
      =/  blob=tape  (trip raw)
      =/  ship-t=@t  (fall (json-str-field 'ship' blob) (scot %p our.bowl))
      =/  id=@t  (fall (json-str-field 'eventId' blob) '')
      =/  key=@t  (crip :(weld (trip ship-t) ":" (trip id)))
      =/  ev=(unit @t)  (~(get by events.state) key)
      =/  rev=(unit @t)  (~(get by ref-events.state) key)
      =/  found=(unit @t)
        ?~  ev
          rev
        `u.ev
      ?^  found
        =/  body=@t  (crip :(weld (trip '{"ok":true,"key":"') (trip key) (trip '","event":') (trip u.found) "}"))
        =/  =simple-payload:http
          :-  [200 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html body)
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  who=@p  (slav %p ship-t)
      =/  body=@t  (crip :(weld (trip '{"ok":false,"pending":true,"key":"') (trip key) (trip '"}')))
      =/  =simple-payload:http
        :-  [202 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html body)
      =/  rsp-cards  (give-simple-payload:app:server eyre-id simple-payload)
      =/  req-cards=(list card)
        ?:  =(who our.bowl)
          ~
        ~[[%pass /calendar-resolve/(scot %p who)/[id] %agent [who %calendar] %poke %calendar-poke !>(`cal-poke`[%sync-request key])]]
      :_  this(ref-following (~(put in ref-following.state) key))
      (weld rsp-cards req-cards)
    ?:  &(=(%'GET' method.request.inbound-request) =(path-tape "/apps/calendar/api/debug"))
      =/  evs=@t  (json-list ~(val by events.state))
      =/  rfl=@t  (json-str-list ~(tap in ref-following.state))
      =/  fol-flat=@t  (json-followers-flat followers.state)
      =/  rfs-flat=@t  (json-refs-flat refs.state)
      =/  rev-flat=@t  (json-raw-flat ref-events.state)
      =/  targets=@t  (json-follow-targets our.bowl events.state ref-events.state)
      =/  dbg=tape  :(weld (trip '{"ok":true,"ship":"') (trip (scot %p our.bowl)))
      =.  dbg  :(weld dbg (trip '","version":"365K-demo-polish-1","events":') (trip evs))
      =.  dbg  :(weld dbg (trip ',"refFollowing":') (trip rfl))
      =.  dbg  :(weld dbg (trip ',"followersFlat":') (trip fol-flat))
      =.  dbg  :(weld dbg (trip ',"refsFlat":') (trip rfs-flat))
      =.  dbg  :(weld dbg (trip ',"refEventsFlat":') (trip rev-flat))
      =.  dbg  :(weld dbg (trip ',"followTargets":') (trip targets) "}")
      =/  body=@t  (crip dbg)
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html body)
      [(give-simple-payload:app:server eyre-id simple-payload) this]
    ?:  &(=(%'POST' method.request.inbound-request) =(path-tape "/apps/calendar/api/event"))
      =/  bod  body.request.inbound-request
      ?~  bod
        =/  =simple-payload:http
          :-  [400 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html '{"ok":false,"error":"missing body"}')
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  raw=@t  q.u.bod
      =/  key=@t  (event-key our.bowl raw)
      =/  res=@t  (crip :(weld (trip '{"ok":true,"key":"') (trip key) (trip '"}')))
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html res)
      =/  rsp-cards  (give-simple-payload:app:server eyre-id simple-payload)
      =/  blob=tape  (trip raw)
      =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
      =/  updated=@t  (fall (json-str-field 'updatedAt' blob) '')
      =/  id-ta=@ta  (crip (trip id))
      =/  updated-ta=@ta  (crip (trip updated))
      =/  creator=@p  (event-creator our.bowl raw)
      =/  cancelled=?  (json-true-field 'cancelled' blob)
      =/  extra=(list card)
        ?:  =(creator our.bowl)
          (weld (fanout-cards key raw followers.state) (local-artifact-cards our.bowl key raw refs.state))
        (follow-card our.bowl key raw %save)
      =/  out-cards=(list card)  (weld rsp-cards extra)
      =?  out-cards  &(=(creator our.bowl) cancelled)
        (weld out-cards ~[(clear-notification-card our.bowl id)])
      ?:  &(=(creator our.bowl) cancelled)
        [out-cards this(events (~(del by events.state) key))]
      =/  delay=(unit @t)  (json-str-field 'notifyInSec' blob)
      ?~  delay
        [out-cards this(events (~(put by events.state) key raw))]
      ?:  =(0 (met 3 u.delay))
        [out-cards this(events (~(put by events.state) key raw))]
      =/  sec=@ud  (rash u.delay dem)
      ?:  =(0 sec)
        [out-cards this(events (~(put by events.state) key raw))]
      =/  deadline=@da  (add now.bowl (mul sec ~s1))
      =/  wait
        ^-  card:agent:gall
        [%pass /reminder/[id-ta]/[updated-ta] %arvo %b %wait deadline]
      [(weld out-cards ~[wait]) this(events (~(put by events.state) key raw))]
    ?:  &(=(%'POST' method.request.inbound-request) =(path-tape "/apps/calendar/api/remove"))
      =/  bod  body.request.inbound-request
      ?~  bod
        =/  =simple-payload:http
          :-  [400 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html '{"ok":false,"error":"missing body"}')
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  raw=@t  q.u.bod
      =/  key=@t  (event-key our.bowl raw)
      =/  id=@t  (fall (json-str-field 'id' (trip raw)) 'missing')
      =/  res=@t  (crip :(weld (trip '{"ok":true,"key":"') (trip key) (trip '"}')))
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html res)
      =/  rsp-cards  (give-simple-payload:app:server eyre-id simple-payload)
      =/  clr  (clear-notification-card our.bowl id)
      =/  keep-ref=?  (~(has in ref-following.state) key)
      =/  unf=(list card)  (unfollow-card our.bowl key raw keep-ref)
      :_  this(events (~(del by events.state) key))
      :(weld rsp-cards ~[clr] unf)
    ?:  &(=(%'POST' method.request.inbound-request) =(path-tape "/apps/calendar/api/reference"))
      =/  bod  body.request.inbound-request
      ?~  bod
        =/  =simple-payload:http
          :-  [400 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html '{"ok":false,"error":"missing body"}')
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  raw=@t  q.u.bod
      =/  key=@t  (event-key our.bowl raw)
      =/  res=@t  (crip :(weld (trip '{"ok":true,"key":"') (trip key) (trip '"}')))
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html res)
      =/  rsp-cards  (give-simple-payload:app:server eyre-id simple-payload)
      :_  this(ref-following (~(put in ref-following.state) key), ref-events (~(put by ref-events.state) key raw))
      (weld rsp-cards (follow-card our.bowl key raw %ref))
    ?:  &(=(%'POST' method.request.inbound-request) =(path-tape "/apps/calendar/api/artifact-ref"))
      =/  bod  body.request.inbound-request
      ?~  bod
        =/  =simple-payload:http
          :-  [400 ~[['content-type' 'application/json']]]
          `(as-octs:mimes:html '{"ok":false,"error":"missing body"}')
        [(give-simple-payload:app:server eyre-id simple-payload) this]
      =/  raw=@t  q.u.bod
      =/  key=@t  (event-key our.bowl raw)
      =/  art=@ta  (crip (trip (fall (json-str-field 'artifactId' (trip raw)) '')))
      =/  old=(set @ta)  (fall (~(get by refs.state) key) *(set @ta))
      =/  next=(set @ta)  (~(put in old) art)
      =/  res=@t  (crip :(weld (trip '{"ok":true,"key":"') (trip key) (trip '","artifactId":"') (trip art) (trip '"}')))
      =/  =simple-payload:http
        :-  [200 ~[['content-type' 'application/json']]]
        `(as-octs:mimes:html res)
      =/  rsp-cards  (give-simple-payload:app:server eyre-id simple-payload)
      :_  this(refs (~(put by refs.state) key next), ref-following (~(put in ref-following.state) key), ref-events (~(put by ref-events.state) key raw))
      (weld rsp-cards (follow-card our.bowl key raw %ref))
    =/  page=@t
      '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Calendar</title><style>:root{--face:#c0c0c0;--light:#fff;--shadow:#808080;--dark:#000;--blue:#000080;--blue2:#1084d0;--text:#000;--green:#008000}*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#008080;color:var(--text);font-family:"MS Sans Serif",Tahoma,Arial,sans-serif;font-size:12px}.desktop{height:100%;padding:6px;overflow:hidden}.window{height:100%;display:flex;flex-direction:column;background:var(--face);border-top:2px solid var(--light);border-left:2px solid var(--light);border-right:2px solid var(--dark);border-bottom:2px solid var(--dark);box-shadow:1px 1px 0 var(--shadow);max-width:660px;margin:0 auto}.titlebar{height:22px;background:linear-gradient(90deg,var(--blue),var(--blue2));color:#fff;display:flex;align-items:center;gap:6px;padding:2px 4px;font-weight:bold}.titlebar .icon{width:16px;height:16px;background:#ff0;border:1px solid #000;display:inline-block}.titlebar .spacer{flex:1}.winbtn{width:18px;height:16px;background:var(--face);border-top:1px solid var(--light);border-left:1px solid var(--light);border-right:1px solid var(--dark);border-bottom:1px solid var(--dark);color:#000;display:flex;align-items:center;justify-content:center;font-size:11px}.menubar{height:20px;display:flex;align-items:center;gap:18px;padding:0 8px;border-bottom:1px solid var(--shadow)}.content{padding:6px;min-height:0;flex:1;overflow:hidden}.toolbar{display:flex;gap:5px;align-items:center;margin-bottom:5px;flex-wrap:wrap}.title{font-size:15px;font-weight:bold;margin-right:auto}.btn,button{background:var(--face);color:#000;border-top:2px solid var(--light);border-left:2px solid var(--light);border-right:2px solid var(--dark);border-bottom:2px solid var(--dark);padding:3px 8px;font:inherit;cursor:pointer;min-height:22px}.btn:active,button:active{border-top:2px solid var(--dark);border-left:2px solid var(--dark);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:5px 9px 3px 11px}.primary{font-weight:bold}.panel{background:var(--face);border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:6px}.grid{display:grid;grid-template-columns:repeat(7,1fr);gap:2px;background:var(--shadow);border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:2px}.dow{background:#000080;color:#fff;text-align:center;font-weight:bold;padding:3px}.day{min-height:74px;background:#fff;padding:3px;overflow:hidden}.day.today{outline:2px dotted #000;outline-offset:-4px}.day.muted{background:#e8e8e8;color:#808080}.date{font-weight:bold;margin-bottom:2px}.pill{display:block;width:100%;background:#ffffcc;border:1px solid #808000;text-align:left;margin:1px 0;padding:1px 2px;font-size:10px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.field{display:grid;grid-template-columns:96px 1fr;gap:5px;align-items:center;margin-bottom:5px}label{text-align:right}input,textarea,select{font:inherit;background:#fff;color:#000;border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:3px}textarea{min-height:48px;max-height:64px}.statusbar{display:flex;gap:6px;border-top:1px solid var(--shadow);padding:3px 6px;flex-shrink:0}.statuscell{border-top:1px solid var(--shadow);border-left:1px solid var(--shadow);border-right:1px solid var(--light);border-bottom:1px solid var(--light);padding:1px 5px;min-height:16px;flex:1}.big{font-size:18px;font-weight:bold;color:#000080;margin:4px 0}.meta{line-height:1.45}.row{display:flex;gap:6px;align-items:center;margin:4px 0}.grow{flex:1}.artifact-title{font-size:15px;font-weight:bold;color:#000080}body.tool-mode .desktop{display:flex;align-items:center;justify-content:center}body.artifact-mode .desktop{display:flex;align-items:center;justify-content:center;padding:4px}body.artifact-mode .window{height:auto;max-width:360px;margin:0}body.artifact-mode .menubar,body.artifact-mode .statusbar{display:none}body.artifact-mode .content{padding:4px}body.artifact-mode .panel{padding:5px}body.artifact-mode .big{font-size:16px;margin:2px 0}body.tool-mode .window{height:auto;max-width:340px;margin:0}body.tool-mode .menubar,body.tool-mode .statusbar{display:none}.tool-compact{max-width:300px;margin:0 auto}.tool-compact p{margin:6px 0 10px}.tool-compact .toolbar{margin-bottom:0}@media(max-width:720px){.desktop{padding:4px}.grid{font-size:11px}.day{min-height:68px}.field{grid-template-columns:1fr}label{text-align:left}}</style></head><body><div class="desktop"><div class="window"><div class="titlebar"><span class="icon"></span><span id="caption">Calendar</span><span class="spacer"></span><span class="winbtn">_</span><span class="winbtn">□</span><span class="winbtn" id="closeWin">×</span></div><div class="menubar"><span>File</span><span>Edit</span><span>View</span><span>Help</span></div><main class="content" id="root"></main><div class="statusbar"><div class="statuscell" id="mode">Ready</div><div class="statuscell">Windows 95 Plugin Mode</div></div></div></div><script>var P=1,S="calendar-365k-events-v1",REQ={},COPY_STATUS=null,PUBLISH_EVENT=null,TRACKED={},LIST_RESOLVE=null,UPDATE_STATUS=null,UPDATE_CLOSE=false,MEM=[],session=null,context=null,hostShip=null,shown=new Date(),lastView=null,backView=null,root=document.getElementById("root"),mode=document.getElementById("mode"),caption=document.getElementById("caption");function E(t,c){var e=document.createElement(t);if(c)e.className=c;return e}function T(s){return document.createTextNode(s||"")}function pad(n){return String(n).padStart(2,"0")}function ymd(d){return d.getFullYear()+"-"+pad(d.getMonth()+1)+"-"+pad(d.getDate())}function send(t,p){parent.postMessage({source:"noltbook-plugin",protocol:P,session:session,type:t,payload:p||{}},"*")}function openCalendar(ctx){send("nb:open-app",{desk:"calendar",href:"/apps/calendar",title:"Calendar",width:680,height:720,context:ctx||{}})}function editEvent(ev){openCalendar({view:"edit",event:ev})}function apiFetch(method,path,body){if(parent===window)return fetch(path,{method:method,headers:body?{"Content-Type":"application/json"}:{},body:body?JSON.stringify(body):undefined});var id="req-"+Date.now().toString(36)+"-"+Math.random().toString(36).slice(2);return new Promise(function(resolve){var timer=setTimeout(function(){delete REQ[id];resolve({ok:false,status:0,json:async function(){return{}},text:async function(){return""}})},15000);REQ[id]=function(res){clearTimeout(timer);delete REQ[id];resolve({ok:!!res.ok,status:res.status||0,json:async function(){try{return JSON.parse(res.body||"{}")}catch(e){return{}}},text:async function(){return res.body||""}})};send("nb:request",{requestId:id,method:method,path:path,body:body})})}function resize(kind){setTimeout(function(){if(parent!==window){var p;if(kind==="tool")p={width:340,height:220};else if(kind==="artifact"){var w=document.querySelector(".window"),h=w?w.offsetHeight+12:220;p={width:360,height:Math.max(180,Math.min(360,h))}}else p={width:680,height:720};send("nb:resize",p)}},0)}function load(){return MEM||[]}async function sync(){try{var r=await apiFetch("GET","/apps/calendar/api/events");var j=await r.json();MEM=Array.isArray(j.events)?j.events:[]}catch(e){MEM=MEM||[]}return MEM}async function persist(ev){try{var r=await apiFetch("POST","/apps/calendar/api/event",ev);return r.ok}catch(e){return false}}async function forget(ev){try{var r=await apiFetch("POST","/apps/calendar/api/remove",ev);return r.ok}catch(e){return false}}function save(x){MEM=x}function eid(){return "ev-"+Date.now().toString(36)+"-"+Math.random().toString(36).slice(2,8)}function key(e){return (e.creator||"local")+":"+e.id}function saved(ev){return load().some(function(x){return key(x)===key(ev)})}function mine(ev){return !!ev&&(ev.creator&&hostShip&&ev.creator===hostShip)}async function upsert(ev){var xs=load(),i=xs.findIndex(function(x){return key(x)===key(ev)});ev.saved=true;if(i>=0)xs[i]=Object.assign(xs[i],ev);else xs.push(ev);save(xs);return await persist(ev)}async function remove(ev){save(load().filter(function(x){return key(x)!==key(ev)}));return await forget(ev)}async function cancelOwned(ev){var ok=await persist(ev);if(ok)save(load().filter(function(x){return key(x)!==key(ev)}));return ok}function fmtDate(e){return new Date((e.date||ymd(new Date()))+"T"+(e.time||"00:00")).toLocaleDateString([],{weekday:"short",month:"short",day:"numeric",year:"numeric"})}function time12(v){if(!v)return"";var a=v.split(":").map(Number),h=a[0]||0,m=a[1]||0,ap=h>=12?"PM":"AM",hh=h%12||12;return hh+":"+pad(m)+" "+ap}function fmtTime(e){return e.time?time12(e.time)+(e.endTime?"-"+time12(e.endTime):""):"All day"}function rem(v){return {"none":"None","1m":"1 minute before","1h":"1 hour before","1d":"1 day before","1w":"1 week before"}[v||"1h"]||v}function eventRef(e){return{kind:"calendar-event",ship:e.creator||hostShip||"local",eventId:e.id}}function eventData(e){return{kind:"calendar-event",event:e,previewTitle:e.title||"Calendar Event",previewDate:e.date||"",previewTime:e.time||"",updatedAt:e.updatedAt||Date.now()}}function ref(e){return JSON.stringify({noltbookApp:1,name:e.title||"Calendar Event",app:{desk:"calendar",publisher:null},ref:eventRef(e),data:eventData(e)},null,2)}async function resolveEvent(r,fallback){if(!r||r.kind!=="calendar-event")return fallback;var k=(r.ship||"")+":"+(r.eventId||""),local=load().find(function(x){return key(x)===k});if(local)return local;try{var res=await apiFetch("POST","/apps/calendar/api/resolve",{ship:r.ship,eventId:r.eventId});var j=await res.json();if(j&&j.event)return j.event}catch(e){}return fallback}function previewEvent(r,d){d=d||{};if(d.event)return Object.assign({},d.event,{id:d.event.id||r.eventId,creator:d.event.creator||r.ship});return{id:r&&r.eventId||eid(),creator:r&&r.ship||"local",kind:"calendar-event",title:d.previewTitle||"Calendar Event",date:d.previewDate||ymd(new Date()),time:d.previewTime||"",endTime:"",location:"",notes:"",reminder:"none",notifyInSec:"",createdAt:Date.now(),cancelled:false,updatedAt:d.updatedAt||Date.now()}}function descriptorPayload(ev){return{ref:eventRef(ev),data:eventData(ev)}}function registerReference(e){if(!e||!e.id)return;apiFetch("POST","/apps/calendar/api/reference",e)}function registerArtifact(e,id){if(!e||!e.id||!id)return;var k=(e.creator||"local")+":"+e.id+":"+id;if(TRACKED[k])return;TRACKED[k]=true;var b=Object.assign({},e,{artifactId:id});apiFetch("POST","/apps/calendar/api/artifact-ref",b)}function copyRef(e,st){registerReference(e);COPY_STATUS=st;st.textContent="Copying";send("nb:copy-text",{text:ref(e)})}function viewMode(tool,artifact){document.body.classList.toggle("tool-mode",!!tool);document.body.classList.toggle("artifact-mode",!!artifact)}function clear(){root.innerHTML=""}function btn(label,cls,fn){var b=E("button",cls||"");b.appendChild(T(label));b.onclick=fn;return b}function field(label,type,value){var f=E("div","field"),l=E("label"),i=type==="notes"?E("textarea"):E(type==="select"?"select":"input");l.appendChild(T(label));if(type==="date"||type==="time")i.type=type;if(type==="select"){["none","1m","1h","1d","1w"].forEach(function(v){var o=E("option");o.value=v;o.appendChild(T(rem(v)));i.appendChild(o)})}i.value=value||"";f.appendChild(l);f.appendChild(i);return [f,i]}function notifyInSec(date,time,r){if(!r||r==="none")return "";var off={"1m":60000,"1h":3600000,"1d":86400000,"1w":604800000}[r]||0,ts=new Date((date||ymd(new Date()))+"T"+(time||"00:00")).getTime();if(!Number.isFinite(ts))return "";var d=Math.floor((ts-off-Date.now())/1000);return d>0?String(d):""}function eventFrom(seed,ins){var date=ins.date.value||ymd(new Date()),time=ins.time.value,rem=ins.rem.value||"1h";return {id:seed.id||eid(),creator:seed.creator||hostShip||"local",kind:"calendar-event",title:ins.title.value||"Untitled Event",date:date,time:time,endTime:ins.end.value,location:ins.loc.value,notes:ins.notes.value,reminder:rem,notifyInSec:notifyInSec(date,time,rem),sourceNoteId:context&&context.noteId||seed.sourceNoteId||null,createdAt:seed.createdAt||Date.now(),cancelled:!!seed.cancelled,updatedAt:Date.now()}}function form(seed,pub,artifactEdit){viewMode(false);seed=seed||{};clear();mode.textContent=pub?"Create note event":"Create private event";caption.textContent=pub?"Calendar - New Note Event":"Calendar - Event Editor";var p=E("div","panel"),h=E("div","artifact-title");h.appendChild(T(pub?"New Note Event":"Event Properties"));p.appendChild(h);var a=field("Title","text",seed.title),d=field("Date","date",seed.date||ymd(new Date())),ti=field("Start time","time",seed.time),en=field("End time","time",seed.endTime),re=field("Reminder","select",seed.reminder||"1h"),lo=field("Location","text",seed.location),no=field("Notes","notes",seed.notes);[a,d,ti,en,re,lo,no].forEach(function(x){p.appendChild(x[0])});var st=E("span","status"),bar=E("div","toolbar");bar.appendChild(btn(pub?"Publish":"Save","primary",async function(){var ev=eventFrom(seed,{title:a[1],date:d[1],time:ti[1],end:en[1],rem:re[1],loc:lo[1],notes:no[1]});st.textContent="Saving";var ok=await upsert(ev);if(!ok){st.textContent="Save failed";return}if(pub){st.textContent="Publishing event artifact";PUBLISH_EVENT=ev;send("nb:publish",Object.assign({name:ev.title},descriptorPayload(ev)))}else if(artifactEdit==="source"){st.textContent="Updating chat artifact";UPDATE_STATUS=st;UPDATE_CLOSE=true;send("nb:update-source-artifact",descriptorPayload(ev))}else if(artifactEdit){st.textContent="Updating artifact";send("nb:update-artifact",descriptorPayload(ev));renderEvent(ev)}else renderFull()}));if(seed.id){bar.appendChild(btn(mine(seed)?"Cancel Event":"Remove from Calendar","",async function(){if(mine(seed)){st.textContent="Cancelling";var ev=Object.assign({},seed,{cancelled:true,notifyInSec:"",updatedAt:Date.now()});var ok=await cancelOwned(ev);if(!ok){st.textContent="Cancel failed";return}if(artifactEdit==="source"){st.textContent="Updating chat artifact";UPDATE_STATUS=st;UPDATE_CLOSE=true;send("nb:update-source-artifact",descriptorPayload(ev))}else renderFull()}else{st.textContent="Removing";var ok=await remove(seed);st.textContent=ok?"Removed":"Remove failed";if(ok)renderFull()}}))}bar.appendChild(btn("Back","",function(){if(lastView)lastView();else renderFull()}));bar.appendChild(st);p.appendChild(bar);root.appendChild(p);resize("full")}function detail(ev){viewMode(false);clear();mode.textContent="Event selected";caption.textContent="Calendar - "+ev.title;var p=E("div","panel"),h=E("div","artifact-title"),m=E("div","meta"),b=E("div","big"),n=E("div","meta"),bar=E("div","toolbar"),st=E("span","status");h.appendChild(T((ev.cancelled?"CANCELLED - ":"")+(ev.title||"Calendar event")));m.appendChild(T(fmtDate(ev)));b.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.location?"Location: "+ev.location+"  ":"")+"Reminder: "+rem(ev.reminder)+(ev.notes?"  Notes: "+ev.notes:"")));if(mine(ev)){bar.appendChild(btn("Edit","primary",function(){lastView=function(){detail(ev)};form(ev,false)}));bar.appendChild(btn("Cancel Event","",async function(){var x=Object.assign({},ev,{cancelled:true,notifyInSec:"",updatedAt:Date.now()});var ok=await cancelOwned(x);if(ok)renderFull()}))}else{bar.appendChild(btn("Remove from Calendar","",async function(){await remove(ev);renderFull()}))}bar.appendChild(btn("Copy Event Reference","",function(){copyRef(ev,st)}));bar.appendChild(btn("Back","",renderFull));bar.appendChild(st);[h,m,b,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize("full")}function renderFull(){viewMode(false);mode.textContent="Main calendar";caption.textContent="Calendar";clear();var y=shown.getFullYear(),m=shown.getMonth(),first=new Date(y,m,1),start=new Date(first),today=ymd(new Date()),events=load();start.setDate(1-first.getDay());var bar=E("div","toolbar"),title=E("div","title"),grid=E("div","grid");title.appendChild(T(shown.toLocaleString([],{month:"long",year:"numeric"})));bar.appendChild(title);bar.appendChild(btn("< Prev","",function(){shown.setMonth(m-1);renderFull()}));bar.appendChild(btn("Today","",function(){shown=new Date();renderFull()}));bar.appendChild(btn("Next >","",function(){shown.setMonth(m+1);renderFull()}));bar.appendChild(btn("New Event","primary",function(){lastView=renderFull;form({date:today},false)}));if(backView)bar.appendChild(btn("Back","",function(){var f=backView;backView=null;f()}));root.appendChild(bar);["Sun","Mon","Tue","Wed","Thu","Fri","Sat"].forEach(function(x){var e=E("div","dow");e.appendChild(T(x));grid.appendChild(e)});for(var i=0;i<42;i++){var d=new Date(start);d.setDate(start.getDate()+i);var date=ymd(d),cell=E("div","day"+(date===today?" today":"")+(d.getMonth()!==m?" muted":""));var da=E("div","date");da.appendChild(T(String(d.getDate())));cell.appendChild(da);cell.onclick=function(dd){return function(){lastView=renderFull;form({date:dd},false)}}(date);events.filter(function(e){return e.date===date}).sort(function(a,b){return (a.time||"").localeCompare(b.time||"")}).slice(0,4).forEach(function(ev){var p=btn((ev.time?time12(ev.time)+" ":"")+ev.title,"pill",function(x){return function(ev2){if(ev2&&ev2.stopPropagation)ev2.stopPropagation();detail(x)}}(ev));cell.appendChild(p)});grid.appendChild(cell)}root.appendChild(grid);resize("full")}function listNoteArtifacts(kind,limit){return new Promise(function(resolve){if(parent===window){resolve([]);return}var done=false,timer=setTimeout(function(){if(done)return;done=true;LIST_RESOLVE=null;resolve([])},12000);LIST_RESOLVE=function(payload){if(done)return;done=true;clearTimeout(timer);LIST_RESOLVE=null;resolve(payload&&payload.ok&&Array.isArray(payload.artifacts)?payload.artifacts:[])};send("nb:list-note-artifacts",{kind:kind,limit:limit||50})})}async function noteEvents(){try{var arts=await listNoteArtifacts("calendar-event",100),out=[];arts.forEach(function(a){var x=a&&a.data,r=a&&a.ref;if(x&&x.kind==="calendar-event"&&x.event)out.push(x.event);else if(r&&r.kind==="calendar-event")out.push(previewEvent(r,x))});var t=ymd(new Date());return out.filter(function(e){return e.date>=t})}catch(e){return[]}}function renderTool(){viewMode(true);mode.textContent="Note tool";caption.textContent="Calendar - Noltbook Tool";clear();var p=E("div","panel tool-compact"),h=E("div","artifact-title"),m=E("p","meta"),bar=E("div","toolbar"),st=E("span","status");h.appendChild(T("Calendar Tool"));m.appendChild(T("Create a shareable event for this note, or post upcoming Calendar artifacts found here."));bar.appendChild(btn("Create Event","primary",function(){lastView=renderTool;form({date:ymd(new Date())},true)}));bar.appendChild(btn("Post Upcoming","",async function(){st.textContent="Scanning";var evs=await noteEvents();if(!evs.length){st.textContent="No upcoming events";return}send("nb:publish",{name:"Upcoming Calendar Events",data:{kind:"calendar-event-list",events:evs.slice(0,20),sourceNoteId:context&&context.noteId,createdAt:Date.now()}})}));bar.appendChild(btn("Open Calendar","",function(){backView=renderTool;renderFull()}));bar.appendChild(btn("Close","",function(){send("nb:close")}));bar.appendChild(st);[h,m,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize("tool")}function renderEvent(ev){viewMode(false,true);mode.textContent="Artifact event";caption.textContent="Calendar Event";clear();var p=E("div","panel"),h=E("div","artifact-title"),d=E("div","meta"),t=E("div","big"),n=E("div","meta"),bar=E("div","toolbar"),st=E("span","status"),isSaved=saved(ev),isMine=mine(ev);h.appendChild(T((ev.cancelled?"CANCELLED - ":"")+(ev.title||"Calendar event")));d.appendChild(T(fmtDate(ev)));t.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.cancelled?"Status: cancelled  ":"")+(ev.location?"Location: "+ev.location+"  ":"")+"Reminder: "+rem(ev.reminder)+(isMine?"  Creator: you":"")));if(isMine){bar.appendChild(btn("Edit Event","primary",function(){editEvent(ev)}))}else if(isSaved){bar.appendChild(btn("Remove from Calendar","",async function(){st.textContent="Removing";var ok=await remove(ev);st.textContent=ok?"Removed":"Remove failed";renderEvent(ev)}))}else{bar.appendChild(btn("Add to Calendar","primary",async function(){st.textContent="Adding";var ok=await upsert(ev);st.textContent=ok?"Added":"Add failed";renderEvent(ev)}))}bar.appendChild(btn("Open Calendar","",function(){openCalendar({view:"calendar"})}));bar.appendChild(btn("Copy Event Reference","",function(){copyRef(ev,st)}));bar.appendChild(st);[h,d,t,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize("artifact")}function renderList(evs){viewMode(false,true);mode.textContent="Artifact list";caption.textContent="Calendar - Upcoming Events";clear();var p=E("div","panel"),h=E("div","artifact-title");h.appendChild(T("Upcoming Events"));p.appendChild(h);(evs||[]).filter(function(e){return e.date>=ymd(new Date())}).forEach(function(ev){var row=E("div","row"),main=E("div","grow"),meta=E("div","meta");main.appendChild(T(ev.title));meta.appendChild(T(fmtDate(ev)+" - "+fmtTime(ev)));main.appendChild(meta);row.appendChild(main);row.appendChild(btn(saved(ev)?"Remove":"Add","",async function(){if(saved(ev))await remove(ev);else await upsert(ev);renderList(evs)}));p.appendChild(row)});root.appendChild(p);resize("artifact")}async function renderRefEvent(r,d){var fb=previewEvent(r,d);registerReference(fb);renderEvent(fb);var ev=await resolveEvent(r,fb);if(ev&&JSON.stringify(ev)!==JSON.stringify(fb))renderEvent(ev);[1500,5000,12000].forEach(function(ms){setTimeout(async function(){var base=ev||fb,later=await resolveEvent(r,base);if(later&&JSON.stringify(later)!==JSON.stringify(base)){ev=later;renderEvent(later)}},ms)})}function renderArtifact(){var art=context&&context.artifact||{},d=art.data||{},r=art.ref||null;if(r&&r.kind==="calendar-event"){renderRefEvent(r,d)}else if(d.kind==="calendar-event"){if(context&&context.artifact&&context.artifact.creator===hostShip)registerArtifact(d.event||{},context.artifact.id);renderEvent(d.event||{})}else if(d.kind==="calendar-event-list")renderList(d.events||[]);else{clear();root.appendChild(T("Unknown Calendar artifact."))}}window.addEventListener("message",function(e){if(e.source!==parent)return;var d=e.data;if(!d||d.source!=="noltbook-host"||d.protocol!==P)return;if(d.type==="nb:init"){session=d.session;context=d.payload;hostShip=context.hostShip||null;sync().then(function(){var cx=context&&context.context||{};if(context.mode==="private-tool")renderTool();else if(context.mode==="embedded-app"&&cx.view==="edit"&&cx.event){lastView=renderFull;form(cx.event,false,context.sourceArtifact?"source":false)}else if(context.mode==="embedded-app")renderFull();else renderArtifact()})}else if(d.session!==session)return;else if(d.type==="nb:response"){var cb=REQ[d.payload&&d.payload.requestId];if(cb)cb(d.payload||{});return}else if(d.type==="nb:list-note-artifacts-result"){if(LIST_RESOLVE)LIST_RESOLVE(d.payload||{});return}else if(d.type==="nb:update-source-artifact-result"){var ok=d.payload&&d.payload.ok;if(UPDATE_STATUS)UPDATE_STATUS.textContent=ok?"Saved":"Artifact update failed";if(ok&&UPDATE_CLOSE)setTimeout(function(){send("nb:close")},150);UPDATE_CLOSE=false;return}else if(d.type==="nb:copy-text-result"){if(COPY_STATUS)COPY_STATUS.textContent=d.payload&&d.payload.ok?"Copied":"Copy failed";return}else if(d.type==="nb:open-app-result"){return}else if(d.type==="nb:publish-result"){if(d.payload&&d.payload.ok){var r=d.payload.result||{};if(PUBLISH_EVENT&&r.artifactId)registerArtifact(PUBLISH_EVENT,r.artifactId);PUBLISH_EVENT=null;send("nb:close")}else{PUBLISH_EVENT=null;clear();var p=E("div","panel");p.appendChild(T("Publish failed"));root.appendChild(p)}}});var cw=document.getElementById("closeWin");if(cw)cw.onclick=function(){send("nb:close")};if(window.parent===window)sync().then(renderFull);else parent.postMessage({source:"noltbook-plugin",protocol:P,type:"nb:ready"},"*");</script></body></html>'
    =/  html-bytes=octs  (as-octs:mimes:html page)
    =/  =simple-payload:http
      :-  [200 ~[['content-type' 'text/html; charset=utf-8']]]
      `html-bytes
    [(give-simple-payload:app:server eyre-id simple-payload) this]
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=([%reminder @ @ ~] wire)
    ?.  ?=([%behn %wake *] sign-arvo)  `this
    =/  id=@t  i.t.wire
    =/  updated=@t  i.t.t.wire
    =/  ev=(unit @t)  (event-by-id id ~(val by events.state))
    ?~  ev  `this
    =/  blob=tape  (trip u.ev)
    ?:  (json-true-field 'cancelled' blob)  `this
    =/  delay=(unit @t)  (json-str-field 'notifyInSec' blob)
    ?~  delay  `this
    ?:  =(0 (met 3 u.delay))  `this
    =/  cur=@t  (fall (json-str-field 'updatedAt' blob) '')
    ?.  =(cur updated)  `this
    :_  this
    ~[(set-notification-card our.bowl u.ev)]
  ?+  wire  (on-arvo:def wire sign-arvo)
      [%eyre-bind ~]
    `this
  ==
++  on-peek   on-peek:def
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
      [%http-response @ ~]
    `this
  ==
++  on-leave  on-leave:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?:  ?=(%poke-ack -.sign)
    ?~  p.sign
      ~&  [%calendar-poke-ok wire]
      `this
    ~&  [%calendar-poke-nack wire]
    `this
  (on-agent:def wire sign)
++  on-fail   on-fail:def
--
