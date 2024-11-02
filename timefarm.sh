#!/bin/bash

# 환경 변수 설정
export WORK="/root/TimeFarmBot"
export NVM_DIR="$HOME/.nvm"

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # 색상 초기화

echo -e "${GREEN}Timefarm 봇을 설치합니다.${NC}"
echo -e "${GREEN}스크립트작성자: https://t.me/kjkresearch${NC}"
echo -e "${GREEN}출처: https://github.com/Freddywhest/TimeFarmBot${NC}"

echo -e "${GREEN}설치 옵션을 선택하세요:${NC}"
echo -e "${YELLOW}1. Timefarm 봇 새로 설치${NC}"
echo -e "${YELLOW}2. 재실행하기${NC}"
read -p "선택: " choice

case $choice in
  1)
    echo -e "${GREEN}Timefarm 봇을 새로 설치합니다.${NC}"

    # 사전 필수 패키지 설치
    echo -e "${YELLOW}시스템 업데이트 및 필수 패키지 설치 중...${NC}"
    sudo apt update
    sudo apt install -y git

    echo -e "${YELLOW}작업 공간 준비 중...${NC}"
    if [ -d "$WORK" ]; then
        echo -e "${YELLOW}기존 작업 공간 삭제 중...${NC}"
        rm -rf "$WORK"
    fi

    # GitHub에서 코드 복사
    echo -e "${YELLOW}GitHub에서 코드 복사 중...${NC}"
    git clone https://github.com/Freddywhest/TimeFarmBot.git
    cd "$WORK"

    # Node.js 20 버전 설치 및 사용
    echo -e "${YELLOW}Node.js LTS 버전을 설치하고 설정 중...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    nvm install 20 # 20.x 버전 설치
    nvm use 20     # 20.x 버전 사용
    npm install

    echo -e "${YELLOW}Web텔레그렘에 접속후 F12를 누르시고 게임을 실행하세요${NC}"
    read -p "애플리케이션-세션저장소-timefarm과 관련된 URL클릭 후 나오는 UserID나 QueryID를 적어두세요 (엔터) : "
    echo -e "${GREEN}다계정의 query_id를 입력할 경우 줄바꿈으로 구분하세요.${NC}"
    echo -e "${GREEN}입력을 마치려면 엔터를 두 번 누르세요.${NC}"
    echo -e "${YELLOW}Userid를 입력하세요(user= 또는 query_id= 포함해서 입력):${NC}"

   # 쿼리 파일 생성 및 초기화
  {
      echo "{"  # JSON 객체 시작
      while IFS= read -r line; do
          [[ -z "$line" ]] && break
          echo "  \"$line\": \"$line\","  # 각 줄을 키-값 쌍으로 변환
      done | sed '$ s/,$//'  # 마지막 줄의 쉼표 제거
      echo "}"  # JSON 객체 끝
  } > "$WORK/queryIds.json"

    # .env파일 생성
    {
        echo "API_ID=FALSE"
        echo "API_HASH=FALSE"
        echo "CLAIM_FRIENDS_REWARD=TRUE"
        echo "AUTO_FARMING=TRUE"
        echo "AUTO_DAILY_QUIZ=TRUE"
        echo "SLEEP_BETWEEN_REQUESTS=TRUE"
        echo "USE_PROXY_FROM_FILE=TRUE"
        echo "USE_QUERY_ID=TRUE"
    } > "$WORK/.env"  

    echo -e "${GREEN}.env파일을 생성했습니다.${NC}"

    # 프록시파일 생성
    echo -e "${YELLOW}프록시 정보를 입력하세요. 입력형식: http://user:pass@ip:port${NC}"
    echo -e "${YELLOW}여러 개의 프록시는 줄바꿈으로 구분하세요.${NC}"
    echo -e "${YELLOW}입력을 마치려면 엔터를 두 번 누르세요.${NC}"

    {
        echo "const proxies = ["  # 파일 시작
        while IFS= read -r line; do
            [[ -z "$line" ]] && break
            # 입력된 프록시 정보를 파싱하여 형식에 맞게 변환
            IFS='@' read -r userpass hostport <<< "$line"
            IFS=':' read -r username password <<< "$userpass"
            IFS=':' read -r ip port <<< "$hostport"
            echo "  {"
            echo "    ip: \"$ip\","
            echo "    port: $port,"
            echo "    socksType: 5,"  # 기본값으로 5 사용
            echo "    username: \"$username\","
            echo "    password: \"$password\","
            echo "  },"
        done
        echo "];"  # 배열 끝
        echo "module.exports = proxies;"  # 모듈 내보내기
    } > "$WORK/bot/config/proxies.js"
    
    # 봇 구동
    cd "$WORK"
    node index.js
    ;;
    
  2)
    echo -e "${GREEN}봇을 재실행합니다.${NC}"
    
    # nvm을 로드합니다
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # nvm을 로드합니다
    cd "$WORK"

    # 봇 구동
    node index.js
    ;;

  *)
    echo -e "${RED}잘못된 선택입니다. 다시 시도하세요.${NC}"
    ;;
esac
