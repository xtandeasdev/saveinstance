local RunService = game:GetService("RunService")
 
if RunService:IsClient() then
    --if its client return error
    error("SaveInstance Module Cannot call on client.")
    return
end
local saveinstance = {}
local HttpService = game:GetService("HttpService")
local DataStore = game:GetService("DataStoreService"):GetDataStore("Instances")
local debugmode = false
function saveinstance.New(debugMode : boolean?)
    --Construct class
    local self = setmetatable(saveinstance, {})
    if debugMode ~= nil then
        debugmode = debugMode
        --if debug mode is true, save a part and check output
    end
    return self
end
function saveinstance:GetProperties(basepart : Part) 
    local properties = {
        --parts position
        ["Position"] = {basepart.Position.X,basepart.Position.Y,basepart.Position.Z},
        ["Anchored"] = basepart.Anchored,
        --parts orientation
        ["Orientation"] = {basepart.Orientation.X,basepart.Orientation.Y,basepart.Orientation.Z},
        --parts color
        ["Color"] = {basepart.Color.R,basepart.Color.G,basepart.Color.B},
        --parts transparency
        ["Transparency"] = basepart.Transparency,
        ["CanCollide"] = basepart.CanCollide,
        ["Size"] = {basepart.Size.X, basepart.Size.Y, basepart.Size.Z},
        ["CanTouch"] = basepart.CanTouch,
        ["CanQuery"] = basepart.CanQuery,
        ["Name"] = basepart.Name,
        ["Parent"] = basepart.Parent,
        --parts collision group
        ["CollisionGroup"] = basepart.CollisionGroup,
        ["Material"] = basepart.Material.Name,
        --part surfaces
        ["BackSurface"] = basepart.BackSurface.Name,
        ["BottomSurface"] = basepart.BottomSurface.Name,
        ["FrontSurface"] = basepart.FrontSurface.Name,
        ["LeftSurface"] = basepart.LeftSurface.Name,
        ["RightSurface"] = basepart.RightSurface.Name,
        ["TopSurface"] = basepart.TopSurface.Name,
        ["Shape"] = basepart.Shape.Name,
        ["Massless"] = basepart.Massless,
        ["AssemblyLinearVelocity"] = {basepart.AssemblyLinearVelocity.X, basepart.AssemblyLinearVelocity.Y, basepart.AssemblyLinearVelocity.Z},
    }
    if basepart.CustomPhysicalProperties ~= nil then
        properties["CustomPhysicalProperties"]["Density"] = basepart.CustomPhysicalProperties.Density
        properties["CustomPhysicalProperties"]["Elasticity"] = basepart.CustomPhysicalProperties.Elasticity
        properties["CustomPhysicalProperties"]["ElasticityWeight"] = basepart.CustomPhysicalProperties.ElasticityWeight
        properties["CustomPhysicalProperties"]["Friction"] = basepart.CustomPhysicalProperties.Friction
        properties["CustomPhysicalProperties"]["FrictionWeight"] = basepart.CustomPhysicalProperties.FrictionWeight
    else
        properties["CustomPhysicalProperties"] = false
    end
    if debugmode == true then
        print(basepart.Name, "Properties were taken")
    end
    return properties
end
function saveinstance:Save(identity, basepart : BasePart)
    local properties = self:GetProperties(basepart)
    local data = DataStore:GetAsync(identity)
    if data == nil then
        local jsonData = nil
        local array = {}
        local success,err = pcall(function()
            jsonData = HttpService:JSONEncode(properties)
        end)
        if jsonData ~= nil then
            local succ,er = pcall(function()
                --Save basepart properties
                table.insert(array, jsonData)
                DataStore:SetAsync(identity, array)
            end)
            if succ then
                if debugmode == true then
                    print("Instance has been Saved")
                end
                return
            else
                --if get error
                warn("failed to instance saving")
                error(err)
            end
        end
    else
        --identity already on datastore
        warn("Identity already been saved, please choose another identity")
    end
end
function saveinstance:Get(identity)
    local data = DataStore:GetAsync(identity)
    if data ~= nil then
        local Decoded = nil 
        local success,err = pcall(function()
            --json to luau table
            Decoded = HttpService:JSONDecode(data)
        end)
        if success then
 
            local basepart = Instance.new("Part")
            basepart.Parent = game.Workspace
            for i,v in pairs(Decoded) do
                --if i variable is valid properties
                if basepart[tostring(i)] ~= nil then
                    if typeof(v) == "table" then
                        if i == "Color" then
                            v = Color3.new(v[1], v[2], v[3])
                        end
                        if i == "Position" then
                            v = Vector3.new(v[1], v[2], v[3]) 
                        end
                        if i == "Velocity" then
                            v = Vector3.new(v[1], v[2], v[3])
                        end
                        if i == "Size" then
                            v = Vector3.new(v[1], v[2], v[3])
                        end
                        if i == "Orientation" then
                            v = Vector3.new(v[1], v[2], v[3])
                        end
                    end
                    if i == "Material" then
                        v = Enum.Material[v]
                    end
                    if i:match("Surface") then
                        v = Enum.SurfaceType[v]
                    end
                    if i == "Shape" then
                        v = Enum.PartType[v]
                    end
                    if i == "CustomPhysicalProperties" then
                        if v ~= false or v ~= nil then
                            basepart["CustomPhysicalProperties"]["Density"] = v["Density"]
                            basepart["CustomPhysicalProperties"]["Elasticity"] = v["Elasticity"]
                            basepart["CustomPhysicalProperties"]["ElasticityWeight"] = v["ElasticityWeight"]
                            basepart["CustomPhysicalProperties"]["Friction"] = v["Friction"]
                            basepart["CustomPhysicalProperties"]["FrictionWeight"] = v["FrictionWeight"]
                        end
                    end
                    basepart[i] = v
                end
            end
            if debugmode == true then
                print("The part has been placed")
            end
        else
            error("Failed to convert Data To Table.")
        end
    else
        error("Failed to find instance.")
    end
end
function saveinstance:Remove(identity)
    local data = DataStore:GetAsync(identity)
    --if data is not nil
    if data ~= nil then
        --remove identity from data store
        DataStore:RemoveAsync(identity)
        if debugmode == true then
            print(identity.." was removed.")
        end
    else
        --if identity is not found
        warn("Failed to find identity.")
    end
end
function saveinstance:BulkSave(childrens, identity) 
    local array = {}
    -- if childrens type is table
    if typeof(childrens) == "table" then
        local data = DataStore:GetAsync(identity)
        --if data is not nil
        if data == nil then
            for i,v in pairs(childrens) do
                -- loop for saving parts
                if v:IsA("BasePart") then
                    --get part properties (anchored vs.)
                    local properties = self:GetProperties(v)
                    --luau table to json
                    properties = HttpService:JSONEncode(properties)
                    --add to array part properties
                    table.insert(array, properties)
                end
            end
            if #array > 0 then
                --if array length is not zero
                DataStore:SetAsync(identity,  array)
                --save part properties to datastore
            end
 
        else
            --if identity already been saved.
            error("Identity already been saved please choose another identity")
        end
    end
end
function saveinstance:BulkDelete(identity)
    local data = DataStore:GetAsync(identity)
    if data ~= nil then
        -- Deletes part properties from datastore
        DataStore:RemoveAsync(identity)
        if debugmode == true then
            print(identity.." Removed Successfully")
        end
    end
end
function saveinstance:BulkGet(identity)
    local data = DataStore:GetAsync(identity)
    if data ~= nil then
        if #data > 0 then
            for i,v in pairs(data) do
                v = HttpService:JSONDecode(v)
                --reason of this was because i using a different datatype.
                local basepart = Instance.new("Part")
                basepart.Parent = game.Workspace
                for i,v in pairs(v) do
                    --if i variable is valid properties
                    if basepart[tostring(i)] ~= nil then
                        --if childrens type is table
                        if typeof(v) == "table" then
                            if i == "Color" then
                                v = Color3.new(v[1], v[2], v[3])
                            end
                            if i == "Position" then
                                v = Vector3.new(v[1], v[2], v[3]) 
                            end
                            if i == "Velocity" then
                                v = Vector3.new(v[1], v[2], v[3])
                            end
                            if i == "Size" then
                                v = Vector3.new(v[1], v[2], v[3])
                            end
                            if i == "Orientation" then
                                v = Vector3.new(v[1], v[2], v[3])
                            end
                        end
                        if i == "Material" then
                            v = Enum.Material[v]
                        end
                        --if property name include Surface 
                        if i:match("Surface") then
                            v = Enum.SurfaceType[v]
                        end
                        if i == "Shape" then
                            v = Enum.PartType[v]
                        end
                        if i == "CustomPhysicalProperties" then
                            --if custom physical properties is on 
                            if v ~= false or v ~= nil then
                                --physical properties
                                basepart["CustomPhysicalProperties"]["Density"] = v["Density"]
                                basepart["CustomPhysicalProperties"]["Elasticity"] = v["Elasticity"]
                                basepart["CustomPhysicalProperties"]["ElasticityWeight"] = v["ElasticityWeight"]
                                basepart["CustomPhysicalProperties"]["Friction"] = v["Friction"]
                                basepart["CustomPhysicalProperties"]["FrictionWeight"] = v["FrictionWeight"]
                            end
                        end
                        basepart[i] = v
                    end
                end
                if debugmode == true then
                    print("The part has been placed from bulkget")
                end
            end
        end
    end
end
return saveinstance
