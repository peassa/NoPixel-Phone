local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}


--- action functions
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil


--- esx
local GUI = {}
ESX                           = nil
GUI.Time                      = 0
local PlayerData              = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
    PlayerData = ESX.GetPlayerData()
  end

  while PlayerData == nil do
    PlayerData = ESX.GetPlayerData()
    Citizen.Wait(0)
  end
end)

RegisterNetEvent('setduty:getPlayer')
AddEventHandler('setduty:getPlayer', function()
  PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('es:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

----markers
AddEventHandler('esx_duty:hasEnteredMarker', function (zone)
  if zone ~= nil then
    CurrentAction     = 'onoff'
    CurrentActionMsg = _U('duty')
  end
end)

AddEventHandler('esx_duty:hasExitedMarker', function (zone)
  CurrentAction = nil
end)


--keycontrols
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(1)

        local playerPed = GetPlayerPed(-1)
        
        local jobs = {
            'offambulance',
            'offpolice',
            'police',
            'ambulance',
            'mechanic',
            'offmechanic'
        }

        if CurrentAction ~= nil then
            for k,v in pairs(jobs) do
              if PlayerData.job ~= nil then
                  if PlayerData.job.name == v then
                      --[[ SetTextComponentFormat('STRING')
                      AddTextComponentString(CurrentActionMsg)
                      DisplayHelpTextFromStringLabel(0, 0, 1, -1) ]]

                      if IsControlJustPressed(0, Keys['E']) then
                          TriggerServerEvent('duty:onoff')
                      end
                  end
                end
            end

        end

    end       
end)

-- Display markers
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)

    local coords = GetEntityCoords(GetPlayerPed(-1))

      for k,v in pairs(Config.Zones) do
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
          if PlayerData.job == nil then
            TriggerEvent('setduty:getPlayer')
          elseif PlayerData.job.name == 'police' or PlayerData.job.name == 'ambulance' or PlayerData.job.name == 'mechanic' then
            local lolwhat, groundz = GetGroundZFor_3dCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            Draw3DText(v.Pos.x, v.Pos.y, v.Pos.z+0.8, "Press [E] to go off duty!")
            DrawMarker(v.Type, v.Pos.x, v.Pos.y, groundz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.ColorOn.r, v.ColorOn.g, v.ColorOn.b, 100, false, true, 2, false, false, false, false)
          elseif PlayerData.job.name == 'offpolice' or PlayerData.job.name == 'offambulance' or PlayerData.job.name == 'offmechanic' then
            local lolwhat, groundz = GetGroundZFor_3dCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            Draw3DText(v.Pos.x, v.Pos.y, v.Pos.z+0.8, "Press [E] to go on duty!")
            DrawMarker(v.Type, v.Pos.x, v.Pos.y, groundz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.ColorOff.r, v.ColorOff.g, v.ColorOff.b, 100, false, true, 2, false, false, false, false)
          end
        end
      end
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
  while true do
    Citizen.Wait(0)

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
        isInMarker  = true
        currentZone = k
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_duty:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_duty:hasExitedMarker', LastZone)
    end
  end
end)

function Draw3DText(x,y,z, text)
  local onScreen,_x,_y=World3dToScreen2d(x,y,z)
  local px,py,pz=table.unpack(GetGameplayCamCoords())
  
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x,_y)
  local factor = (string.len(text)) / 370
  DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end