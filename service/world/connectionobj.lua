--import module

local global = require "global"
local skynet = require "skynet"
local interactive = require "base.interactive"
local net = require "base.net"

function NewConnection(...)
    local o = CConnection:New(...)
    return o
end

CConnection = {}
CConnection.__index = CConnection

function CConnection:New(mConn, pid)
    local o = setmetatable({}, self)

    o.m_iHandle = mConn.handle
    o.m_iGateAddr = mConn.gate
    o.m_sIP = mConn.ip
    o.m_iPort = mConn.port
    o.m_iOwnerPid = pid

    return o
end

function CConnection:Release()
end

function CConnection:FindPlayerAnyway()
    local oWorldMgr = global.oWorldMgr
    return oWorldMgr:FindPlayerAnywayByPid(self.m_iOwnerPid)
end

function CConnection:GetOwnerPid()
    return self.m_iOwnerPid
end

function CConnection:Send(sMessage, mData)
    net.Send({gate = self.m_iGateAddr, fd = self.m_iHandle}, sMessage, mData)
end

function CConnection:MailAddr()
    return {gate = self.m_iGateAddr, fd = self.m_iHandle}
end

function CConnection:Disconnected()
    local oPlayer = self:FindPlayerAnyway()
    if oPlayer then
        oPlayer:SetNetHandle(nil)
    end
end

function CConnection:Forward()
    local oPlayer = self:FindPlayerAnyway()
    if oPlayer then
        oPlayer:SetNetHandle(self.m_iHandle)
    end
    skynet.send(self.m_iGateAddr, "text", "forward", self.m_iHandle, skynet.address(MY_ADDR), skynet.address(self.m_iGateAddr))
end