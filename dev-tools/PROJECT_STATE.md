# ReaMenuHelper — Stato del progetto

Documento di riferimento. Prima di prendere decisioni tecniche o toccare file, va riletto — non va ricostruito a memoria dalla chat.

**Punto di controllo 31/07**: dopo il giro di test su anteprima/sottomenu annidati/posizionamento a bordo schermo/toast, l'utente ha confermato "mi sembra tutto perfetto" — buono stato noto, utile riferimento se qualcosa si rompe in futuro.

## Struttura file — aggiornata 01/08: `DEFAULT_MENU_TEMPLATES` spostato fuori dall'HTML

**Premessa corretta dall'utente** (io mi ero basato su una premessa vecchia): il progetto NON è più "un file HTML solo" da tempo — è già uno zip con più file (`Data/REAPER_DefaultAction.lst` è già separato e mantenuto da Daryl). Quindi non c'era più motivo tecnico per tenere `DEFAULT_MENU_TEMPLATES` (~104KB) dentro l'HTML.

**Fatto**: `DEFAULT_MENU_TEMPLATES` spostato in `Data/default-menu-templates.js`, caricato con un normale `<script src="Data/default-menu-templates.js"></script>` — funziona perché `ReaMenuHelper.html` e `Data/` sono cartelle fianco a fianco (non serve l'API delle cartelle di REAPER, è un caricamento normalissimo via browser, funziona anche aprendo l'HTML con doppio click da file:// locale). Le funzioni `tA/tS/tH/tM/tF` restano nell'HTML PRIMA di questo tag (servono per valutare i dati del file esterno), il resto della logica (`RESERVED_MENU_COMMANDS`, `bareActionName`, ecc.) resta nell'HTML DOPO — quindi il singolo `<script>` originale è ora diviso in due tag inline con questo tag esterno in mezzo. `ReaMenuHelper.html` sceso da 228KB a 125KB. Verificato: sintassi di tutti e 3 i pezzi, e test funzionale end-to-end (21 sezioni, 1659 voci, 0 non risolte) rifatto dopo lo spostamento — stesso risultato di prima, nessuna perdita di dati.

**Struttura finale della cartella `ReaMenuHelper/`** (quella che va nello zip per l'utente):
```
ReaMenuHelper/
├── ReaMenuHelper.html
└── Data/
    ├── REAPER_DefaultAction.lst
    ├── default-menu-templates.js
    └── help-content.js
```
Solo questi 4 file servono all'utente finale. Restano nella cartella di lavoro ma NON vanno nello zip distribuito: `Genera_REAPER_DefaultAction.lua` (strumento solo per Daryl) e `PROJECT_STATE.md` (documento di lavoro nostro).

## Pulsante Help (01/08)

Pulsante **❓ Help** in cima a destra nella topbar (dopo `.spacer`). Apre `#help-overlay` (variante larga di `.modal-box`, classe `.help-box`, scorrevole, chiudibile con la ×, con click sull'ambiente esterno o con la ×). Il contenuto vero e proprio (istruzioni passo-passo in tabella + spiegazione delle 4 schede della palette) sta in `Data/help-content.js` (`const HELP_HTML = \`...\`;`), caricato con `<script src="Data/help-content.js">` — stesso meccanismo già validato per `default-menu-templates.js`, nessuna chiamata `fetch()` (bloccata su file:// da Chrome/Edge). Al click sul pulsante, `#help-content.innerHTML = HELP_HTML`. Testo aggiornabile modificando solo quel file, senza toccare `ReaMenuHelper.html`.

**Pulizia fatta lo stesso giorno** (file eliminati perché inutili/residui, non solo esclusi dallo zip): i 3 file-promemoria vuoti di Daryl (`01/02/03 ....txt`), `Data/reamenu-groups.json` (dati di test di Daryl — l'app la ricrea da sola al primo salvataggio gruppi dell'utente), `Data/system.png` (serviva solo come sorgente per l'icona REAPER nella topbar, ora già incorporata in base64 dentro l'HTML), e un `reamenu-groups.json` doppione mai usato che stava fuori dalla cartella Data.

## Obiettivo

Sostituire la finestra "Customize menus/toolbars" di REAPER (considerata l'unico vero difetto di REAPER) con un editor drag&drop più semplice, distribuibile come file HTML singolo via GitHub (zip), zero installazioni, funzionante offline. Utente finale: musicisti/sound engineer, NON tecnici. Non si può mai chiedere all'utente di andare a cercare file o capire cosa sono.

## Regole ferree (violate in passato, da NON ripetere)

1. **Mai toccare/caricare automaticamente `reaper-menu.ini`** (il file live di REAPER). L'app lavora sempre su un file di output separato che l'utente importa manualmente in REAPER.
2. **Mai auto-caricare un `.ReaperMenuSet` precedentemente salvato.** Per quello esiste il pulsante "Import".
3. **SWS non è più una dipendenza.** L'elenco azioni native (`Data/REAPER_DefaultAction.lst`) si genera con `Genera_REAPER_DefaultAction.lua` (ReaScript puro, nessuna estensione richiesta) — ma questo lo fa DARYL, non l'utente finale (vedi "Architettura file" sotto per il perché). Se in futuro esistono due versioni di quel file, **va sempre tenuta quella generata dal Lua**, mai una vecchia via SWS — questo è già successo per errore una volta (vedi sotto, "Incidente").
4. Non proporre più opzioni quando l'utente chiede una singola decisione: dare una risposta diretta.
5. Non scrivere/modificare codice senza conferma esplicita dell'utente sulla modifica specifica (istruzione globale utente).
6. Prima di ogni decisione consequenziale (es. "quale file tengo?"), va detto esplicitamente il motivo — così un errore di collegamento con l'intento dell'utente si vede PRIMA di agire, non dopo.

## Incidente registrato (per non ripeterlo)

Dopo aver fatto scrivere all'utente `Genera_REAPER_DefaultAction.lua` proprio per eliminare la dipendenza da SWS, alla domanda "ho due file REAPER_DefaultAction.lst, quale tengo?" ho risposto "tieni quello vecchio (SWS)" perché tecnicamente più completo, ignorando che l'intero scopo dello script Lua era eliminare SWS. Ho anche cancellato il file generato dal Lua. Errore di ragionamento (non di memoria): avevo entrambi i fatti disponibili ma non li ho ricollegati all'intento dichiarato dall'utente prima di rispondere.

## Architettura file

- **App**: `ReaMenuHelper.html` — file singolo autosufficiente (stato JS, parser/serializer, UI, drag&drop, tutto inline).
- **Cartella REAPER** (scelta una volta dall'utente via File System Access API, permesso valido anche ai riavvii con re-conferma manuale):
  - `reaper-kb.ini` → azioni custom (script/macro dell'utente)
  - `MenuSets/` → dove si salvano gli export (`.ReaperMenuSet` / `.ReaperMenu`)
  - `ReaMenuHelper/Data/` (sottocartella derivata, stesso permesso):
    - `REAPER_DefaultAction.lst` → elenco azioni native REAPER
    - `reamenu-groups.json` → i Gruppi salvati dall'utente (salvataggio automatico, non c'è un pulsante "Salva Gruppi" visibile)

**IMPORTANTE — deciso il 31/07, corregge una conclusione sbagliata presa in questa stessa sessione**: il musicista finale NON deve lanciare `Genera_REAPER_DefaultAction.lua`. Le azioni native di REAPER (quelle in `Data/REAPER_DefaultAction.lst`, a parte gli script personali) sono le stesse per chiunque abbia la stessa versione di REAPER — non sono dati personalizzati dell'utente, sono "di serie". Quindi:
- Daryl genera `Data/REAPER_DefaultAction.lst` dalla propria installazione REAPER, **filtra via le righe dei propri script personali** (facilmente riconoscibili: nomi tipo "Script: nomefile.lua" o "Custom: nome" che non sono azioni REAPER standard), e lo include già pronto nello zip distribuito su GitHub.
- Quando esce una versione REAPER nuova con azioni nuove, Daryl rigenera il file e lo ripubblica.
- Il musicista scarica lo zip e basta — non deve mai aprire REAPER per generare nulla.
- Le azioni CUSTOM di ogni singolo musicista (i suoi script/macro) restano gestite come già fa l'app: lette da `reaper-kb.ini` nella sua cartella REAPER (`refreshCustomActions()`), scheda "Azioni Custom" — meccanismo separato e già corretto, non tocca.
- `Genera_REAPER_DefaultAction.lua` resta nel repository/nella cartella di sviluppo, ma è uno strumento per DARYL (per rigenerare il file quando serve), non per l'utente finale.

**Stato attuale reale della cartella Data (verificato 31/07, dopo i rinomini):**
```
Data/REAPER_DefaultAction.lst   <- ancora la versione CON le righe personali di Daryl, da ripulire (vedi Prossimi passi)
Data/reamenu-groups.json
```
Contenuto verificato: formato 3 colonne `Section\tId\tAction`, tutte `Main`, 4356 azioni (di cui 10 sono script personali di Daryl da rimuovere prima della distribuzione). L'app legge il file case-insensitive (`dir.getFileHandle('REAPER_DefaultAction.lst')` in `ReaMenuHelper.html`).

## Formati file REAPER (verificati)

- `reaper-menu.ini`: `[Sezione]`, `default=`, `title=`, `item_N=<comando> <testo>`. Comando: `-1` separatore, `-2 testo` apertura submenu, `-3` chiusura submenu, `-4 testo` header, numero = azione nativa, `_XXXX` = azione custom.
- **Vincolo duro e verificato esaustivamente**: `reaper-menu.ini` contiene SOLO le sezioni che l'utente ha manualmente personalizzato in REAPER. REAPER non espone mai il contenuto di default delle sezioni non toccate, con nessun meccanismo (export, riavvio, Reset, API ReaScript). Per questo esiste il motore "Genera Menu di Default" (vedi sotto).
- `reaper-kb.ini`: `SCR <sezione> <flag> RS<hash> "Descrizione" "path"` e `ACT <sezione> <flag> "<hash>" "Descrizione" <id...>`. Regex hash deve includere underscore (`RS[0-9a-fA-F_]+`) per gli ID scoped al MIDI editor (es. `RS7d3c_...`).
- Action list export (formato 3 colonne, tab-separated): `Section\tId\tAction`. Lo stesso ID numerico può significare cose diverse in sezioni diverse ("Main" vs "MIDI Editor" vs "Media Explorer") — 562 collisioni di nome confermate. Il matching per "Genera Menu di Default" filtra SEMPRE `section === 'Main'`.

## Motore "Genera Menu di Default"

Combina un template strutturale (costruito a mano per Main file/edit/view da screenshot; per gli altri 18 generato a partire dai file .ReaperMenu esportati dall'utente, vedi sotto) con `Data/REAPER_DefaultAction.lst` (sempre aggiornata, versione-corretta). Funzioni chiave in `ReaMenuHelper.html`: `tA/tS/tH/tM/tF` (nodi template, ognuno commentato nel codice), `DEFAULT_MENU_TEMPLATES`, `bareActionName`, `findMainActionByName`, `resolveTemplateNode`, `generateDefaultSection`.

Cinque tipi di nodo:
- `tA(nome, override?)` — cercato per NOME in `Data/REAPER_DefaultAction.lst` ogni volta che si genera il menu. Caso normale, si autoaggiorna da solo tra versioni di REAPER.
- `tS()` — separatore.
- `tH(nome)` — riga di solo testo, davvero non cliccabile (equivalente al comando REAPER 65535 "No-op"). Usare SOLO per testo informativo puro, mai per segnaposto di liste dinamiche (vedi sotto perché è un errore diverso).
- `tM(nome, figli)` — sottomenu.
- `tF(nome, id)` — comando con ID fisso, per due casi molto diversi tra loro che NON vanno confusi:
  1. comandi reali "normali" ma invisibili a `kbd_enumerateActions` (es. "Close" nel Mixer, i preset di playrate, le forme dei punti inviluppo Linear/Square/Bezier);
  2. **segnaposto di liste dinamiche di REAPER** (es. "(take list)", "(track template list)", "(theme list)", "(lane name)"). Questi NON sono testo — sono voci vere che REAPER stesso riconosce dal numero e sostituisce con il contenuto reale quando il menu viene aperto davvero (es. "(take list)" diventa "Take 1: ...", "Take 2: ..." cliccabili). Se trattati come `tH` (titolo), REAPER li lascerebbe scritti così per sempre, senza mai espanderli — bug verificato con screenshot del menu reale di REAPER (tasto destro su un item con 2 take: REAPER mostra davvero "Take 1: 01-MIDI" / "Take 2: ..." al posto del segnaposto).

  In entrambi i casi il numero NON si autoaggiorna tra versioni di REAPER — resta fisso, preso dal file .ReaperMenu esportato dall'utente. Rischio pratico basso per i comandi normali (REAPER non ha mai rinumerato un comando nativo in 20+ anni); per i segnaposto di liste, l'ID è documentato esternamente (vedi sotto) quindi ancora più affidabile.

**Fonte esterna verificata**: la categoria "comandi invisibili a Data/REAPER_DefaultAction.lst" è documentata dal progetto Ultraschall (mespotin.uber.space/Ultraschall/Reaper-Filetype-Descriptions.html) come "Menu only actions" — non è una deduzione isolata mia. La stessa fonte + una verifica diretta dell'utente dentro REAPER (Customize dialog e menu reale) hanno corretto un errore di classificazione: inizialmente avevo scambiato i segnaposto di lista dinamica (tipo "(take list)") per testo informativo inerte e li avevo messi come `tH`. Sono voci funzionanti, vanno `tF`. Corretti tutti i ~22 casi trovati: "(track template list)" (×5), "(take list)" (×2), "(comp list)" (×2), "(folder list)", "(lane name)", "(lane list)", "(theme list)", "(project template list)", "(recent project list)", "Select envelope (env name)" (×2), "<automation items on disk>" (×3), "Automation items", "no markers/regions" — inclusi 2 casi che erano nel template "Main file" scritto a mano molto prima di oggi, mai accorti fino ad ora.

Restano `tH` solo 4 righe, verificate come davvero testo informativo puro (equivalgono al comando REAPER 65535 "No-op"): "Hold shift to open in new project tab..." (Main file), "When not adding lanes..." (Main options), "Drag below the main toolbar..." (Ruler/arrange context), "Override project recording behavior:" (Track fixed lane controls context).

**Tutti i 21 template sono completati e verificati** (test funzionale: 0 voci irrisolte su 1659 totali, 1285 azioni, contro `Data/REAPER_DefaultAction.lst` reale):
- Main file: 23 `tA` + 2 `tF` (48000 "(project template list)" e 44000 "(recent project list)" — confermati con export reale `REAPER_Main File.ReaperMenu`, non solo fonte esterna)
- Main edit: 14/14 azioni
- Main view: 64 `tA` + 1 `tF` (43699, assente da `Data/REAPER_DefaultAction.lst` ma valido)
- I restanti 18 (Main insert/item/track/options/actions, Ruler/arrange context, Track control panel context, Track fixed lane controls context, Track spacer context, Empty TCP context, Media item context, Envelope context, Envelope point context, Automation item context, Mixer context, FX extended mixer context, Sends extended mixer context, Transport context) — costruiti a partire dai file `.ReaperMenu` reali esportati dall'utente in `MenuSets/`, incrociando ogni ID del file con `Data/REAPER_DefaultAction.lst`.

Nota: il file `Empty TCP context_300720261843.ReaperMenu` (senza prefisso `REAPER_`) era vecchio materiale di test (azioni DARYL_*), non usato — il template usa `REAPER_Empty TCP context.ReaperMenu`.

**Verifica in corso, una voce alla volta, dentro REAPER vero** (non solo a livello di codice/dati). Nomi sempre quelli originali di REAPER (inglese), mai tradotti:
- ✅ "(take list)" (45000) — confermato con screenshot del menu reale (mostra i take veri)
- ✅ "(recent project list)" (44000) e "(project template list)" (48000) — confermati con export reale `REAPER_Main File.ReaperMenu`
- ✅ "(theme list)" (45500) — confermato con screenshot: Options → Themes mostra 3 temi reali cliccabili (Default, Default_6.0, Classic_1.x)
- ✅ "Select envelope (env name)" (40854) — confermato con screenshot: tasto destro su un inviluppo mostra "Envelope: Volume" (voce grigia non cliccabile, ma con nome vero, dinamico — diverso da "(take list)" che invece è cliccabile, ma stesso meccanismo: serve l'ID vero per la sostituzione)
- ✅ "(track template list)" (46001, usato in Main insert/Main track/Track control panel context/Track spacer context/Empty TCP context) — confermato: senza modelli salvati REAPER mostra "(no saved track templates)", non il testo letterale del segnaposto — conferma la sostituzione dinamica anche a lista vuota

**Categoria "segnaposto di lista" considerata verificata come classe** (4 esempi diversi confermati, stesso meccanismo REAPER) — non serve più testare uno per uno gli altri: "(comp list)" (45100), "(folder list)" (49000), "(lane name)" (1945), "(lane list)" (42804), "<automation items on disk>" (42094), "Automation items" (42219), "no markers/regions" (40264).

⏳ **Categoria diversa, NON ancora testata**: i `tF` di comando normale/fisso (es. "Close" nel Mixer, i preset di playrate, le forme dei punti inviluppo Linear/Square/Bezier, "Hide Transport") — questi sono comandi singoli, non liste dinamiche, vale la pena controllarne almeno un paio.

Nota metodologica: non fidarsi di una fonte esterna (sito web) da sola per questi ID — il fatto che un numero NON compaia nell'elenco azioni di REAPER è normale per questa categoria, non un segnale di errore. La verifica affidabile è un export reale dell'utente da REAPER (come fatto per "Main file") o un test visivo nel menu vero.

Caso limite riscontrato durante la costruzione: l'ID 45000 nel menu "(take list)" di Main item/Media item context coincide per puro caso con un comando reale non correlato ("Take: Set 1st take active") in `Data/REAPER_DefaultAction.lst`. Per questo il riconoscimento dei segnaposto controlla prima il testo (pattern tipo "(...)", "<...>", o ID 65535) e solo dopo cerca il nome — non si fida del solo "l'ID esiste" per decidere se è un'azione vera.

## "Nuova sezione"

`VALID_SECTION_NAMES` è una lista chiusa di 21 nomi di sezione validi per REAPER (nomi interni puliti, senza mnemonici `&`). Verificato empiricamente: REAPER rifiuta in import un `.ReaperMenu` con nome sezione non riconosciuto (es. errore con la sezione di test "cacca"), quindi niente nomi liberi. "Main toolbar" è stato rimosso dalla lista su richiesta esplicita dell'utente. Il popup "Nuova sezione" ora crea SOLO sezioni vuote (pulsanti: Annulla / Crea) — generare i default è un'azione separata, vedi sotto.

## Comandi riservati (palette)

`RESERVED_MENU_COMMANDS`: lista fissa di 80 comandi (gli stessi usati internamente da `tF()` nei template), esposti anche nella scheda "native" della palette con badge "Riservato", trascinabili a mano in qualsiasi menu — non solo tramite generazione automatica. Servono perché questi comandi non sono mai cercabili tramite il normale meccanismo per nome (non compaiono in `Data/REAPER_DefaultAction.lst`).

## "Aggiungi Voci di Default di Reaper" (ex "Genera con i default")

Rinominato e spostato: prima viveva solo nel popup "Nuova sezione" (quindi utilizzabile solo alla creazione, mai dopo). Ora è un pulsante fisso a destra nella barra "Menu: X" in alto al canvas, sempre disponibile mentre modifichi quella sezione — vale sia su sezioni vuote sia già popolate. Comportamento: se la sezione è vuota la riempie direttamente; se ha già contenuto, chiede conferma e poi mette **i default in cima**, seguiti da UN separatore, col contenuto già presente sotto (non il contrario — errore di comprensione mio corretto durante la sessione, verificare bene se si ritorna su questa funzione). Funzione: `addDefaultsToCurrentSection()`.

## Elemento "Intestazione: nome sezione" (palette, scheda Elementi)

Quarto elemento oltre a Separatore/Intestazione/Submenu vuoto — non esiste in REAPER, è un comodo raccorciatoia dell'app. Crea un header (`newHeader`) con testo già precompilato col nome della sezione/contesto corrente (`s.displayTitle || s.name`), invece del generico "Nuova intestazione" da rinominare a mano. Il nome si valuta al momento del trascinamento (drop), non alla creazione della card, quindi riflette sempre la sezione che si sta guardando in quel momento.

## Avviso "sessione recuperata, non ancora salvata"

Al click su "Recupera" nel banner di ripristino, se il contenuto recuperato ha qualcosa di esportabile (`hasExportableContent()`), appare un toast persistente rosso lampeggiante ("⚠️ ATTENZIONE!!! - Sessione Recuperata - Non ancora Salvata", chiave `recovered-warning`, nessun timer — sparisce solo con la X o quando l'utente salva davvero, vedi `dismissToastByKey` richiamato nei 3 punti di salvataggio: `saveMenuFile`, e i 2 percorsi di `saveMenuFileAs`).

**Bug segnalato dall'utente e corretto**: se il contenuto recuperato non aveva nulla di esportabile (es. un contesto vuoto creato e poi refresh), l'app mostrava comunque l'avviso "salva!" con `state.dirty=true`, ma il pulsante Export restava disabilitato (giustamente, non c'è nulla da esportare) — un vicolo cieco logico, l'avviso non poteva mai essere soddisfatto nel modo previsto. Fix: `state.menuFileRecovered`/`state.dirty` si attivano SOLO se `hasExportableContent()` è vero al momento del recupero; altrimenti il ripristino avviene silenziosamente con un toast normale ("Sessione recuperata."), non allarmante.

## Finestre di dialogo

Tutti i `confirm()`/`prompt()` nativi del browser sono stati sostituiti con una finestra unica in stile app (`showConfirmModal(msg, opts)` / `showPromptModal(msg, defaultValue)`, entrambe Promise-based, overlay `#generic-modal-overlay`), riusata da: reset test, elimina sezione, aggiungi default, nuovo gruppo, rinomina gruppo, elimina gruppo. Se in futuro serve un'altra conferma/input da utente, usare queste, mai `confirm()`/`prompt()`/`alert()` diretti.

## Autosalvataggio: race condition su refresh (bug segnalato e corretto)

Bug: refresh veloce dopo una modifica → a volte il contenuto spariva senza nemmeno offrire "Recupera". Causa: l'autosalvataggio su IndexedDB è debounced (600ms) e asincrono — un refresh può interrompere la scrittura a metà o prima che parta. Fix in due parti:
1. `visibilitychange`/`pagehide` forzano un tentativo di salvataggio immediato invece di aspettare il timer.
2. Rete di sicurezza sincrona: stesso snapshot scritto anche su `localStorage` (chiave `LS_SNAPSHOT_KEY`), che a differenza di IndexedDB è sincrono e garantito completarsi prima che l'handler finisca. Al riavvio (`tryRestoreAutosave`) si confrontano i due snapshot (IndexedDB e localStorage) e si usa il più recente.

**Bug correlato trovato dall'utente**: il banner "Recupera" mostrava "menu: ?" invece di un nome vero. Causa: `state.menuFileName` si valorizza SOLO quando si importa un file di partenza (`loadStarterFile`) — se le sezioni sono costruite da zero con "Nuova sezione" (caso comune), resta sempre vuoto, quindi il banner sembrava rotto anche con contenuto vero da recuperare. Fix: il banner ora mostra il conteggio e i primi nomi delle sezioni (sempre disponibili, è la stessa condizione già usata per decidere se mostrare il banner) invece di `menuFileName`.

Utente ha confermato che ora "pare funzionare", tenerlo sotto controllo — non dato per chiuso al 100%, IndexedDB durante un unload resta tecnicamente non garantito anche con questi accorgimenti.

## Playground: RIMOSSO, sostituito da anteprima diretta (31/07)

Il Playground (vista separata con 8 zone su 21, mai completata) è stato eliminato del tutto su richiesta dell'utente — idea migliore: invece di dover mappare "zona finta → sezione", basta un'anteprima diretta del menu che si sta già modificando.

Rimosso: `PLAYGROUND_ZONES`, `guessSectionFor`, `renderPlayground`, `setView`, `state.view`, `state.playgroundZones`, il toggle "Editor/Playground" in alto, `#playground-view`, CSS `.pg-zone*`/`.view-toggle*`. L'app ora ha una sola vista, sempre visibile (niente più toggle).

Aggiunto: pulsante vero (non una semplice iconcina — classe `btn-secondary`, come "Aggiungi Voci di Default di Reaper") con testo "🎯 Anteprima", PRIMA di "Menu: X" nel breadcrumb (a sinistra del testo, non dopo). Un click mostra subito l'anteprima flyout del menu correntemente aperto, riusando `showFlyoutMenu()`/`buildFlyoutLevel()` con `state.currentSectionName`. Nessuna mappatura zona↔sezione più necessaria: si vede sempre e solo il menu che si sta guardando in quel momento.

**Bug reale trovato testando l'anteprima su un menu con sottomenu annidati** (segnalato dall'utente con screenshot: "michia" → "Nuovo submenu" non si apriva): `buildFlyoutLevel()` chiudeva TUTTI i sottomenu aperti in tutta la pagina (`document.querySelectorAll('.flyout-sub.open')`) ogni volta che se ne apriva uno nuovo — quindi aprire un sottomenu di secondo livello chiudeva anche il suo genitore (che doveva restare aperto per contenerlo), facendo sparire l'intera catena. Funzionava al primo livello per puro caso (nessun antenato da chiudere accidentalmente). Fix: la chiusura ora è scoperta solo ai sottomenu FRATELLI dello stesso livello (`wrap.querySelectorAll(':scope > .flyout-item > .flyout-sub.open')`), mai agli antenati.

**Secondo bug, stesso giro di test**: un menu lungo posizionato vicino al bordo dello schermo usciva fuori dalla finestra (nessun controllo dei confini). Fix in tre parti: `clampToViewport()` riposiziona il flyout principale dopo averlo renderizzato, se sfora; `positionFlyoutSub()` fa lo stesso per ogni sottomenu quando si apre; `.flyout-menu` ha ora anche `max-height:calc(100vh - 16px); overflow-y:auto` come rete di sicurezza per menu davvero più lunghi dello schermo intero.

**Terzo bug, causato proprio da quel `overflow-y:auto` appena aggiunto** (segnalato dall'utente con screenshot: sottomenu "Master Track" nel Mixer context mostrava il contenuto mescolato con quello del menu padre): regola poco nota del CSS — se un elemento ha `overflow-y` diverso da `visible` ma `overflow-x` non specificato (quindi `visible` di default), il browser forza ANCHE `overflow-x` ad `auto`. Risultato: ogni `.flyout-menu` ora tagliava tutto ciò che usciva dal proprio bordo destro, sottomenu compresi (che dovrebbero uscire a destra del genitore). `positionFlyoutSub()` prima passava a `position:fixed` SOLO quando rilevava che il sottomenu sarebbe uscito dallo schermo — nei casi "normali" (sottomenu che ci stava comodamente) restava `position:absolute`, quindi vulnerabile al taglio. Fix: `positionFlyoutSub()` ora usa SEMPRE `position:fixed` per ogni sottomenu, non solo quando serve il clamp — `position:fixed` non viene mai tagliato dall'overflow di un antenato (finché nessun antenato usa `transform`), quindi risolve il problema alla radice invece di limitarsi ai casi limite.

**Nota per il futuro**: `overflow-y:auto` senza specificare esplicitamente `overflow-x` è un'insidia CSS silenziosa — se in futuro serve scroll verticale su un contenitore che ha anche figli/popup che devono uscire orizzontalmente dal suo bordo, ricordarsi di questa regola.

**Nel processo scoperto un bug reale** (non ipotetico): `setView()` nascondeva/mostrava le viste con `element.style.display = ''` per "mostra". `''` non vuol dire "mostra con il default", vuol dire "togli lo stile inline, torna a quello del CSS" — e il CSS di `#playground-view` aveva `display:none` come regola base, quindi il Playground non si apriva MAI (l'utente lo vedeva come uno schermo blu scuro vuoto dietro la barra pulsanti). Per `#editor-view` funzionava per puro caso, perché il suo default CSS era già `display:flex`. **Nota per il futuro**: se un'altra vista/pannello sembra "non aprirsi mai" pur senza errori in console, controllare per primo questo pattern (`style.display = ''` su un elemento il cui CSS di base è `display:none`) prima di ipotizzare altro. Il bug non esiste più (il codice che lo conteneva è stato rimosso insieme al Playground), ma il pattern va evitato altrove nel codice.

Discusso e scartato: un Playground "fotorealistico" con screenshot veri di REAPER come sfondo e zone cliccabili posizionate in percentuale — tecnicamente fattibile ma giudicato troppo dispersivo (serve uno screenshot calibrato per ogni zona particolare, i menu della barra in alto non ci si prestano). Non più rilevante ora che il Playground a zone è stato eliminato.

## Wizard guidato — completo (31/07)

Richiesta originale (accantonata da tempo, non "mesi fa"): "i passaggi forzati devono seguire la prassi guidata tipo un wizard che faccia lampeggiare i passaggi necessari".

Concezione decisa con l'utente: **non** un wizard a schermate bloccate in sequenza — solo evidenziazione lampeggiante sul pulsante giusto, senza impedire di guardarsi in giro, TRANNE per il primo passo (cartella REAPER), che è un vero blocco perché senza quello l'app è sostanzialmente inutilizzabile (niente azioni custom, niente azioni riservate cercabili per nome dal file bundlato, niente posto dove salvare l'export).

Tre passaggi identificati come "necessari": (1) Cartella REAPER — bloccante vero; (2) crea/importa almeno una sezione; (3) esporta — questi due restano solo lampeggio guidato, non ancora implementati.

**Passo 1 implementato**: `#dir-required-overlay` (overlay scuro su tutto `#main` — sidebar/canvas/palette — con messaggio, `pointer-events` bloccati di default dato che è un div sopra tutto) + classe `.blink` con `@keyframes dir-btn-blink` sul pulsante "📁 Cartella REAPER..." (che resta fuori dall'overlay, nella topbar, quindi sempre cliccabile). Attivi/disattivi in `renderTopbar()`, condizione `!state.reaperDirHandle` — copre sia il caso "mai scelta" sia il caso "serve solo riconfermare il permesso dopo un riavvio" (`state.pendingReaperDirHandle`), perché in entrambi `reaperDirHandle` resta null finché non è davvero pronta.

**Passo 2 implementato**: lampeggio su "Nuova sezione" (`#btn-new-section`, stessa animazione `dir-btn-blink`), MA solo la primissima volta — a differenza del passo 1, qui non basta guardare `state.sections.length === 0` (altrimenti lampeggerebbe di nuovo ogni volta che l'utente elimina tutte le sezioni, diventando fastidioso). Tracciato con un flag persistito in `localStorage` (`LS_CREATED_SECTION_KEY`): appena `state.sections.length > 0` una volta, il flag si fissa a `'1'` per sempre e il lampeggio non si ripresenta più, anche se in futuro le sezioni tornano a zero. Logica in `renderSectionList()`.

In più, richiesto insieme: **colonna centrale (canvas) disabilitata quando non ci sono sezioni** — `#canvas-panel.disabled` (opacità ridotta + `pointer-events:none`), attivata/disattivata in `renderAll()` in base a `state.sections.length === 0`. A differenza del lampeggio "una tantum", questa si riattiva ogni volta che le sezioni tornano a zero (comportamento voluto: non c'è nulla da editare, va disabilitata sempre, non solo la prima volta).

**Passo 3 implementato**: lampeggio su "💾 Export..." (`#btn-export-menu`, stessa animazione), condizione `state.dirty && hasExportableContent()` in `updateDirtyIndicator()` — a differenza del passo 2, questo NON è una tantum: si riattiva ogni volta che ci sono modifiche non salvate, perché è uno stato che si ripresenta normalmente durante il lavoro (stesso spirito del pallino `#dirty-dot` già esistente, solo più evidente).

**Wizard: tutti e 3 i passaggi implementati.** Nessun lavoro strutturale rimasto in sospeso su questa funzione.

## Stato funzionale generale

Parser/serializer ini: verificato byte-identico su file reale 8109 righe. Parsing reaper-kb.ini: 8692/8692 azioni custom. Drag&drop: motore custom a Pointer Events (non HTML5 nativo), soglia 5px, ghost element, drop-line indipendente calcolata sul punto medio tra blocchi. Export bloccato se il menu è vuoto (`hasExportableContent`). Permessi File System Access persistiti con re-conferma manuale al riavvio browser (mai `requestPermission()` automatico, solo `queryPermission()` in avvio + richiesta reale solo dentro il click handler).

## Prossimi passi

Fatto: `Data/REAPER_DefaultAction.lst` già ripulito dalle righe personali (31/07) — pronto per quando servirà.

1. Continuare a usare l'app normalmente e segnalare bug/rifiniture UI via via — nessun lavoro strutturale grosso rimasto in sospeso sul motore "Genera Menu di Default", quello è considerato finito e verificato. Wizard guidato completo (vedi sopra). Pulsante Help con istruzioni fatto (01/08, vedi sopra).
2. La categoria `tF` "comando normale" (Close nel Mixer, preset playrate, forme punti inviluppo) resta tecnicamente non testata dentro REAPER vero, ma l'utente ha giudicato il test inutile — non è un blocco.

**Deciso il 31/07: la pacchettizzazione in zip è volutamente rimandata a molto più avanti**, solo quando tutto il resto è finito — non proporla né iniziarla finché l'utente non lo chiede esplicitamente.
