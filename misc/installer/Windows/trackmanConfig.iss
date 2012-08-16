function getJavaExe32() : String;
var
  temp : String;
  tempStrings : TArrayOfString;
  i : integer;
begin
  setArrayLength(tempStrings, 3);
  Result := ''
  tempStrings[0] := ExpandConstant('{pf32}\Java\jre5\bin\java.exe')
  tempStrings[1] := ExpandConstant('{pf32}\Java\jre6\bin\java.exe')
  tempStrings[2] := ExpandConstant('{pf32}\Java\jre7\bin\java.exe')
 

 for i := 0 to GetArrayLength(tempStrings)-1 do begin

 if FileExists( tempStrings[i]) then
  begin
    Result := tempStrings[i]
  end;

end;

end;


function getJavaExe() : String;
var
  temp : String;
  tempStrings : TArrayOfString;
  i : integer;
begin
  setArrayLength(tempStrings, 3);
  Result := ''
  tempStrings[0] := ExpandConstant('{pf64}\Java\jre5\bin\java.exe')
  tempStrings[1] := ExpandConstant('{pf64}\Java\jre6\bin\java.exe')
  tempStrings[2] := ExpandConstant('{pf64}\Java\jre7\bin\java.exe')
 

 for i := 0 to GetArrayLength(tempStrings)-1 do begin

 if FileExists( tempStrings[i]) then
  begin
    Result := tempStrings[i]
  end;

end;

end;



procedure CreateTrackingConfigFile(javaExe : String; fileName : String);
var
  configFile : String;
  batFile : String;
  configStrings : TArrayOfString;
  i : Integer;
  javaExePath : String;
begin
  setArrayLength(configStrings, 6);
  
  configFile := ExpandConstant('{app}\Trackman\bin\trackman.conf');

  DeleteFile( configFile );
	SaveStringToFile(configFile, '#Config File Created by Setup'  + #13 + #10, True);
 
  configStrings[0] := 'UbitrackComponentDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin\ubitrack' + #13 + #10;
  configStrings[1] := 'LastDirectory='+ ExpandConstant('{app}') + #13 + #10;
  configStrings[2] := 'UbitrackWrapperDirectory='+ ExpandConstant('{app}') +'\UbiTrack\lib' + #13 + #10;
  configStrings[3] := 'AutoCompletePatterns='+ ExpandConstant('{app}') + #13 + #10;
  configStrings[4] := 'UbitrackLibraryDirectory='+ ExpandConstant('{app}') +'\UbiTrack\bin' + #13 + #10;
  configStrings[5] := 'PatternTemplateDirectory='+ ExpandConstant('{app}') +'\UbiTrack\doc\utql' + #13 + #10;
  
  for i := 0 to GetArrayLength(configStrings)-1 do begin
    StringChange(configStrings[i], '\', '\\')
    StringChange(configStrings[i], ':', '\:')
    SaveStringToFile(configFile, configStrings[i] , True);       
  end;
  

  
	DeleteFile( fileName);
  
  if Length( javaExePath) > 0 then begin
    MsgBox('Can not find java', mbInformation, MB_OK);
  end else begin
    SaveStringToFile(fileName, '"'+ javaExe + '"' + ' ' + '-jar'+ ' ' + 'trackman.jar', True);
  end;

end;

