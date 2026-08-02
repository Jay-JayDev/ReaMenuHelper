-- Opens ReaMenuHelper.html (in the same folder as this script) in the default browser.

local script_path = ({reaper.get_action_context()})[2]:match('^(.*[/\\])')
local html_path = script_path .. 'ReaMenuHelper.html'

if not reaper.file_exists(html_path) then
  reaper.ShowMessageBox('File not found:\n' .. html_path, 'ReaMenuHelper', 0)
  return
end

if reaper.GetOS():match('Win') then
  reaper.ExecProcess('cmd.exe /c start "" "' .. html_path .. '"', -2)
else
  reaper.ExecProcess('open "' .. html_path .. '"', -2)
end
