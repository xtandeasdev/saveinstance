# SaveInstance
SaveInstance Module For Luau

Usage:
```lua
local SaveInstance = require(game.ServerScriptService.SaveInstance)
local module = SaveInstance.new(true) --if this is true then error mode is on
module:BulkSave(game.Workspace.MyParts:GetDescendants(), "myparts") --first is basepart folder or model and second is identity for datastore
module:BulkGet("myparts") --if the id is saved in the datastore, the parts are cloned in the workspace with recent properties
module:BulkRemove("myparts") --removes this identity on datastore
```

### Example:
create new folder in workspace, set its name to MyParts and create few parts inside of MyParts folder.
Create new script, paste this code inside.

```lua
local SaveInstance = require(game.ServerScriptService.SaveInstance)
local module = SaveInstance.new(true)
module:BulkSave(game.Workspace.MyParts:GetDescendants(), "myparts")
task.wait(.5)
for i,v in pairs(game.Workspace.MyParts:GetDescendants()) do
  v:Destroy()
end

```
after joined the game, delete MyParts Folder.
and replace line 2 and below

```lua
module:BulkGet("myparts")
```

happy coding.
