function getJavaExe(bit32 : Boolean) : String;
var  
  tempStrings : TArrayOfString;
  i : integer;
begin
  setArrayLength(tempStrings, 3);
  Result := ''
  if bit32 then
	begin
		tempStrings[0] := ExpandConstant('{pf32}\Java\jre5\bin\java.exe')
		tempStrings[1] := ExpandConstant('{pf32}\Java\jre6\bin\java.exe')
		tempStrings[2] := ExpandConstant('{pf32}\Java\jre7\bin\java.exe')
	end
	else 
	begin
		tempStrings[0] := ExpandConstant('{pf64}\Java\jre5\bin\java.exe')
		tempStrings[1] := ExpandConstant('{pf64}\Java\jre6\bin\java.exe')
		tempStrings[2] := ExpandConstant('{pf64}\Java\jre7\bin\java.exe')
	end;
 

 for i := 0 to GetArrayLength(tempStrings)-1 do begin

 if FileExists( tempStrings[i]) then
  begin
    Result := tempStrings[i]
  end;

end;

end;



procedure CreateTrackingConfigFile(bit32 : Boolean; fileName : String);
var
  configFile : String;  
  configStrings : TArrayOfString;
  i : Integer;
  javaExePath : String;
begin
  setArrayLength(configStrings, 6);
  
  configFile := ExpandConstant('{app}\Trackman\bin\trackman.conf');

  DeleteFile( configFile );
	
 if bit32 then
	begin
	  configStrings[0] := 'UbitrackComponentDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin32\ubitrack' + #13 + #10;
	  configStrings[4] := 'UbitrackLibraryDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin32' + #13 + #10;
	  configStrings[2] := 'UbitrackWrapperDirectory='+ ExpandConstant('{app}') +'\UbiTrack\lib32' + #13 + #10;
	  configFile := ExpandConstant('{app}\Trackman\bin\trackman.conf.32');
  end
  else 
  begin
	  configStrings[0] := 'UbitrackComponentDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin\ubitrack' + #13 + #10;
	  configStrings[4] := 'UbitrackLibraryDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin' + #13 + #10;
	  configStrings[2] := 'UbitrackWrapperDirectory='+ ExpandConstant('{app}') +'\UbiTrack\lib' + #13 + #10;
	  configFile := ExpandConstant('{app}\Trackman\bin\trackman.conf.64');
  end;
  configStrings[1] := 'LastDirectory='+ ExpandConstant('{app}') + #13 + #10;  
  configStrings[3] := 'AutoCompletePatterns='+ ExpandConstant('{app}') + #13 + #10;  
  configStrings[5] := 'PatternTemplateDirectory='+ ExpandConstant('{app}') +'\UbiTrack\doc\utql' + #13 + #10;
  
  DeleteFile( configFile );
  SaveStringToFile(configFile, '#Config File Created by Setup'  + #13 + #10, True);
  
  for i := 0 to GetArrayLength(configStrings)-1 do begin
    StringChange(configStrings[i], '\', '\\')
    StringChange(configStrings[i], ':', '\:')
    SaveStringToFile(configFile, configStrings[i] , True);       
  end;
  

  
	DeleteFile( fileName);
  javaExePath := getJavaExe(bit32);
  if Length( javaExePath) = 0 then begin
    MsgBox('Can not find java', mbInformation, MB_OK);
  end else begin
  if bit32 then
	begin
		SaveStringToFile(fileName, 'set path='+ExpandConstant('{app}') +'\UbiTrack\bin32;%PATH%' + #13 + #10, True);
		SaveStringToFile(fileName, 'copy trackman.conf.32 trackman.conf' + #13 + #10, True);
	end
	else
	begin
		SaveStringToFile(fileName, 'set path='+ExpandConstant('{app}') +'\UbiTrack\bin;%PATH%' + #13 + #10, True);
		SaveStringToFile(fileName, 'copy trackman.conf.64 trackman.conf' + #13 + #10, True);
	end;
    SaveStringToFile(fileName, '"'+ javaExePath + '"' + ' ' + '-jar'+ ' ' + 'trackman.jar', True);
  end;

end;

