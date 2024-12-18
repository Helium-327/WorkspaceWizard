@echo off
setlocal enabledelayedexpansion
title Workspace Manager
color 0a

:: 加载配置文件
call config.bat

:: 检查必要的环境变量
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
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::         Workspace Manager          ::
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo "当前环境变量:"
    echo WORKSPACE_ROOT_PATH:  %WORKSPACE_ROOT_PATH%
    echo PROJECT_ROOT_PATH:    %PROJECT_ROOT_PATH%
    echo LOG_FILE:             %LOG_FILE%
    echo ========================================
    echo "c. Create Workspace"
    echo "r. Run Workspace"
    echo "d. Delete Workspace"
    echo "l. List Workspaces"
    echo "s. Set Config"
    echo "q. Quit"
    echo ========================================
    set /p choice="Please select an option (c/r/d/l/s/q): "

    if /i "%choice%"=="c" goto createWorkspace
    if /i "%choice%"=="r" goto runWorkspace
    if /i "%choice%"=="d" goto deleteWorkspace
    if /i "%choice%"=="l" goto listWorkspaces
    if /i "%choice%"=="s" goto setConfig
    if /i "%choice%"=="q" goto eof

    echo Invalid choice. Please try again.
    pause
    goto mainMenu

:: 设置config文件中的内容
:setConfig
    cls
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::             Set Config             ::
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo "1. Manually set configuration"
    echo "d. Restore default configuration"
    echo "q. Quit"
    echo ================================
    set /p choice="Please choose an option: "

    if "%choice%"=="1" goto updateConfig
    if "%choice%"=="d" goto restoreDefaultConfig
    if "%choice%"=="q" goto mainMenu

    echo Invalid choice. Please try again.
    pause
    goto setConfig

:updateConfig
    set /p WORKSPACE_ROOT_PATH="Enter workspace root path: "
    set /p PROJECT_ROOT_PATH="Enter project root path: "
    set /p LOG_FILE="Enter log file path: "

    (
        echo set WORKSPACE_ROOT_PATH=%WORKSPACE_ROOT_PATH%
        echo set PROJECT_ROOT_PATH=%PROJECT_ROOT_PATH%
        echo set LOG_FILE=%LOG_FILE%
    ) > config.bat

    echo Configuration file has been updated.
    pause
    goto mainMenu

:restoreDefaultConfig
    call default.config.bat
    (
        echo set WORKSPACE_ROOT_PATH=%WORKSPACE_ROOT_PATH%
        echo set PROJECT_ROOT_PATH=%PROJECT_ROOT_PATH%
        echo set LOG_FILE=%LOG_FILE%
    ) > config.bat

    echo Configuration file has been restored to default.
    pause
    goto mainMenu

:: 创建工作空间
:createWorkspace
    cls
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::         Create Workspace           ::
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ================================
    echo "1. Windows"
    echo "2. Ubuntu"
    echo "q. Back to Main Menu"
    echo ================================
    set /p platform="Please select platform (1/2/q): "

    if "%platform%"=="1" goto createWindowsWorkspace
    if "%platform%"=="2" goto createUbuntuWorkspace
    if "%platform%"=="q" goto mainMenu

    echo Invalid choice. Please try again.
    pause
    goto createWorkspace

:createWindowsWorkspace
    set /p inputName="Please enter the workspace name: "
    call :createWorkspaceHelper %inputName% WS-
    goto mainMenu

:createUbuntuWorkspace
    set /p inputName="Please enter the workspace name: "
    call :createWorkspaceHelper %inputName% Wsl-
    goto mainMenu

:createWorkspaceHelper
    setlocal enabledelayedexpansion
    set inputName=%1
    set prefix=%2
    set WORKSPACE_NAME=!prefix!%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\!WORKSPACE_NAME!
    set FOLDER_PATH=%PROJECT_ROOT_PATH%\!prefix!%inputName%

    echo !WORKSPACES_PATH!
    if exist !WORKSPACES_PATH! (
        echo Workspace:!WORKSPACES_PATH! already exists.
        echo Starting workspace...
        start !WORKSPACES_PATH!
        pause
    ) else (
        mkdir !FOLDER_PATH!
        (
            echo {
            echo     "folders": [
            echo         {
            echo             "path": "!FOLDER_PATH!"
            echo         }
            echo     ],
            echo     "settings": {}
            echo }
        ) > !WORKSPACES_PATH!
        echo [%DATE% %TIME%] Created workspace: !WORKSPACE_NAME! >> "%LOG_FILE%"
        echo Workspace created.
        echo Starting workspace...
        echo !WORKSPACES_PATH!
        pause
        start !WORKSPACES_PATH!
    )
    endlocal
    exit /b 0

:: 运行工作空间
:runWorkspace
    cls
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::            Run Workspace           ::
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

    set WORKSPACE_NAME=%inputName%.code-workspace
    set WORKSPACES_PATH=%WORKSPACE_ROOT_PATH%\%WORKSPACE_NAME%

    if exist %WORKSPACES_PATH% (
        start %WORKSPACES_PATH%
    ) else (
        echo Workspace does not exist.
        echo Please create a new workspace.
        pause
    )
    goto mainMenu

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
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ::         List All Workspaces        ::
    echo ::::::::::::::::::::::::::::::::::::::::::
    echo ================================
    set count=0
    for %%i in (%WORKSPACE_ROOT_PATH%\*.code-workspace) do (
        set /a count+=1
        set name=%%~ni
        echo !count!. !name!
    )
    echo ================================
    pause
    goto mainMenu

:: 退出
:eof
endlocal
exit /b 0