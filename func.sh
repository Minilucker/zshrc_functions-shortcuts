# ======================================================================================================================================================
# Custom functions & aliases
alias nmap-all="sudo nmap -p- -T5"
alias nmap-srv="sudo nmap -sC -sV -T5"
alias nmap-udp="sudo nmap -sU -T5"

function exenv() {
    deactivate
    unset BOX_NAME
    unset CURRENT_BOX
    rm -f ~/.opened_env
    if [[ $? == 0 ]]
    then
        echo "Successfully exited env"
    else
        echo "Error"
    fi
}

function nmap_ftcp() {
    nmap-all $1 -o "${CURRENT_BOX}/nmap/${BOX_NAME}-all.nmap"
    openedports=$(cat "${CURRENT_BOX}/nmap/${BOX_NAME}-all.nmap" | grep open | cut -d '/' -f 1 | xargs | tr ' ' ',')
    if [ ! -z "$CURRENT_BOX" ]
    then
        echo "running nmap-srv $1 -p $openedports -o ${CURRENT_BOX}/nmap/${BOX_NAME}-srv.nmap"
        nmap-srv $1 -p "$openedports" -o "${CURRENT_BOX}/nmap/${BOX_NAME}-srv.nmap"
    else
        if [ -d "./nmap" ]
        then
            echo "Not in env, running nmap-srv $1 -p $openedports -o nmap/${BOX_NAME}-srv.nmap"
            nmap-srv $1 -p "$openedports" -o "nmap/${BOX_NAME}-srv.nmap"
        else
            nmap-srv $1 -p "$openedports" -o "${BOX_NAME}-srv.nmap"
        fi
    fi
}

function eenv(){
    cd "$HOME/Documents/$1/$2/"
    if [ ! -d ".$2" ]
    then
        python3 -m venv ".$2"
    fi
    source ".$2/bin/activate"
    export CURRENT_BOX="$PWD"
    export BOX_NAME="$2"
    echo "Ready to go !"
    echo "$1 $2" > ~/.opened_env
}

function cenv(){
    cd "$HOME/Documents/$1"
    mkdir "$2" 2>/dev/null
    if [[ $? == 1 ]]
    then
        echo "env already created, entering ..."
        eenv "$1" "$2"
    else
        mkdir "$2/nmap"
        echo "env created, entering ..."
        eenv "$1" "$2"
    fi
}

function addhost() {
    output=$(grep "/etc/hosts" -e "$2")
    if [ -z $output ]
    then
        echo "no host found ,adding"
        echo -e "$1\t$2" | sudo tee -ap /etc/hosts
    else
        read "answer?host found, update ip ? [Y/n]?"
        if [ -z "$answer" ]
        then
            updatehost $1 $2
        else
            echo "exiting ..."
            exit 0
        fi
    fi
}

function updatehost() {
    current_ip=$(grep "/etc/hosts" -e "$2" | cut -d$'\t' -f 1)
    echo $current
    sudo sed -i "s/$current_ip/$1/g" /etc/hosts
    echo "updated /etc/hosts file"
}

if [[ -f ~/.opened_env ]]
then
echo "found opened environement, entering $(cat ~/.opened_env | cut -d " " -f 1) -> $(cat ~/.opened_env | cut -d " " -f 2)"
eenv $(cat ~/.opened_env)
echo "run exenv to exit the environment"
fi
