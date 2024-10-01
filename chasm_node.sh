#!/bin/bash

tput reset
tput civis

# Put your logo here if nessesary

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_orange "   ______  __    __       ___           _______..___  ___. " && sleep 0.2
show_orange "  /      ||  |  |  |     /   \         /       ||   \/   | " && sleep 0.2
show_orange " |  ,----'|  |__|  |    /  ^  \       |   (---- |  \  /  | " && sleep 0.2
show_orange " |  |     |   __   |   /  /_\  \       \   \    |  |\/|  | " && sleep 0.2
show_orange " |   ----.|  |  |  |  /  _____  \  .----)   |   |  |  |  | " && sleep 0.2
show_orange "  \______||__|  |__| /__/     \__\ |_______/    |__|  |__| " && sleep 0.2
echo ""
sleep 1

while true; do
    echo "1. Подготовка к установке Chasm (Preparation)"
    echo "2. Установка Chasm (Install)"
    echo "3. Запустить или обновить (Start or update node)"
    echo "4. Проверить логи (Check logs)"
    echo "5. Удаление ноды (Delete node)"
    echo "6. О нодe (About Node)"
    echo "7. Выход (Exit)"
    echo ""
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            echo -e "\e[33mНачинаем подготовку (Starting preparation)...\e[0m"
            sleep 1
            # Update packages
            echo -e "\e[33mОбновляем пакеты (Updating packages)...\e[0m"
            if sudo apt update && sudo apt upgrade -y && sudo apt install -y curl git jq lz4 build-essential unzip; then
                sleep 1
                echo -e "Обновление пакетов (Updating packages): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "Обновление пакетов (Updating packages): \e[31mОшибка (Error)\e[0m"
                echo ""
                exit 1
            fi

            # Install or update Docker
            if which docker > /dev/null 2>&1; then
                echo -e "\e[32mDocker уже установлен (Docker is already installed)\e[0m"
                echo ""
                # Try to update Docker
                echo -e "\e[33mОбновляем Docker до последней версии (Updating Docker to the latest version)...\e[0m"
                sleep 1

                if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
                    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
                    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
                    sudo apt-get update &&
                    sudo apt-get install --only-upgrade docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
                    sleep 1
                    echo -e "Обновление Docker (Docker update): \e[32mУспешно (Success)\e[0m"
                    echo ""
                else
                    echo -e "Обновление Docker (Docker update): \e[31мОшибка (Error)\e[0m"
                    echo ""
                fi
            else
                # Install docker
                echo -e "\e[31mDocker не установлен (Docker not installed)\e[0m"
                echo ""
                echo -e "\e[33mУстанавливаем Docker (Installing Docker)...\e[0m"
                sleep 1
                if sudo apt install apt-transport-https ca-certificates curl software-properties-common -y &&
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&
                sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&
                sudo apt-get update &&
                sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y; then
                    sleep 1
                    echo -e "Установка Docker (Docker installation): \e[32mУспешно (Success)\e[0m"
                    echo ""
                else
                    echo -e "Установка Docker (Docker installation): \e[31mОшибка (Error)\e[0m"
                    echo ""
                fi
            fi
            echo -e "\e[33m--- ПОДГОТОВКА ЗАВЕРШЕНА. PREPARATION COMPLETED ---\e[0m"
            echo ""
            ;;
        2)
            # chasm installation
            echo -e "\e[33mНачинаем установку (Starting installation)...\e[0m"
            echo ""
            sleep 2

            # get data from user
            read -p "Введите имя скаута (SCOUT NAME): " SCOUT_NAME
            read -p "Введите SCOUT UID: " SCOUT_UID
            read -p "Введите Chasm API ключ (WEBHOOK API KEY): " WEBHOOK_API_KEY
            read -p "Введите GROQ API ключ (GROQ API KEY): " GROQ_API_KEY

            SERVER_IP=$(hostname -I | awk '{print $1}')

            # create env
            echo -e "\e[33mСкачиваем ENV (Downloading env)...\e[0m"
            sleep 1
            if mkdir ChasmNode && cd ChasmNode && touch .env; then
                sleep 1
                echo -e "ENV создан (ENV created): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "ENV создан (ENV created): \e[31mОшибка (Error)\e[0m"
                echo ""
            fi

            # rewrite env with user data
            echo -e "\e[33mПереписываем ENV (Rewriting env)...\e[0m"
            sleep 2
            echo ""
            if cat << EOF > .env
PORT=3001
LOGGER_LEVEL=debug

# Chasm
ORCHESTRATOR_URL=https://orchestrator.chasm.net
SCOUT_NAME=$SCOUT_NAME
SCOUT_UID=$SCOUT_UID
WEBHOOK_API_KEY=$WEBHOOK_API_KEY

WEBHOOK_URL=http://$SERVER_IP:3001/

# Chosen Provider (groq, openai)
PROVIDERS=groq
MODEL=gemma2-9b-it
GROQ_API_KEY=$GROQ_API_KEY
EOF
            then
                sleep 1
                echo -e "ENV обновлен (ENV updated): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "ENV обновлен (ENV updated): \e[31mОшибка (Error)\e[0m"
                echo ""
            fi
            echo -e "\e[33m--- УСТАНОВКА ЗАВЕРШЕНА. INSTALLATION COMPLETED ---\e[0m"
            echo ""
            ;;
        3)
            # Start or update
            # Stop container
            echo -e "\e[33mОстанавливаем контейнер (Stopping container)...\e[0m"
            if docker stop scout; then
                sleep 1
                echo -e "Контейнер остановлен (Container stopped): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mКонтейнер не запущен (Container isn't running)\e[0m"
                echo ""
            fi

            # Delete container
            echo -e "\e[33mУдаляем контейнер (Deleting container)...\e[0m"
            if docker rm scout; then
                sleep 1
                echo -e "Контейнер scout удален (Container deleted): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mКонтейнер scout не найден (Container doesn't exist)\e[0m"
                echo ""
            fi

            # Delete image
            if docker rmi chasmtech/chasm-scout:latest; then
                sleep 1
                echo -e "Образ scout удален (Image deleted): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mОбраз scout не найден (Image doesn't exist)\e[0m"
                echo ""
            fi

            # download docker image
            echo -e "\e[33mСкачиваем образ (Downloading image)...\e[0m"
            sleep 2
            echo ""
            if docker pull chasmtech/chasm-scout:latest; then
                sleep 1
                echo -e "Образ скачан (Image downloaded): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "Образ скачан (Image downloaded): \e[31mОшибка (Error)\e[0m"
                echo ""
            fi

            #Starting Node
            echo -e "\e[33mЗапускаем ноду (Starting node)...\e[0m"
            sleep 1
            if docker run -d --restart=always --env-file /root/ChasmNode/.env -p 3001:3001 --name scout chasmtech/chasm-scout; then
                sleep 1
                echo -e "\e[32mНода запущена (Node is running)!!!!\e[0m"
                echo ""
            else
                echo -e "\e[31mНе удалось запустить ноду (Failed to start the node)!!!!\e[0m"
                echo ""
            fi
            ;;
        4)
            # check node logs
            echo -e "\e[33mЗапускаем логи (Starting the logs)...\e[0m"
            sleep 2
            docker logs scout
            echo ""
            sleep 2
            echo -e "Ответ сервера(Server response): $(curl localhost:3001)"
            echo ""
            sleep 2
            source ./ChasmNode/.env
            curl -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $WEBHOOK_API_KEY" \
            -d '{"body":"{\"model\":\"gemma2-9b-it\",\"messages\":[{\"role\":\"system\",\"content\":\"You are a helpful assistant.\"}]}"}' \
            $WEBHOOK_URL
            ;;
        5)
            # Delete node
            # Stop container
            echo -e "\e[33mОстанавливаем контейнер (Stopping container)...\e[0m"
            if docker stop scout; then
                sleep 1
                echo -e "Контейнер остановлен (Container stopped): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mКонтейнер не запущен (Container isn't running)\e[0m"
                echo ""
            fi

            # Delete container
            echo -e "\e[33mУдаляем контейнер (Deleting container)...\e[0m"
            if docker rm scout; then
                sleep 1
                echo -e "Контейнер scout удален (Container deleted): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mКонтейнер scout не найден (Container doesn't exist)\e[0m"
                echo ""
            fi

            if docker rmi chasmtech/chasm-scout:latest; then
                sleep 1
                echo -e "Образ scout удален (Image deleted): \e[32mУспешно (Success)\e[0m"
                echo ""
            else
                echo -e "\e[34mОбраз scout не найден (Image doesn't exist)\e[0m"
                echo ""
            fi

            # Delete folder
            echo -e "\e[33mУдаляем env (Deleting env)...\e[0m"
            sleep 1
            if sudo rm -rvf ChasmNode; then
                sleep 1
                echo -e "\e[32mENV удален (ENV Deleted)!!!!\e[0m"
                echo ""
            else
                echo -e "\e[34mENV не найден (ENV doesn't exist)\e[0m"
                echo ""
            fi
            echo -e "\e[33m--- НОДА УДАЛЕНА. NODE DELETED ---\e[0m"
            echo ""
            ;;
        6)
            # Print node data
            echo -e "\e[34mИщем данные ноды (Looking for node data)...\e[0m"
            sleep 2
            sudo cat ChasmNode/.env
            echo ""
            ;;
        7)
            # Stop script and exit
            echo -e "\e[31mСкрипт остановлен (Script stopped)\e[0m"
            echo ""
            exit 0
            ;;
        *)
            # incorrect options handling
            echo ""
            echo -e "\e[31mНеверная опция\e[0m. Пожалуйста, выберите из тех, что есть."
            echo ""
            echo -e "\e[31mInvalid option.\e[0m Please choose from the available options."
            echo ""
            ;;
    esac
done
