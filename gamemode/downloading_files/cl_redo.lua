redo_maxstored = CreateClientConVar("redo_maxstored", "30", true, true);
redo = redo or {};

cvars.AddChangeCallback("redo_maxstored", function(name, old, new)
  net.Start("redoLimit");
  net.WriteInt(tonumber(new), 16);
  net.SendToServer();
end);

function redo.Clear()
  net.Start("redoClear");
  net.SendToServer();
end;

function redo.Do_Redo()
  net.Start("redoRequest");
  net.SendToServer();
end;

concommand.Add("redo_clearhistory", redo.Clear);

concommand.Add("redo", redo.Do_Redo);
