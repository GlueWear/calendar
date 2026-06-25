::  calendar -- Noltbook Calendar 365K plugin.
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
    =/  page=@t
      '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Calendar 365K</title><style>html,body{margin:0;background:#080808;color:#dedede;font-family:monospace}header{height:50px;border-bottom:1px solid #ff8a00;display:flex;align-items:center;gap:10px;padding:0 14px}.brand{color:#ffaa00;font-weight:bold;letter-spacing:3px}.chip{color:#65d6e8;border:1px solid #8b4b08;padding:2px 6px}.mode{margin-left:auto;color:#858585;font-size:12px}main{padding:14px;max-width:920px;margin:auto}.bar{display:flex;gap:8px;align-items:center;margin-bottom:12px;flex-wrap:wrap}.title{color:#ffaa00;font-size:20px;margin-right:auto}button{background:#171008;color:#dedede;border:1px solid #8b4b08;padding:8px 10px;font:inherit;cursor:pointer}button.primary{background:#ffaa00;color:#050505;border-color:#ffaa00;font-weight:bold}.grid{display:grid;grid-template-columns:repeat(7,1fr);gap:5px}.dow{color:#858585;font-size:12px}.day{min-height:85px;border:1px solid #34220b;background:#111;padding:6px}.today{border-color:#65d6e8}.muted{opacity:.45}.date{color:#ffaa00;font-size:12px}.pill{display:block;width:100%;font-size:12px;text-align:left;margin-top:4px;padding:4px;border:1px solid #8b4b08;background:#1b1208;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.panel{border:1px solid #8b4b08;background:#101010;padding:14px}.meta{color:#858585;font-size:12px;line-height:1.5}.big{color:#65d6e8;font-size:22px}.field{display:flex;flex-direction:column;gap:4px;margin-bottom:10px}label{color:#858585;font-size:12px}input,textarea,select{background:#050505;color:#dedede;border:1px solid #3a2a10;padding:8px;font:inherit}textarea{min-height:65px}.status{color:#858585;font-size:12px}</style></head><body><header><span class="brand">CALENDAR</span><span class="chip">365K</span><span id="mode" class="mode">APP</span></header><main id="root"></main><script>var P=1,S="calendar-365k-events-v1",session=null,context=null,shown=new Date(),root=document.getElementById("root"),mode=document.getElementById("mode");function E(t,c){var e=document.createElement(t);if(c)e.className=c;return e}function T(s){return document.createTextNode(s||"")}function pad(n){return String(n).padStart(2,"0")}function ymd(d){return d.getFullYear()+"-"+pad(d.getMonth()+1)+"-"+pad(d.getDate())}function send(t,p){parent.postMessage({source:"noltbook-plugin",protocol:P,session:session,type:t,payload:p||{}},"*")}function resize(){setTimeout(function(){if(parent!==window)send("nb:resize",{height:Math.max(190,Math.min(720,document.documentElement.scrollHeight+8))})},0)}function load(){try{return JSON.parse(localStorage.getItem(S)||"[]")}catch(e){return[]}}function save(x){localStorage.setItem(S,JSON.stringify(x))}function eid(){return "ev-"+Date.now().toString(36)+"-"+Math.random().toString(36).slice(2,8)}function key(e){return (e.creator||"local")+":"+e.id}function upsert(ev){var xs=load(),i=xs.findIndex(function(x){return key(x)===key(ev)});ev.saved=true;if(i>=0)xs[i]=Object.assign(xs[i],ev);else xs.push(ev);save(xs)}function remove(ev){save(load().filter(function(x){return key(x)!==key(ev)}))}function fmtDate(e){return new Date((e.date||ymd(new Date()))+"T"+(e.time||"00:00")).toLocaleDateString([],{weekday:"short",month:"short",day:"numeric",year:"numeric"})}function fmtTime(e){return e.time?e.time+(e.endTime?"-"+e.endTime:""):"All day"}function rem(v){return {"none":"None","1h":"1 hour before","1d":"1 day before","1w":"1 week before"}[v||"1h"]||v}function ref(e){return JSON.stringify({type:"calendar-event-ref",desk:"calendar",creator:e.creator||"local",id:e.id,title:e.title,date:e.date,time:e.time},null,2)}function clear(){root.innerHTML=""}function btn(label,cls,fn){var b=E("button",cls||"");b.appendChild(T(label));b.onclick=fn;return b}function field(label,type,value){var f=E("div","field"),l=E("label"),i= type==="notes" ? E("textarea") : E(type==="select" ? "select" : "input");l.appendChild(T(label));if(type==="date"||type==="time")i.type=type;if(type==="select"){["none","1h","1d","1w"].forEach(function(v){var o=E("option");o.value=v;o.appendChild(T(rem(v)));i.appendChild(o)})}i.value=value||"";f.appendChild(l);f.appendChild(i);return [f,i]}function eventFrom(seed,ins){return {id:seed.id||eid(),creator:seed.creator||"local",kind:"calendar-event",title:ins.title.value||"Untitled Event",date:ins.date.value||ymd(new Date()),time:ins.time.value,endTime:ins.end.value,location:ins.loc.value,notes:ins.notes.value,reminder:ins.rem.value||"1h",sourceNoteId:context&&context.noteId||seed.sourceNoteId||null,createdAt:seed.createdAt||Date.now(),updatedAt:Date.now()}}function form(seed,pub){seed=seed||{};clear();var p=E("div","panel"),h=E("h2");h.style.color="#ffaa00";h.appendChild(T(pub?"CREATE NOTE EVENT":"CREATE EVENT"));p.appendChild(h);var a=field("Title","text",seed.title),d=field("Date","date",seed.date||ymd(new Date())),ti=field("Start time","time",seed.time),en=field("End time","time",seed.endTime),re=field("Reminder","select",seed.reminder||"1h"),lo=field("Location","text",seed.location),no=field("Notes","notes",seed.notes);[a,d,ti,en,re,lo,no].forEach(function(x){p.appendChild(x[0])});var st=E("span","status"),bar=E("div","bar");bar.appendChild(btn(pub?"PUBLISH":"SAVE","primary",function(){var ev=eventFrom(seed,{title:a[1],date:d[1],time:ti[1],end:en[1],rem:re[1],loc:lo[1],notes:no[1]});upsert(ev);if(pub){st.textContent="Publishing";send("nb:publish",{name:ev.title,data:{kind:"calendar-event",event:ev}})}else renderFull()}));bar.appendChild(btn("CANCEL","",renderFull));bar.appendChild(st);p.appendChild(bar);root.appendChild(p);resize()}function detail(ev){clear();var p=E("div","panel"),h=E("h2"),m=E("div","meta"),b=E("div","big"),n=E("div","meta"),bar=E("div","bar"),st=E("span","status");h.style.color="#ffaa00";h.appendChild(T(ev.title));m.appendChild(T(fmtDate(ev)));b.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.location?"LOCATION: "+ev.location+"  ":"")+"REMINDER: "+rem(ev.reminder)+(ev.notes?"  "+ev.notes:"")));bar.appendChild(btn("EDIT","primary",function(){form(ev,false)}));bar.appendChild(btn("COPY REF","",function(){navigator.clipboard.writeText(ref(ev));st.textContent="Copied"}));bar.appendChild(btn("REMOVE","",function(){remove(ev);renderFull()}));bar.appendChild(btn("BACK","",renderFull));bar.appendChild(st);[h,m,b,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderFull(){mode.textContent="FULL CALENDAR";clear();var y=shown.getFullYear(),m=shown.getMonth(),first=new Date(y,m,1),start=new Date(first),today=ymd(new Date()),events=load();start.setDate(1-first.getDay());var bar=E("div","bar"),title=E("div","title"),grid=E("div","grid");title.appendChild(T(shown.toLocaleString([],{month:"long",year:"numeric"})));bar.appendChild(title);bar.appendChild(btn("PREV","",function(){shown.setMonth(m-1);renderFull()}));bar.appendChild(btn("TODAY","",function(){shown=new Date();renderFull()}));bar.appendChild(btn("NEXT","",function(){shown.setMonth(m+1);renderFull()}));bar.appendChild(btn("NEW EVENT","primary",function(){form({date:today},false)}));root.appendChild(bar);["Sun","Mon","Tue","Wed","Thu","Fri","Sat"].forEach(function(x){var e=E("div","dow");e.appendChild(T(x));grid.appendChild(e)});for(var i=0;i<42;i++){var d=new Date(start);d.setDate(start.getDate()+i);var date=ymd(d),cell=E("div","day"+(date===today?" today":"")+(d.getMonth()!==m?" muted":""));var da=E("div","date");da.appendChild(T(String(d.getDate())));cell.appendChild(da);cell.onclick=function(dd){return function(){form({date:dd},false)}}(date);events.filter(function(e){return e.date===date}).sort(function(a,b){return (a.time||"").localeCompare(b.time||"")}).slice(0,4).forEach(function(ev){var p=btn((ev.time?ev.time+" ":"")+ev.title,"pill",function(){detail(ev)});cell.appendChild(p)});grid.appendChild(cell)}root.appendChild(grid);resize()}async function noteEvents(){var nid=context&&context.noteId;if(!nid)return[];try{var r=await fetch("/~/scry/noltbook/api/notes/"+encodeURIComponent(nid)+".json"),n=await r.json(),out=[];(n.artifacts||[]).forEach(function(a){var raw=a.latestVersion&&a.latestVersion.content;if(raw){try{var d=JSON.parse(raw);if(d.kind==="calendar-event"&&d.event)out.push(d.event);if(d.kind==="calendar-event-list"&&Array.isArray(d.events))out.push.apply(out,d.events)}catch(e){}}});var t=ymd(new Date());return out.filter(function(e){return e.date>=t})}catch(e){return[]}}function renderTool(){mode.textContent="NOTE TOOL";clear();var p=E("div","panel"),h=E("h2"),m=E("p","meta"),bar=E("div","bar"),st=E("span","status");h.style.color="#ffaa00";h.appendChild(T("CALENDAR TOOL"));m.appendChild(T("Create a shareable event for this note, or post upcoming Calendar artifacts found here."));bar.appendChild(btn("CREATE EVENT","primary",function(){form({date:ymd(new Date())},true)}));bar.appendChild(btn("POST UPCOMING","",async function(){st.textContent="Scanning";var evs=await noteEvents();if(!evs.length){st.textContent="No upcoming events";return}send("nb:publish",{name:"Upcoming Calendar Events",data:{kind:"calendar-event-list",events:evs.slice(0,20),sourceNoteId:context&&context.noteId,createdAt:Date.now()}})}));bar.appendChild(btn("CLOSE","",function(){send("nb:close")}));bar.appendChild(st);[h,m,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderEvent(ev){mode.textContent="NOTE ARTIFACT";clear();var p=E("div","panel"),h=E("h2"),d=E("div","meta"),t=E("div","big"),n=E("div","meta"),bar=E("div","bar"),st=E("span","status");h.style.color="#ffaa00";h.appendChild(T(ev.title||"Calendar event"));d.appendChild(T(fmtDate(ev)));t.appendChild(T(fmtTime(ev)));n.appendChild(T((ev.location?"LOCATION: "+ev.location+"  ":"")+"REMINDER: "+rem(ev.reminder)));bar.appendChild(btn("ADD TO CALENDAR","primary",function(){upsert(ev);st.textContent="Added"}));bar.appendChild(btn("COPY REF","",function(){navigator.clipboard.writeText(ref(ev));st.textContent="Copied"}));bar.appendChild(btn("PAUSE","",function(){send("nb:close")}));bar.appendChild(st);[h,d,t,n,bar].forEach(function(x){p.appendChild(x)});root.appendChild(p);resize()}function renderList(evs){clear();var p=E("div","panel"),h=E("h2");h.style.color="#ffaa00";h.appendChild(T("UPCOMING EVENTS"));p.appendChild(h);(evs||[]).filter(function(e){return e.date>=ymd(new Date())}).forEach(function(ev){var row=E("div","bar"),main=E("div"),meta=E("div","meta");main.appendChild(T(ev.title));meta.appendChild(T(fmtDate(ev)+" - "+fmtTime(ev)));main.appendChild(meta);row.appendChild(main);row.appendChild(btn("ADD","",function(){upsert(ev)}));p.appendChild(row)});p.appendChild(btn("PAUSE","",function(){send("nb:close")}));root.appendChild(p);resize()}function renderArtifact(){var d=context&&context.artifact&&context.artifact.data||{};if(d.kind==="calendar-event")renderEvent(d.event||{});else if(d.kind==="calendar-event-list")renderList(d.events||[]);else{clear();root.appendChild(T("Unknown Calendar artifact."))}}window.addEventListener("message",function(e){if(e.source!==parent)return;var d=e.data;if(!d||d.source!=="noltbook-host"||d.protocol!==P)return;if(d.type==="nb:init"){session=d.session;context=d.payload;if(context.mode==="private-tool")renderTool();else renderArtifact()}else if(d.session!==session)return;else if(d.type==="nb:publish-result"){if(d.payload&&d.payload.ok)send("nb:close")}});if(window.parent===window)renderFull();else parent.postMessage({source:"noltbook-plugin",protocol:P,type:"nb:ready"},"*");</script></body></html>'
    =/  html-bytes=octs  (as-octs:mimes:html page)
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
