#!/bin/bash

# Prompt the user for a regular expression to match process names
read -p "Enter a regular expression to match process names: " regex

# Get a list of running processes that match the regex
matching_processes=$(ps aux | awk -v regex="$regex" '$11 ~ regex {print $2, $11}' | head -n 20)

# Check if any matching processes were found
if [[ -z "$matching_processes" ]]; then
    echo "No processes matching the provided regex found."
    exit 1
fi

# Display the list of matching processes
clear
echo "Matching Processes (PID - Name):"
echo "-------------------------------"
echo "$matching_processes"

# Prompt the user to select a process to kill
read -p "Enter the PID of the process to kill (or 'q' to quit): " pid_to_kill

# Check if the user wants to quit
if [[ "$pid_to_kill" == "q" ]]; then
    exit 0
fi

# Check if the entered PID is valid
if ! [[ "$pid_to_kill" =~ ^[0-9]+$ ]]; then
    echo "Invalid PID entered."
    exit 1
fi

# Check if the entered PID corresponds to a process in the list of matching processes
if ! grep -q "$pid_to_kill" <<< "$matching_processes"; then
    echo "PID $pid_to_kill is not in the list of matching processes."
    exit 1
fi

# Confirm the user's intention to kill the selected process
read -p "Are you sure you want to kill the process with PID $pid_to_kill? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Kill the selected process
    kill -9 "$pid_to_kill"
    echo "Process with PID $pid_to_kill has been killed."
else
    echo "Process with PID $pid_to_kill was not killed."
fi
