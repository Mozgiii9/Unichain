#!/bin/bash

GREEN='\033[0;32m'
RESET='\033[0m'

display_logo() {
    logo="
    \033[32m
    ███╗   ██╗ ██████╗ ██████╗ ███████╗██████╗ ██╗   ██╗███╗   ██╗███╗   ██╗███████╗██████╗ 
    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝██╔══██╗██║   ██║████╗  ██║████╗  ██║██╔════╝██╔══██╗
    ██╔██╗ ██║██║   ██║██║  ██║█████╗  ██████╔╝██║   ██║██╔██╗ ██║██╔██╗ ██║█████╗  ██████╔╝
    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██╔══██╗██║   ██║██║╚██╗██║██║╚██╗██║██╔══╝  ██╔══██╗
    ██║ ╚████║╚██████╔╝██████╔╝███████╗██║  ██║╚██████╔╝██║ ╚████║██║ ╚████║███████╗██║  ██║
    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
    \033[0m
    Подписаться на канал may.crypto{🦅}, чтобы быть в курсе самых актуальных нод - https://t.me/maycrypto
    "
    echo -e "$logo"
}

show_menu() {
    clear
    display_logo
    echo -e "${GREEN}Добро пожаловать в интерфейс управления узлом Uniswap.${RESET}"
    echo -e "${GREEN}Пожалуйста, выберите опцию:${RESET}"
    echo
    echo -e "${GREEN}1.${RESET} Установить узел"
    echo -e "${GREEN}2.${RESET} Перезапустить узел"
    echo -e "${GREEN}3.${RESET} Проверить узел"
    echo -e "${GREEN}4.${RESET} Просмотреть логи операционного узла"
    echo -e "${GREEN}5.${RESET} Просмотреть логи клиента исполнения"
    echo -e "${GREEN}6.${RESET} Отключить узел"
    echo -e "${GREEN}0.${RESET} Выход"
    echo
    echo -e "${GREEN}Введите ваш выбор [0-6]: ${RESET}"
    read -p " " choice
}

install_node() {
    cd
    if docker ps -a --format '{{.Names}}' | grep -q "^unichain-node-execution-client-1$"; then
        echo -e "${GREEN}1. Узел уже установлен.${RESET}"
    else
        echo -e "${GREEN}1. Установка узла...${RESET}"
        sudo apt update && sudo apt upgrade -y
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker

        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose

        git clone https://github.com/Uniswap/unichain-node
        cd unichain-node || { echo -e "${GREEN}Не удалось войти в директорию unichain-node.${RESET}"; return; }

        if [[ -f .env.sepolia ]]; then
            sed -i 's|^OP_NODE_L1_ETH_RPC=.*$|OP_NODE_L1_ETH_RPC=https://ethereum-sepolia-rpc.publicnode.com|' .env.sepolia
            sed -i 's|^OP_NODE_L1_BEACON=.*$|OP_NODE_L1_BEACON=https://ethereum-sepolia-beacon-api.publicnode.com|' .env.sepolia
        else
            echo -e "${GREEN}.env.sepolia файл не найден!${RESET}"
            return
        fi

        sudo docker-compose up -d

        echo -e "${GREEN}1. Узел успешно установлен.${RESET}"
    fi
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

restart_node() {
    echo -е "${GREEN}2. Перезапуск узла...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" up -d
    echo -e "${GREEN}2. Узел перезапущен.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_node() {
    echo -e "${GREEN}3. Проверка статуса узла...${RESET}"
    response=$(curl -s -d '{"id":1,"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["latest",false]}' \
      -H "Content-Type: application/json" http://localhost:8545)
    echo -e "${GREEN}Ответ: ${RESET}$response"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_logs_op_node() {
    echo -e "${GREEN}4. Получение логов для unichain-node-op-node-1...${RESET}"
    sudo docker logs unichain-node-op-node-1
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

check_logs_execution_client() {
    echo -e "${GREEN}5. Получение логов для unichain-node-execution-client-1...${RESET}"
    sudo docker logs unichain-node-execution-client-1
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

disable_node() {
    echo -e "${GREEN}6. Отключение узла...${RESET}"
    HOMEDIR="$HOME"
    sudo docker-compose -f "${HOMEDIR}/unichain-node/docker-compose.yml" down
    echo -e "${GREEN}6. Узел отключён.${RESET}"
    echo
    read -p "Нажмите Enter, чтобы вернуться в главное меню..."
}

while true; do
    show_menu
    case $choice in
        1)
            install_node
            ;;
        2)
            restart_node
            ;;
        3)
            check_node
            ;;
        4)
            check_logs_op_node
            ;;
        5)
            check_logs_execution_client
            ;;
        6)
            disable_node
            ;;
        0)
            echo -e "${GREEN}Выход...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${GREEN}Неверный выбор. Попробуйте снова.${RESET}"
            echo
            read -p "Нажмите Enter, чтобы продолжить..."
            ;;
    esac
done
