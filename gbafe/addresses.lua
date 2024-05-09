-- Any copyright is dedicated to the Public Domain.
-- https://creativecommons.org/publicdomain/zero/1.0/

-- Addresses of interesting objects

local a = {}

-- TODO: those are hardcoded for now to fe8_us addresses, handle other games

a.ProcArray = 0x02024E68
a.ProcTrees = 0x02026A70
a.StringBuf = 0x202A6AC
a.BmStatus = 0x0202BCB0
a.MapSize = 0x0202E4D4
a.MapUnit = 0x0202E4D8
a.MapTerrain = 0x0202E4DC

a.ActiveUnit = 0x03004E50

a.HuffTable = 0x0815A72C
a.HuffRoot = 0x0815D488
a.MessageTable = 0x0815D48C
a.UnitLookup = 0x0859A5D0
a.TerrainNameMsg = 0x0880D374
a.TalkStatus = 0x0859133C
a.TalkProc = 0x08591358
a.TalkWaitForInputProc = 0x085913F0
a.PInfoTable = 0x08803D64
a.IInfoTable = 0x08809B10
a.MenuProc = 0x085B64D0

return a