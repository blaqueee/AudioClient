[Setup]
AppName=Система оповещений
AppVersion=1.0.0
DefaultDirName={pf}\AudioClient
DefaultGroupName=AudioClient
OutputDir=output
OutputBaseFilename=Установщик системы оповещений
Compression=lzma
SolidCompression=yes
DisableDirPage=yes
DisableProgramGroupPage=yes

[Files]
; Основной exe
Source: "C:\Coding\pet\AudioClient\build\windows\x64\runner\Release\audio_client.exe"; DestDir: "{app}"; Flags: ignoreversion

; Flutter runtime
Source: "C:\Coding\pet\AudioClient\build\windows\x64\runner\Release\flutter_windows.dll"; DestDir: "{app}"; Flags: ignoreversion

; Плагин just_audio
Source: "C:\Coding\pet\AudioClient\build\windows\x64\runner\Release\just_audio_windows_plugin.dll"; DestDir: "{app}"; Flags: ignoreversion

; Папка data (может содержать ICU, assets и другие нужные ресурсы)
Source: "C:\Coding\pet\AudioClient\build\windows\x64\runner\Release\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Audio Client"; Filename: "{app}\audio_client.exe"
Name: "{group}\Uninstall Audio Client"; Filename: "{uninstallexe}"

[Run]
Filename: "{app}\audio_client.exe"; Description: "Запустить Audio Client"; Flags: nowait postinstall skipifsilent
