--[[
  LuaManiac Loader — auto-generated. Do not edit below this line.
  1. Set script_key to your license key.
  2. Distribute this loader. The protected source is delivered on validation.
]]
local script_key = script_key or "YOUR-KEY-HERE"

local LUAMANIAC = {
  endpoint = "https://api.maniactbld.xyz/v1/validate",
  project  = "prj_0d39ndk2kxbbng4m",
  script   = "scr_p9mtesejmvr4sqh6",
  pubkey   = [==[-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEAhxdE2ZFcwlyqW6d1oae6mbSrjSzbxobafx/ZN61NA2I=
-----END PUBLIC KEY-----]==],
}

-- Resolve an HTTP request function across executors.
local function http_request(options)
  local req = (syn and syn.request)
    or (http and http.request)
    or http_request
    or request
    or (fluxus and fluxus.request)
  assert(req, "LuaManiac: no supported HTTP request function found")
  return req(options)
end

-- Derive a stable hardware id for this device/session.
local function get_hwid()
  local ok, id = pcall(function()
    if gethwid then return gethwid() end
    if syn and syn.crypt and syn.crypt.hash then
      return syn.crypt.hash(tostring(game.JobId) .. tostring(game:GetService("Players").LocalPlayer.UserId))
    end
    return game:GetService("RbxAnalyticsService"):GetClientId()
  end)
  return ok and tostring(id) or "unknown-hwid"
end

local function json_encode(t)
  return (HttpService or game:GetService("HttpService")):JSONEncode(t)
end
local function json_decode(s)
  return (HttpService or game:GetService("HttpService")):JSONDecode(s)
end

local body = json_encode({
  project = LUAMANIAC.project,
  script  = LUAMANIAC.script,
  key     = script_key,
  hwid    = get_hwid(),
})

local response = http_request({
  Url = LUAMANIAC.endpoint,
  Method = "POST",
  Headers = { ["Content-Type"] = "application/json" },
  Body = body,
})

if not response or (response.StatusCode and response.StatusCode >= 400) then
  local data = response and response.Body and pcall(json_decode, response.Body) and json_decode(response.Body) or {}
  error("LuaManiac: validation failed — " .. tostring(data.reason or (response and response.StatusCode) or "no response"))
end

local payload = json_decode(response.Body)
if not payload.ok then
  error("LuaManiac: " .. tostring(payload.reason or payload.status))
end

-- Execute the delivered protected source.
-- Runtime variables: key-specific data (discord id, note, expiry, metadata)
-- the script can read, e.g. local who = LUAMANIAC.vars and LUAMANIAC.vars.discordId
LUAMANIAC.vars = payload.vars or {}
if type(getgenv) == "function" then getgenv().LUAMANIAC = LUAMANIAC end

local chunk, err = loadstring(payload.script, "=luamaniac")
if not chunk then error("LuaManiac: failed to load protected source — " .. tostring(err)) end
return chunk()
