#!/bin/bash
source $HOME/.bash_profile

read -p "Enter fees: " FEE
read -p "Wait time in seconds: " DELAY
read -s "Password: " PASS

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

for (( ;; )); do

		AMOUNT=$(( $RANDOM %100 ))
		AMOUNT=$(( AMOUNT+7 ))

		echo -e $PASS | umeed tx bank send ${wallet1} ${wallet2} ${AMOUNT}uumee --chain-id=umeevengers-1c --from wallet1 --fees=${FEE}uumee -y
    echo -e $PASS | umeed tx bank send ${wallet2} ${wallet1} ${AMOUNT}uumee --chain-id=umeevengers-1c --from wallet2 --fees=${FEE}uumee -y

for (( timer=${DELAY}; timer>0; timer-- ))
       do
                printf "* sleep for ${RED}%02d${NC} sec\r" $timer
                sleep 1
        done
done
