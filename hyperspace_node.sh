#!/bin/bash

# Script storage path
SCRIPT_PATH="$HOME/Hyperspace.sh"

# Check and install screen if necessary
function check_and_install_screen() {
    if ! command -v screen &> /dev/null; then
        echo "Installing screen..."
        apt update && apt install -y screen
    else
        echo "Screen is already installed."
    fi
}

# Main menu function
function main_menu() {
    while true; do
        clear
        echo "Script created by the Big Bet Community (@ferdie_jhovie on Twitter). Open-source and free—do not trust paid versions."
        echo "For inquiries, contact Twitter (only one account exists)."
        echo "============================================================"
        echo "Press Ctrl + C to exit the script."
        echo "Select an operation:"
        echo "1. Deploy Hyperspace Node"
        echo "2. View Logs"
        echo "3. View Points"
        echo "4. Delete Node (Stop Node)"
        echo "5. Enable Log Monitoring"
        echo "6. View Private Key"
        echo "7. Check Aios Daemon Status"
        echo "8. Enable Points Monitoring"
        echo "9. Exit Script"
        echo "============================================================"
        read -p "Enter choice (1-9): " choice

        case $choice in
            1)  deploy_hyperspace_node ;;
            2)  view_logs ;; 
            3)  view_points ;;
            4)  delete_node ;;
            5)  start_log_monitor ;;
            6)  view_private_key ;;
            7)  view_status ;;
            8)  start_points_monitor ;;
            9)  exit_script ;;
            *)  echo "Invalid selection, please try again."; sleep 2 ;;
        esac
    done
}

# Deploy Hyperspace Node
function deploy_hyperspace_node() {
    echo "Executing installation command..."
    curl https://download.hyper.space/api/install | bash

    # Update PATH
    export PATH=$(bash -c 'source /root/.bashrc && echo $PATH')

    if ! command -v aios-cli &> /dev/null; then
        echo "aios-cli not found. Retrying..."
        sleep 3
        export PATH="$PATH:/root/.local/bin"
        if ! command -v aios-cli &> /dev/null; then
            echo "aios-cli not found. Run 'source /root/.bashrc' manually and retry."
            read -n 1 -s -r -p "Press any key to return to the main menu..."
            return
        fi
    fi

    read -p "Enter screen name (default: hyper): " screen_name
    screen_name=${screen_name:-hyper}

    # Cleanup existing screen session
    if screen -ls | grep "$screen_name" &>/dev/null; then
        echo "Stopping existing screen session: $screen_name..."
        screen -S "$screen_name" -X quit
        sleep 2
    fi

    echo "Creating new screen session: $screen_name..."
    screen -S "$screen_name" -dm
    screen -S "$screen_name" -X stuff "aios-cli start\n"
    sleep 5
    screen -S "$screen_name" -X detach

    echo "Updating environment variables..."
    source /root/.bashrc
    sleep 4

    echo "Enter your private key (press CTRL+D when done):"
    cat > my.pem
    echo "Importing private key..."
    aios-cli hive import-keys ./my.pem
    sleep 5

    model="hf:TheBloke/phi-2-GGUF:phi-2.Q4_K_M.gguf"
    echo "Adding model..."
    while ! aios-cli models add "$model"; do
        echo "Retrying model addition..."
        sleep 3
    done

    echo "Logging into Hive..."
    aios-cli hive login
    
    echo "Select tier (1-5):"
    select tier in 1 2 3 4 5; do
        if [[ $tier =~ ^[1-5]$ ]]; then
            aios-cli hive select-tier $tier
            break
        else
            echo "Invalid choice. Enter a number between 1 and 5."
        fi
    done

    echo "Connecting to Hive..."
    aios-cli hive connect
    sleep 5
    echo "Stopping aios-cli..."
    aios-cli kill
    
    echo "Restarting aios-cli in screen session with logs..."
    screen -S "$screen_name" -X stuff "aios-cli start --connect >> /root/aios-cli.log 2>&1\n"
    echo "Hyperspace node deployed successfully!"

    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# View Points
function view_points() {
    echo "Retrieving points..."
    source /root/.bashrc
    aios-cli hive points
    sleep 5
}

# Delete Node (Stop Node)
function delete_node() {
    echo "Stopping node using aios-cli kill..."
    aios-cli kill
    sleep 2
    echo "Node stopped."
    read -n 1 -s -r -p "Press any key to return to the main menu..."
    main_menu
}

# Enable Log Monitoring
function start_log_monitor() {
    echo "Starting log monitoring..."
    cat > /root/monitor.sh << 'EOL'
#!/bin/bash
LOG_FILE="/root/aios-cli.log"
SCREEN_NAME="hyper"
LAST_RESTART=$(date +%s)
MIN_RESTART_INTERVAL=300

while true; do
    current_time=$(date +%s)
    if (tail -n 4 "$LOG_FILE" | grep -q "Last pong received.*Sending reconnect signal" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to authenticate" || \
        tail -n 4 "$LOG_FILE" | grep -q "Failed to connect to Hive" || \
        tail -n 4 "$LOG_FILE" | grep -q "Another instance is already running" || \
        tail -n 4 "$LOG_FILE" | grep -q "Internal server error") && \
       [ $((current_time - LAST_RESTART)) -gt $MIN_RESTART_INTERVAL ]; then
        echo "$(date): Restarting service due to error..." >> /root/monitor.log
        screen -S "$SCREEN_NAME" -X stuff $'\003'  # Send Ctrl+C
        sleep 2
        screen -S "$SCREEN_NAME" -X stuff "aios-cli start --connect >> /root/aios-cli.log 2>&1\n"
        LAST_RESTART=$(date +%s)
    fi
    sleep 10
done
EOL
    chmod +x /root/monitor.sh
    nohup /root/monitor.sh &
    echo "Log monitoring started."
}

# Start the script
check_and_install_screen
main_menu
