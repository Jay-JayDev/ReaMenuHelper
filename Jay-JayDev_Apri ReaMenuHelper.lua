-- Apre ReaMenuHelper.html (nella stessa cartella di questo script) nel browser predefinito.

local script_path = ({reaper.get_action_context()})[2]:match('^(.*[/\\])')
local html_path = script_path .. 'ReaMenuHelper.html'

if not reaper.file_exists(html_path) then
  reaper.ShowMessageBox('File non trovato:\n' .. html_path, 'ReaMenuHelper', 0)
  return
end

if reaper.GetOS():match('Win') then
  reaper.ExecProcess('cmd.exe /c start "" "' .. html_path .. '"', -2)
else
  reaper.ExecProcess('open "' .. html_path .. '"', -2)
end
