@echo off
chcp 65001 > nul
title Git 1시간 자동 동기화 스크립트

:: 작업 디렉토리 이동
cd /d "%~dp0"
set LOG_FILE=git_auto_push.log

echo ===================================================
echo  Git 1시간 자동 동기화를 시작합니다.
echo  작업 경로: %CD%
echo  로그 파일: %LOG_FILE%
echo  이 창을 닫지 말고 최소화해 두세요.
echo ===================================================
echo.

:loop
cd /d "%~dp0"

:: 날짜/시간 변수 정규화
set CURRENT_DATE=%date:~0,10%
set CURRENT_TIME=%time:~0,8%
set TIMESTAMP=%CURRENT_DATE% %CURRENT_TIME%

echo [%TIMESTAMP%] [STEP 1/4] 원격 최신 변경사항 확인 (git pull)...
git pull origin main --no-rebase > nul 2>&1

echo [%TIMESTAMP%] [STEP 2/4] 변경 사항 확인 및 추가 (git add)...
git add .

:: 변경사항 존재 여부 점검
git diff-index --quiet HEAD --
if %errorlevel% equ 0 goto NO_CHANGES

echo [%TIMESTAMP%] [STEP 3/4] 로컬 커밋 및 원격 푸시 실행...
git commit -m "Auto sync: %TIMESTAMP%"
git push origin main --force
if errorlevel 1 (
    echo [%TIMESTAMP%] [ERROR] Push 실패! 다음 주기에 재시도합니다. >> "%LOG_FILE%"
    echo [WARN] Push에 실패했습니다. 다음 주기에 재시도합니다.
    goto SHOW_LOG
)
echo [%TIMESTAMP%] [SUCCESS] 정상적으로 Push 완료되었습니다.
goto SHOW_LOG

:NO_CHANGES
echo [%TIMESTAMP%] [STEP 3/4] 변경된 파일이 없어 커밋을 건너뜁니다.

:SHOW_LOG
echo.
echo [%TIMESTAMP%] [STEP 4/4] 최근 커밋 기록 확인...
git log -n 3 --oneline --graph --decorate
echo.

:: 로그 기록
echo [SYNC RUN] %TIMESTAMP% >> "%LOG_FILE%"
git log -1 --stat >> "%LOG_FILE%" 2>nul
echo --------------------------------------------------- >> "%LOG_FILE%"

echo.
echo [%TIMESTAMP%] 동기화 시도 완료. 1시간(3600초) 대기합니다...
echo ===================================================
echo.

timeout /t 3600 /nobreak > nul
goto loop