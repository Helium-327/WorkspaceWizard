@echo off
setlocal enabledelayedexpansion

:: 定义变量
set "cmd=cmd.exe"
set "path=%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;C:\Windows\System32\Windowspowershell\v1.0;C:\Windows\System32\OpenSSH;"
:: 通常不建议将当前目录添加到系统PATH，因为它可能会导致不可预见的行为
:: set "path=%path%.;"

:: 定义函数
:createOrRunWorkspace
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::      Let's Create your Workspace   ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ========================================
    echo "1. Create or Run Workspace"
    echo "2. Delete Workspace and Files"
    echo "q. Exit"
    echo ========================================
    set /p choice="Please select an option (1/2/q): "

    if "!choice!"=="1" (
        call :newWorkspace
    ) else if "!choice!"=="2" (
        call :deleteWorkspace
    ) else if "!choice!"=="q" (
        goto :eof
    ) else (
        echo Invalid option, please choose again.
        pause >nul
        goto :createOrRunWorkspace
    )
    goto :eof

:newWorkspace
    setlocal enabledelayedexpansion
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::      Let's Create your Workspace   ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo Create Workspace
    echo ================================

    echo "1. windows"
    echo "2. ubuntu2204"
    set /p platform="Please select platform: "
    set /p inputName="Please enter the workspace name you wanna create: "

    set "onedrivePath=G:\\OneDrive\\VScodeWorkSpaces"
    set "workSpaceName=%inputName%.code-workspace"
    set "workspacesPath=%onedrivePath%\\%workSpaceName%"
    set "folderPath=D:\\AI_Research\\WS-Hub\\WS-%inputName%"
    echo workspace on: !workspacesPath!
    pause

    if not exist "%workspacesPath%" (
        if "%platform%"=="1" (
            mkdir "%folderPath%"
            echo !folderPath!
            pause
            (
                echo {
                echo     "folders": [
                echo         {
                echo             "path": "!folderPath!"
                echo         }
                echo     ],
                echo     "settings": {}
                echo }
            ) > "%workspacesPath%"
            echo Workspace on Windows config file created.
            pause
            cmd /c "start %workspacesPath%"

        ) else if "%platform%"=="2" (
            set "folderPath=/mnt/d/AI_Research/WS-Hub/WS-wsl-%inputName%"
            set "uri=vscode-remote://wsl+ubuntu2204!folderPath!"
            echo URI: !uri!
            echo Folder: !folderPath!
            pause
            mkdir "%folderPath%"
            (
                echo {
                echo     "folders": [
                echo         {
                echo             "uri": "vscode-remote://wsl+ubuntu2204/mnt/d/AI_Research/WS-Hub/WS-!inputName!"
                echo         }
                echo     ],
                echo     "remoteAuthority": "wsl+Ubuntu2204",
                echo     "settings": {}
                echo }
            ) > "%workspacesPath%"
            echo "vscode-remote://wsl+ubuntu2204!folderPath!"
            echo Workspace on Ubuntu config file created.
            pause
            :: 注意：在WSL中直接打开VS Code需要特定的命令或脚本
            :: 这里只是假设性的命令，实际可能需要根据您的环境调整
            cmd /c "start %workspacesPath%"

        ) else (
            echo Invalid platform input.
            pause
            goto :newWorkspace
        )
    ) else (
        echo Workspace !workSpaceName! already exists.
        echo Opening the workspace...
        cmd /c "start %workspacesPath%"
    )
    endlocal
    goto :eof

:deleteWorkspace
    rem Define local variables and enable delayed expansion
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::      Let's Create your Workspace   ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo Delete Workspace
    echo ================================
    rem Read user input for workspace name
    set /p inputName="Please enter the workspace name you wanna delete: "

    set "onedrivePath=G:\\OneDrive\\VScodeWorkSpaces"
    set "folderPath=G:\\WS-Hub\\WS-%inputName%"
    set "workSpaceName=%inputName%.code-workspace"
    set "workspacesPath=%onedrivePath%\%workSpaceName%"

    rem Check if a workspace with the same name exists
    rem If it doesn't, prompt the user that no such workspace exists
    if not exist "%workspacesPath%" (
        echo No such workspace exists.
        pause >nul
    ) else (
        del /f "G:\\OneDrive\VScodeWorkSpaces\\%inputName%.code-workspace"
        rd /s %folderPath%
    )
    rem Delete the specified workspace directory
    goto :createOrRunWorkspace

endlocal