::  calendar -- Noltbook Calendar plugin.
/+  default-agent, dbug, server
|%
+$  versioned-state  [%0 events=(map @t @t)]
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
++  event-key
  |=  [our=@p raw=@t]
  ^-  @t
  =/  blob=tape  (trip raw)
  =/  id=@t  (fall (json-str-field 'id' blob) 'missing')
  =/  creator=@t  (fall (json-str-field 'creator' blob) (scot %p our))
  (crip :(weld (trip creator) ":" (trip id)))
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
++  json-list
  |=  items=(list @t)
  ^-  @t
  =/  body=tape
    |-  ^-  tape
    ?~  items  ~
    ?~  t.items  (trip i.items)
    :(weld (trip i.items) "," $(items t.items))
  (crip :(weld "[" body "]"))
--
%-  agent:dbug
=|  versioned-state
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
  :_  this
  ~[[%pass /eyre-bind %arvo %e %connect [~ /apps/calendar] %calendar]]
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
        '{"noltbookVersion":"365K","version":"365K","title":"Calendar","summary":"A Noltbook-native calendar for private reminders and shareable event artifacts.","launch":{"href":"/apps/calendar","target":"embedded","width":680,"height":720},"artifact":{"label":"Calendar","href":"/apps/calendar/embed","width":680,"height":720},"actions":[{"id":"open","kind":"open","label":"Open Calendar","description":"Open your private Calendar month view.","href":"/apps/calendar","target":"embedded","width":680,"height":720}]}'
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
      :_  this(events (~(put by events.state) key raw))
      =/  delay=(unit @t)  (json-str-field 'notifyInSec' blob)
      ?~  delay  rsp-cards
      ?:  =(0 (met 3 u.delay))  rsp-cards
      =/  sec=@ud  (rash u.delay dem)
      ?:  =(0 sec)  rsp-cards
      =/  deadline=@da  (add now.bowl (mul sec ~s1))
      =/  wait
        ^-  card:agent:gall
        [%pass /reminder/[id-ta]/[updated-ta] %arvo %b %wait deadline]
      (weld rsp-cards ~[wait])
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
      :_  this(events (~(del by events.state) key))
      (weld rsp-cards ~[clr])
    =/  page=@t
      '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Calendar</title><style>:root{--face:#c0c0c0;--light:#fff;--shadow:#808080;--dark:#000;--blue:#000080;--blue2:#1084d0;--text:#000;--green:#008000}*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#008080;color:var(--text);font-family:"MS Sans Serif",Tahoma,Arial,sans-serif;font-size:12px}.desktop{height:100%;padding:6px;overflow:hidden}.window{height:100%;display:flex;flex-direction:column;background:var(--face);border-top:2px solid var(--light);border-left:2px solid var(--light);border-right:2px solid var(--dark);border-bottom:2px solid var(--dark);box-shadow:1px 1px 0 var(--shadow);max-width:660px;margin:0 auto}.titlebar{height:22px;background:linear-gradient(90deg,var(--blue),var(--blue2));color:#fff;display:flex;align-items:center;gap:6px;padding:2px 4px;font-weight:bold}.titlebar .icon{width:16px;height:16px;background:#ff0;border:1px solid #000;display:inline-block}.titlebar .spacer{flex:1}.winbtn{width:18px;height:16px;background:var(--face);border-top:1px solid var(--light);border-left:1px solid var(--light);border-right:1px solid var(--dark);border-bottom:1px solid var(--dark);color:#000;display:flex;align-items:center;justify-content:center;font-size:11px}.menubar{height:20px;display:flex;align-items:center;gap:18px;padding:0 8px;border-bottom:1px solid var(--shadow)}.content{padding:6px;min-height:0;flex:1;overflow:hidden}.toolbar{display:flex;gap:5px;align-items:center;margin-bottom:5px;flex-wrap:wrap}.title{font-size:15px;font-weight:bold;margin-right:auto}.btn,button{background:var(--face);color:#000;border-top:2px solid var(--light);border-left:2px solid var(--light);border-right:2px solid var(--dark);border-bottom:2px solid var(--dark);padding:3px 8px;font:inherit;cursor:pointer;min-height:22px}.btn:active,button:active{border-top:2px solid var(--dark);border-left:2px solid var(--dark);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:5px 9px 3px 11px}.primary{font-weight:bold}.panel{background:var(--face);border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:6px}.grid{display:grid;grid-template-columns:repeat(7,1fr);gap:2px;background:var(--shadow);border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:2px}.dow{background:#000080;color:#fff;text-align:center;font-weight:bold;padding:3px}.day{min-height:74px;background:#fff;padding:3px;overflow:hidden}.day.today{outline:2px dotted #000;outline-offset:-4px}.day.muted{background:#e8e8e8;color:#808080}.date{font-weight:bold;margin-bottom:2px}.pill{display:block;width:100%;background:#ffffcc;border:1px solid #808000;text-align:left;margin:1px 0;padding:1px 2px;font-size:10px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.field{display:grid;grid-template-columns:96px 1fr;gap:5px;align-items:center;margin-bottom:5px}label{text-align:right}input,textarea,select{font:inherit;background:#fff;color:#000;border-top:2px solid var(--shadow);border-left:2px solid var(--shadow);border-right:2px solid var(--light);border-bottom:2px solid var(--light);padding:3px}textarea{min-height:48px;max-height:64px}.statusbar{display:flex;gap:6px;border-top:1px solid var(--shadow);padding:3px 6px;flex-shrink:0}.statuscell{border-top:1px solid var(--shadow);border-left:1px solid var(--shadow);border-right:1px solid var(--light);border-bottom:1px solid var(--light);padding:1px 5px;min-height:16px;flex:1}.big{font-size:18px;font-weight:bold;color:#000080;margin:4px 0}.meta{line-height:1.45}.row{display:flex;gap:6px;align-items:center;margin:4px 0}.grow{flex:1}.artifact-title{font-size:15px;font-weight:bold;color:#000080}body.tool-mode .desktop{display:flex;align-items:center;justify-content:center}body.artifact-mode .desktop{display:flex;align-items:center;justify-content:center;padding:4px}body.artifact-mode .window{height:auto;max-width:360px;margin:0}body.artifact-mode .menubar,body.artifact-mode .statusbar{display:none}body.artifact-mode .content{padding:4px}body.artifact-mode .panel{padding:5px}body.artifact-mode .big{font-size:16px;margin:2px 0}body.tool-mode .window{height:auto;max-width:340px;margin:0}body.tool-mode .menubar,body.tool-mode .statusbar{display:none}.tool-compact{max-width:300px;margin:0 auto}.tool-compact p{margin:6px 0 10px}.tool-compact .toolbar{margin-bottom:0}@media(max-width:720px){.desktop{padding:4px}.grid{font-size:11px}.day{min-height:68px}.field{grid-template-columns:1fr}label{text-align:left}}</style></head><body><div class="desktop"><div class="window"><div class="titlebar"><span class="icon"></span><span id="caption">Calendar</span><span class="spacer"></span><span class="winbtn">_</span><span class="winbtn">□</span><span class="winbtn" id="closeWin">×</span></div><div class="menubar"><span>File</span><span>Edit</span><span>View</span><span>Help</span></div><main class="content" id="root"></main><div class="statusbar"><div class="statuscell" id="mode">Ready</div><div class="statuscell">Windows 95 Plugin Mode</div></div></div></div><script>var P=1,S="calendar-365k-events-v1",MEM=[],session=null,context=null,hostShip=null,shown=new Date(),lastView=null,backView=null,root=document.getElementById("root"),mode=document.getElementById("mode"),caption=document.getElementById("caption");function E(t,c){var e=document.createElement(t);if(c)e.className=c;return e}function T(s){return document.createTextNode(s||"")}function pad(n){return String(n).padStart(2,"0")}function ymd(d){return d.getFullYear()+"-"+pad(d.getMonth()+1)+"-"+pad(d.getDate())}function send(t,p){parent.postMessage({source:"noltbook-plugin",protocol:P,session:session,type:t,payload:p||{}},"*")}function resize(){setTimeout(function(){if(parent!==window){var w=document.querySelector(".window"),h=document.body.classList.contains("artifact-mode")&&w?w.offsetHeight+12:document.documentElement.scrollHeight+8;var p={height:Math.max(180,Math.min(760,h))};if(document.body.classList.contains("artifact-mode"))p.width=360;send("nb:resize",p)}},0)}function load(){return MEM||[]}async function sync(){try{var r=await fetch("/apps/calendar/api/events");var j=await r.json();MEM=Array.isArray(j.events)?j.events:[]}catch(e){MEM=MEM||[]}return MEM}function persist(ev){try{fetch("/apps/calendar/api/event",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify(ev)})}catch(e){}}function forget(ev){try{fetch("/apps/calendar/api/remove",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify(ev)})}catch(e){}}function save(x){MEM=x}function eid(){return "ev-"+Date.now().toString(36)+"-"+Math.random().toString(36).slice(2,8)}function key(e){return (e.creator||"local")+":"+e.id}function saved(ev){return load().some(function(x){return key(x)===key(ev)})}function mine(ev){return !!ev&&(ev.creator&&hostShip&&ev.creator===hostShip)}function upsert(ev){var xs=load(),i=xs.findIndex(function(x){return key(x)===key(ev)});ev.saved=true;if(i>=0)xs[i]=Object.assign(xs[i],ev);else xs.push(ev);save(xs);persist(ev)}function remove(ev){save(load().filter(function(x){return key(x)!==key(ev)}));forget(ev)}function fmtDate(e){return new Date((e.date||ymd(new Date()))+"T"+(e.time||"00:00")).toLocaleDateString([],{weekday:"short",month:"short",day:"numeric",year:"numeric"})}function fmtTime(e){return e.time?e.time+(e.endTime?"-"+e.endTime:""):"All day"}function rem(v){return {"none":"None","1m":"1 minute before","1h":"1 hour before","1d":"1 day before","1w":"1 week before"}[v||"1h"]||v}function ref(e){return JSON.stringify({noltbookApp:1,name:e.title||"Calendar Event",app:{desk:"calendar",publisher:null},data:{kind:"calendar-event",event:e}},null,2)}function viewMode(tool,artifact){document.body.classList.toggle("tool-mode",!!tool);document.body.classList.toggle("artifact-mode",!!artifact)}function clear(){root.innerHTML=""}function btn(label,cls,fn){var b=E("button",cls||"");b.appendChild(T(label));b.onclick=fn;return b}function field(label,type,value){var f=E("div","field"),l=E("label"),i=type==="notes"?E("textarea"):E(type==="select"?"select":"input");l.appendChild(T(label));if(type==="date"||type==="time")i.type=type;if(type==="select"){["none","1m","1h","1d","1w"].forEach(function(v){var o=E("option");o.value=v;o.appendChild(T(rem(v)));i.appendChild(o)})}i.value=value||"";f.appendChild(l);f.appendChild(i);return [f,i]}function notifyInSec(date,time,r){if(!r||r==="none")return "";var off={"1m":60000,"1h":3600000,"1d":86400000,"1w":604800000}[r]||0,ts=new Date((date||ymd(new Date()))+"T"+(time||"00:00")).getTime();if(!Number.isFinite(ts))return "";var d=Math.floor((ts-off-Date.now())/1000);return d>0?String(d):""}function eventFrom(seed,ins){var date=ins.date.value||ymd(new Date()),time=ins.time.value,rem=ins.rem.value||"1h";return {id:seed.id||eid(),creator:seed.creator||hostShip||"local",kind:"calendar-event",title:ins.title.value||"Untitled Event",date:date,time:time,endTime:ins.end.value,location:ins.loc.value,notes:ins.notes.value,reminder:rem,notifyInSec:notifyInSec(date,time,rem),sourceNoteId:context&&context.noteId||seed.sourceNoteId||null,createdAt:seed.createdAt||Date.now(),updatedAt:Date.now()}}function form(seed,pub){viewMode(false);seed=seed||{};clear();mode.textContent=pub?"Create note event":"Create private event";caption.textContent=pub?"Calendar - New Note Event":"Calendar - Event Editor";var p=E("div","panel"),h=E("div","artifact-title");h.appendChild(T(pub?"New Note Event":"Event Properties"));p.appendChild(h);var a=field("Title","text",seed.title),d=field("Date","date",seed.date||ymd(new Date())),ti=field("Start time","time",seed.time),en=field("End time","time",seed.endTime),re=field("Reminder","select",seed.reminder||"1h"),lo=field("Location","text",seed.location),no=field("Notes","notes",seed.notes);[a,d,ti,en,re,lo,no].forEach(function(x){p.appendChild(x[0])});var st=E("span","status"),bar=E("div","toolbar");bar.appendChild(btn(pub?"Publish":"Save","primary",function(){var ev=eventFrom(seed,{title:a[1],date:d[1],time:ti[1],end:en[1],rem:re[1],loc:lo[1],notes:no[1]});upsert(ev);if(pub){st.textContent="Publishing event artifact";send("nb:publish",{name:ev.title,data:{kind:"calendar-event",event:ev}})}else renderFull()}));bar.appendChild(btn("Back","",function(){if(lastView)lastView();else renderFull()}));bar.appendChild(st);p.appendChild(bar);root.appendChild(p);resize()}function detail(ev){viewMode(false);clear();mode.textContent="Event selected";caption.textContent="Calendar - "+ev.title;var p=E("div","panel"),h=E("div","artifact-title"),m=E("div","meta"),b=E("div","big"),n=E("div","meta"),bar=E("div","toolbar"),st=E("span","status");h.appendChild(T(ev.title));m.appendChild(T(fmtDate(ev)));b.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.location?"Location: "+ev.location+"  ":"")+"Reminder: "+rem(ev.reminder)+(ev.notes?"  Notes: "+ev.notes:"")));bar.appendChild(btn("Edit","primary",function(){lastView=function(){detail(ev)};form(ev,false)}));bar.appendChild(btn("Copy Event Reference","",function(){navigator.clipboard.writeText(ref(ev));st.textContent="Copied event reference"}));bar.appendChild(btn("Remove","",function(){remove(ev);renderFull()}));bar.appendChild(btn("Back","",renderFull));bar.appendChild(st);[h,m,b,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderFull(){viewMode(false);mode.textContent="Main calendar";caption.textContent="Calendar";clear();var y=shown.getFullYear(),m=shown.getMonth(),first=new Date(y,m,1),start=new Date(first),today=ymd(new Date()),events=load();start.setDate(1-first.getDay());var bar=E("div","toolbar"),title=E("div","title"),grid=E("div","grid");title.appendChild(T(shown.toLocaleString([],{month:"long",year:"numeric"})));bar.appendChild(title);bar.appendChild(btn("< Prev","",function(){shown.setMonth(m-1);renderFull()}));bar.appendChild(btn("Today","",function(){shown=new Date();renderFull()}));bar.appendChild(btn("Next >","",function(){shown.setMonth(m+1);renderFull()}));bar.appendChild(btn("New Event","primary",function(){lastView=renderFull;form({date:today},false)}));if(backView)bar.appendChild(btn("Back","",function(){var f=backView;backView=null;f()}));root.appendChild(bar);["Sun","Mon","Tue","Wed","Thu","Fri","Sat"].forEach(function(x){var e=E("div","dow");e.appendChild(T(x));grid.appendChild(e)});for(var i=0;i<42;i++){var d=new Date(start);d.setDate(start.getDate()+i);var date=ymd(d),cell=E("div","day"+(date===today?" today":"")+(d.getMonth()!==m?" muted":""));var da=E("div","date");da.appendChild(T(String(d.getDate())));cell.appendChild(da);cell.onclick=function(dd){return function(){lastView=renderFull;form({date:dd},false)}}(date);events.filter(function(e){return e.date===date}).sort(function(a,b){return (a.time||"").localeCompare(b.time||"")}).slice(0,4).forEach(function(ev){var p=btn((ev.time?ev.time+" ":"")+ev.title,"pill",function(x){return function(ev2){if(ev2&&ev2.stopPropagation)ev2.stopPropagation();detail(x)}}(ev));cell.appendChild(p)});grid.appendChild(cell)}root.appendChild(grid);resize()}async function noteEvents(){var nid=context&&context.noteId;if(!nid)return[];try{var r=await fetch("/~/scry/noltbook/api/notes/"+encodeURIComponent(nid)+".json"),n=await r.json(),out=[];(n.artifacts||[]).forEach(function(a){var raw=a.latestVersion&&a.latestVersion.content;if(raw){try{var d=JSON.parse(raw),x=(d&&d.noltbookApp===1)?d.data:d;if(x&&x.kind==="calendar-event"&&x.event)out.push(x.event);if(x&&x.kind==="calendar-event-list"&&Array.isArray(x.events))out.push.apply(out,x.events)}catch(e){}}});var t=ymd(new Date());return out.filter(function(e){return e.date>=t})}catch(e){return[]}}function renderTool(){viewMode(true);mode.textContent="Note tool";caption.textContent="Calendar - Noltbook Tool";clear();var p=E("div","panel tool-compact"),h=E("div","artifact-title"),m=E("p","meta"),bar=E("div","toolbar"),st=E("span","status");h.appendChild(T("Calendar Tool"));m.appendChild(T("Create a shareable event for this note, or post upcoming Calendar artifacts found here."));bar.appendChild(btn("Create Event","primary",function(){lastView=renderTool;form({date:ymd(new Date())},true)}));bar.appendChild(btn("Post Upcoming","",async function(){st.textContent="Scanning";var evs=await noteEvents();if(!evs.length){st.textContent="No upcoming events";return}send("nb:publish",{name:"Upcoming Calendar Events",data:{kind:"calendar-event-list",events:evs.slice(0,20),sourceNoteId:context&&context.noteId,createdAt:Date.now()}})}));bar.appendChild(btn("Open Calendar","",function(){backView=renderTool;renderFull()}));bar.appendChild(btn("Close","",function(){send("nb:close")}));bar.appendChild(st);[h,m,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderEvent(ev){viewMode(false,true);mode.textContent="Artifact event";caption.textContent="Calendar - Event Artifact";clear();var p=E("div","panel"),h=E("div","artifact-title"),d=E("div","meta"),t=E("div","big"),n=E("div","meta"),bar=E("div","toolbar"),st=E("span","status"),isSaved=saved(ev),isMine=mine(ev);h.appendChild(T(ev.title||"Calendar event"));d.appendChild(T(fmtDate(ev)));t.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.location?"Location: "+ev.location+"  ":"")+"Reminder: "+rem(ev.reminder)+(isMine?"  Creator: you":"")));if(isMine){bar.appendChild(btn("Edit Event","primary",function(){upsert(ev);send("nb:resize",{width:680,height:720});lastView=function(){renderEvent(ev)};form(ev,false)}))}else if(isSaved){bar.appendChild(btn("Remove from Calendar","",function(){remove(ev);st.textContent="Removed";renderEvent(ev)}))}else{bar.appendChild(btn("Add to Calendar","primary",function(){upsert(ev);st.textContent="Added";renderEvent(ev)}))}bar.appendChild(btn("Copy Event Reference","",function(){navigator.clipboard.writeText(ref(ev));st.textContent="Copied"}));bar.appendChild(btn("Open Calendar","",function(){backView=function(){renderEvent(ev)};renderFull()}));bar.appendChild(st);[h,d,t,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderList(evs){viewMode(false,true);mode.textContent="Artifact list";caption.textContent="Calendar - Upcoming Events";clear();var p=E("div","panel"),h=E("div","artifact-title");h.appendChild(T("Upcoming Events"));p.appendChild(h);(evs||[]).filter(function(e){return e.date>=ymd(new Date())}).forEach(function(ev){var row=E("div","row"),main=E("div","grow"),meta=E("div","meta");main.appendChild(T(ev.title));meta.appendChild(T(fmtDate(ev)+" - "+fmtTime(ev)));main.appendChild(meta);row.appendChild(main);row.appendChild(btn(saved(ev)?"Remove":"Add","",function(){if(saved(ev))remove(ev);else upsert(ev);renderList(evs)}));p.appendChild(row)});root.appendChild(p);resize()}function renderArtifact(){var d=context&&context.artifact&&context.artifact.data||{};if(d.kind==="calendar-event")renderEvent(d.event||{});else if(d.kind==="calendar-event-list")renderList(d.events||[]);else{clear();root.appendChild(T("Unknown Calendar artifact."))}}window.addEventListener("message",function(e){if(e.source!==parent)return;var d=e.data;if(!d||d.source!=="noltbook-host"||d.protocol!==P)return;if(d.type==="nb:init"){session=d.session;context=d.payload;hostShip=context.hostShip||null;sync().then(function(){if(context.mode==="private-tool")renderTool();else if(context.mode==="embedded-app")renderFull();else renderArtifact()})}else if(d.session!==session)return;else if(d.type==="nb:publish-result"){if(d.payload&&d.payload.ok)send("nb:close");else{clear();var p=E("div","panel");p.appendChild(T("Publish failed"));root.appendChild(p)}}});var cw=document.getElementById("closeWin");if(cw)cw.onclick=function(){send("nb:close")};if(window.parent===window)sync().then(renderFull);else parent.postMessage({source:"noltbook-plugin",protocol:P,type:"nb:ready"},"*");</script></body></html>'
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
    =/  cur=@t  (fall (json-str-field 'updatedAt' (trip u.ev)) '')
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
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
