@echo off
chcp 65001 > nul
title Git 1시간 자동 동기화 스크립트

echo [STEP 1/5] 작업 디렉토리로 이동...
cd /d "%~dp0"
echo 현재 위치: %CD%
echo.

echo [STEP 2/5] Git 저장소 확인...
git status
echo.

set LOG_FILE=git_auto_push.log

echo ===================================================
echo  Git 1시간 자동 동기화를 시작합니다.
echo  로그 파일: %LOG_FILE%
echo  이 창을 닫지 말고 최소화해 두세요.
echo ===================================================
echo.

:loop
cd /d "%~dp0"

echo [%date% %time%] [STEP 3/5] 변경 사항 추가 (git add)...
git add .
echo.

echo [%date% %time%] [STEP 4/5] 커밋 및 푸시 실행...
git commit -m "Auto sync: %date% %time%"
git push origin main
echo.

echo [%date% %time%] [STEP 5/5] 최근 커밋 기록 및 로그 작성...
git log -n 3 --oneline --graph --decorate
echo.

echo [SYNC RUN] %date% %time% >> "%LOG_FILE%"
git log -1 --stat >> "%LOG_FILE%" 2>nul
echo --------------------------------------------------- >> "%LOG_FILE%"

echo.
echo [%date% %time%] 동기화 시도 완료. 1시간(3600초) 대기합니다...
echo ===================================================
echo.

timeout /t 3600 /nobreak > nul

goto loop