#!/bin/bash

# Wait before postfix is really started.

function get_state {
    echo $(script -c 'postfix status' | grep postfix/postfix-script)
}

postfix start
echo $(get_state)

while true; do
    state=$(get_state)
    if [[ "$state" != "${state/is running/}" ]]; then
        PID=${state//[^0-9]/}
        if [[ -z $PID ]]; then
            continue
        fi
        if [[ ! -d "/proc/$PID" ]]; then
            echo "Postfix proces $PID does not exist."
            break
        fi
    else
        echo "Postfix is not running."
        break
    fi
done


