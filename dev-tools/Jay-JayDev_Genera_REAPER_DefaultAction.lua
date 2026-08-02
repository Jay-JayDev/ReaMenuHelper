-- ReaMenuHelper: genera Data/REAPER_DefaultAction.lst (azioni native REAPER, sezione Main).
-- Strumento per chi mantiene ReaMenuHelper (da rilanciare quando esce una nuova versione di
-- REAPER con azioni nuove), NON per l'utente finale — nello zip distribuito il file arriva già pronto.

local section = reaper.SectionFromUniqueID(0) -- 0 = Main

local resourcePath = reaper.GetResourcePath()
local outPath = resourcePath .. "/ReaMenuHelper/Data/REAPER_DefaultAction.lst"
local file = io.open(outPath, "w")

if not file then
  reaper.ShowMessageBox("Impossibile scrivere il file:\n" .. outPath, "Errore", 0)
  return
end

file:write("Section\tId\tAction\n")

local idx = 0
local count = 0
while true do
  local retval, name = reaper.kbd_enumerateActions(section, idx)
  if not retval or retval == 0 then break end
  file:write("Main\t" .. tostring(retval) .. "\t" .. tostring(name) .. "\n")
  count = count + 1
  idx = idx + 1
end

file:close()

reaper.ShowMessageBox("Fatto.\n\nAzioni scritte: " .. count .. "\nFile: " .. outPath .. "\n\nRicorda: prima di distribuire questo file, togli manualmente le righe dei tuoi script personali (Script:/Custom: che non sono azioni REAPER standard).", "ReaMenuHelper - Genera elenco azioni (solo per lo sviluppo)", 0)
