::  calendar -- Noltbook Calendar 365K plugin.
::
::  Serves the full app, embedded artifact/tool surface, and Noltbook manifest.
/+  default-agent, dbug, server
|%
+$  versioned-state  $%([%0 ~])
+$  card  card:agent:gall
--
%-  agent:dbug
=|  [%0 ~]
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
++  on-load   |=(=vase `this)
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+  mark  (on-poke:def mark vase)
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
        '{"noltbook":1,"title":"Calendar 365K","summary":"A Noltbook-native calendar for private reminders and shareable event artifacts.","launch":{"href":"/apps/calendar","target":"same-tab"},"artifact":{"label":"Calendar","href":"/apps/calendar/embed"},"actions":[{"id":"open","kind":"open","label":"Open Calendar","description":"Open your private Calendar 365K month view.","href":"/apps/calendar"}]}'
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
    =/  html-path=path
      :*  (scot %p our.bowl)
          q.byk.bowl
          (scot %da now.bowl)
          /lib/calendar/index/html
      ==
    =/  html-bytes=octs  (as-octs:mimes:html .^(@ %cx html-path))
    =/  =simple-payload:http
      :-  [200 ~[['content-type' 'text/html; charset=utf-8']]]
      `html-bytes
    [(give-simple-payload:app:server eyre-id simple-payload) this]
  ==
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
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
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
