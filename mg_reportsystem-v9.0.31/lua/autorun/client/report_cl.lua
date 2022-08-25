surface.CreateFont("vReport",{
	font = "DermaLarge",
	size = 25
})

local a

local funny_sayings = { 
	"Nonay Admin Panel"
}

local function makeadmin(reports)
	a = vgui.Create("DFrame")
	a:SetSize(750,450)
	a:MakePopup()
	a:Center()
	a:SetTitle(funny_sayings[math.random(#funny_sayings)])
	a.btnClose:SetVisible(true)
	function a.btnClose:Paint(w, h) 
		draw.SimpleText("X", "DermaDefault", w * .75 + 1, h * .35, Color(235,235,235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
    a.btnMaxim:SetVisible(false)
    a.btnMinim:SetVisible(false)
		
	function a:Paint(w, h)
		draw.RoundedBox(2, 0, 0, w, h, Color(185, 46, 46))
	end
	
	function a:Close()
		self:Remove()
		timer.Simple(0,function() a = nil end)
	end
	
	local l = vgui.Create("DListView",a)
	l:SetSize(400,300)
	l:Dock(LEFT)
	l:AddColumn("Reports")
	l:AddColumn("Issue")
	l:AddColumn("Claimed")

	for k,v in pairs(reports) do
		local cl = "<Nobody>"
		if v.claimed then
			cl = v.claimed:Nick()
		end
		local a = l:AddLine(v.nick, v.data, cl)
		a.id = k
	end

	local data = vgui.Create("DTextEntry",a)
	data:SetSize(200,200)
	data:Dock(BOTTOM)
	data:SetEditable(false)
	data:SetMultiline(true)
	data:SetText("The info of the report you choose will show up here!\nYou can start by selecting one!")

	local details = vgui.Create("DTextEntry",a)
	details:Dock(FILL)
	details:AllowInput(false)
	details:SetEditable(false)
	details:SetMultiline(true)
	details:SetText("The details of the report will show up here!\nJust select one from the left side!")

	function l:OnRowSelected( _, p )
		local i = p.id
		local report = reports[i]
		local n = "<Nobody>"
		if report.claimed then
			n = report.claimed:Nick() .. " (" .. report.claimed:SteamID() .. ")"
		end
		details:SetText("The details of the selected report:\n\nReported by: " .. report.nick .. " (" .. report.steamid ..")\n\nTime of report: " .. report.time .."\n\nClaimed by: " .. (n))
		data:SetText(report.data)
		local rc = DermaMenu()
		rc:AddOption("View",function() rc:Remove() end):SetIcon("icon16/find.png")
		rc:AddSpacer()
		if report.claimed ~= LocalPlayer() then
			rc:AddOption("Claim",function() if report.claimed then return end net.Start("vAReportMenu") net.WriteString("claim") net.WriteInt(i,32) net.SendToServer() end):SetIcon("icon16/add.png")
		end
		rc:AddOption("Goto",function() RunConsoleCommand("ulx","goto",report.nick) end):SetIcon("icon16/wand.png")
		rc:AddOption("Bring",function() RunConsoleCommand("ulx","bring",report.nick) end):SetIcon("icon16/wand.png")
		rc:AddOption("Freeze",function() RunConsoleCommand("ulx","Freeze",report.nick) end):SetIcon("icon16/wand.png")
		if report.claimed == LocalPlayer() then
			rc:AddOption("Finish",function() net.Start("vAReportMenu") net.WriteString("finish") net.WriteInt(i,32) net.SendToServer() end):SetIcon("icon16/accept.png")
		else
			rc:AddOption("Delete",function() if report.claimed then return end net.Start("vAReportMenu") net.WriteString("delete") net.WriteInt(i,32) net.SendToServer() end):SetIcon("icon16/cross.png")
		end
		rc:Open()
	end
end

net.Receive("vAReportMenu",function()
	local reports = net.ReadTable()
	makeadmin(reports)
end)

net.Receive("vAUpdate",function()
	if ispanel(a) then
		a:Remove()
		makeadmin(net.ReadTable())
	end
end)