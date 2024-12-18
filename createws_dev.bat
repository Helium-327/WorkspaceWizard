@echo off
setlocal
title Workspace Manager
color 0a
:: Gomez groom dev 2023-11-21
:: Batch script for workspace management

:: 初始化变量
set "cmd=cmd.exe"


::加载配置文件
call config.bat

if not defined WORKSPACE_ROOT_PATH (
    echo Error: WORKSPACE_ROOT_PATH not defined.
    exit /b 1
)

if not defined PROJECT_ROOT_PATH (
    echo Error: PROJECT_ROOT_PATH not defined.
    exit /b 1
)

if not defined LOG_FILE (
    echo Error: LOG_FILE not defined.
    exit /b 1
)

:: 主菜单
:mainMenu
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::         Workspace Manager          ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo "当前环境变量:"
    echo WORKSPACE_ROOT_PATH:  %WORKSPACE_ROOT_PATH%
    echo PROJECT_ROOT_PATH:    %PROJECT_ROOT_PATH%
    echo LOG_FILE:             %LOG_FILE%
    echo remoteAuthority:      %remoteAuthority%
    echo ========================================
    echo "c. Create Workspace"
    echo "r. Run Workspace"
    echo "d. Delete Workspace"
    echo "l. List Workspaces"
    echo "s. Set Config"
    echo "q. Quit"
    echo ========================================
    set /p choice="Please select an option (c/r/d/l/s/q): "

    if "%choice%"=="c" goto :createWorkspace
    if "%choice%"=="r" goto :runWorkspace
    if "%choice%"=="d" goto :deleteWorkspace
    if "%choice%"=="l" goto :listWorkspaces
    if "%choice%"=="s" goto :setConfig
    if "%choice%"=="q" goto :eof

:: 设置config文件中的内容
:setConfig
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::             Set Config             ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo "1. 手动配置"
    echo "d. 一键恢复默认配置"
    echo "q. 退出"
    echo ================================
    set /p choice="请选择："

    if "%choice%"=="1" (
        set /p WORKSPACE_ROOT_PATH="请输入工作空间根目录路径："
        set /p PROJECT_ROOT_PATH="请输入项目根目录路径："
        set /p LOG_FILE="请输入日志文件路径："

        (
            echo set WORKSPACE_ROOT_PATH=%WORKSPACE_ROOT_PATH%
            echo set PROJECT_ROOT_PATH=%PROJECT_ROOT_PATH%
            echo set LOG_FILE=%LOG_FILE%
        ) > config.bat

        echo 配置文件已更新。
        pause
        goto :mainMenu
    )

    if "%choice%"=="d" (
        call default.config.bat
        (
            echo set WORKSPACE_ROOT_PATH=%WORKSPACE_ROOT_PATH%
            echo set PROJECT_ROOT_PATH=%PROJECT_ROOT_PATH%
            echo set LOG_FILE=%LOG_FILE%
        ) > config.bat

        echo 配置文件已恢复到默认值。
        pause
        goto :mainMenu
    )

    if "%choice%"=="q" (
        goto :mainMenu
    )

:: 创建工作空间
:createWorkspace
    setlocal enabledelayedexpansion
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::         Create Workspace           ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo "1. Windows"
    echo "2. Ubuntu"
    echo "q. Back to Main Menu"
    echo ================================
    set /p platform="Please select platform (1/2/q): "

    if "%platform%"=="1" goto :createWindowsWorkspace
    if "%platform%"=="2" goto :createUbuntuWorkspace
    if "%platform%"=="q" goto :mainMenu
    goto :createWorkspace

:createWindowsWorkspace
    setlocal enabledelayedexpansion
    set /p inputName="Please enter the workspace name: "
    set WORKSPACE_NAME=%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\\%WORKSPACE_NAME%
    set FOLDER_PATH=%PROJECT_ROOT_PATH%\\WS-%inputName%

    if exist %WORKSPACES_PATH% (
        echo Workspace:%WORKSPACES_PATH% already exists. 
        echo Starting workspace...
        cmd /c start %WORKSPACES_PATH%
        pause
    ) else (
        mkdir %FOLDER_PATH%
        echo %FOLDER_PATH%
        (
            echo {
            echo     "folders": [
            echo         {
            echo             "path": "!FOLDER_PATH!"
            echo         }
            echo     ],
            echo     "settings": {}
            echo }
        ) > %WORKSPACES_PATH%
        echo [%DATE% %TIME%] 创建工作空间：%WORKSPACE_NAME% >> "%LOG_FILE%"
        echo Workspace created.
        echo Starting workspace...
        echo %WORKSPACES_PATH%
        pause
        cmd /c start %WORKSPACES_PATH%
    )
    goto :mainMenu

:createUbuntuWorkspace
    setLOCAL enabledelayedexpansion
    set /p inputName="Please enter the workspace name: "
    set WORKSPACE_NAME=%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\\%WORKSPACE_NAME%
    set FOLDER_PATH=%PROJECT_ROOT_PATH%\\Wsl-%inputName%

    if not exist %WORKSPACES_PATH% (
        mkdir %FOLDER_PATH%
        (
            echo {
            echo     "folders": [
            echo         {
            echo             "uri": "vscode-remote://%remoteAuthority%/mnt/d/AI_Research/WS-Hub/Wsl-%inputName%"
            echo         }
            echo     ],
            echo     "remoteAuthority": "%remoteAuthority%",
            echo     "settings": {}
            echo }
        ) > %WORKSPACES_PATH%
        echo [%DATE% %TIME%] 创建工作空间：%WORKSPACE_NAME% >> "%LOG_FILE%"
        echo Workspace created.
        echo Starting workspace...
        cmd /c start %WORKSPACES_PATH%
        pause
    ) else (
        echo Workspace already exists.
        echo Please try to run the workspace.
        pause
    )
    goto :mainMenu
endlocal
exit /b 0

:: 运行工作空间
:runWorkspace
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::            Run Workspace           ::
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ================================
    setLOCAL enabledelayedexpansion
    echo "当前工作空间:"
    set count=0
    for %%i in (%WORKSPACE_ROOT_PATH%\\*.code-workspace) do (
        set /a count+=1
        set name=%%~ni
        echo !count!. !name!
    )
    echo ================================
    set /p inputName="Please enter the workspace name (or q to back): "

    if "%inputName%"=="q" goto :mainMenu

    set WORKSPACE_NAME=%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\\%WORKSPACE_NAME%

    if exist %WORKSPACES_PATH% (
        cmd /c start %WORKSPACES_PATH%
	goto :runWorkspace
    ) else (
        echo Workspace does not exist.
        echo Please create a new workspace.
        pause
    )
    goto :runWorkspace
    exit /b 0

:: 删除工作空间
:deleteWorkspace
    cls
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::            Delete Workspace        ::
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo Current workspaces:
    set count=0
    for %%i in (%WORKSPACE_ROOT_PATH%\*.code-workspace) do (
        set /a count+=1
        set name=%%~ni
        echo !count!. !name!
    )
    echo ================================
    set /p inputName="Please enter the workspace name (or q to back): "

    if "%inputName%"=="q" goto mainMenu

    set FOLDER_PATH=%PROJECT_ROOT_PATH%\WS-%inputName%
    set WORKSPACE_NAME=%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\%WORKSPACE_NAME%

    echo FOLDER_PATH:       %FOLDER_PATH%
    echo WORKSPACE_NAME:    %WORKSPACE_NAME%
    echo WORKSPACES_PATH:   %WORKSPACES_PATH%

    if exist %WORKSPACES_PATH% (
        echo %WORKSPACES_PATH% exists.
        del /f "%WORKSPACES_PATH%"
        echo [%DATE% %TIME%] Deleted workspace: %WORKSPACE_NAME% >> %LOG_FILE%
        echo Workspace deleted.
        pause
    ) else (
        echo %WORKSPACES_PATH% does not exist.
        pause
    )

    if exist %FOLDER_PATH% (
        rd /s /q "%FOLDER_PATH%"
        echo [%DATE% %TIME%] Deleted project directory: %FOLDER_PATH% >> %LOG_FILE%
        echo Project deleted.
        pause
    ) else (
        echo %FOLDER_PATH% does not exist.
        pause
    )
    goto mainMenu

:: 列出工作空间
:listWorkspaces
    cls
    echo ::::::::::::::::::::::::::::::::::::::::
    echo ::         List All Workspaces        ::
    echo ::::::::::::::::::::::::::::::::::::::::
    setLOCAL enabledelayedexpansion
    set count=0
    for %%i in (%WORKSPACE_ROOT_PATH%\\*.code-workspace) do (
        set /a count+=1
        set name=%%~ni
        echo !count!. !name!
    )
    echo ================================
    pause
    goto :mainMenu
    exit /b 0

:: 退出
:eof
exit /b 0
