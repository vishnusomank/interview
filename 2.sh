#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to display error message in red
error_message() {
    echo -e "${RED}Error: $1 ${NC}"
}

print_help() {
	# Display Help
	echo "A simple GitHub cloning utility"
	echo
	echo "Syntax: clone <gh-repo-link> <branch(optional)>"
	echo "examples:"
	echo "    clone git@github.com/test-gh-test-repo.git my-test-branch"
	echo "    clone my-test-branch git@github.com/test-gh-test-repo.git"
	echo "    clone git@github.com/test-gh-test-repo.git"
	echo
}

# Function to prompt for confirmation
confirm_delete() {
    echo -e "The folder $GREEN'${repo_name}'${NC} already exists."
    read -p "$(echo -e ${RED}"Do you want to delete it and clone again? [[Y]/n]: "${NC})" -n 1 choice
    echo "" 
	choice=${choice:-Y} # set default value to Y
    case "$choice" in 
      y|Y ) 
          echo "Deleting existing folder and cloning..."
          rm -rf "$1"
          ;;
      n|N ) 
          echo "Skipping clone."
          exit 0
          ;;
      * ) 
	  	error_message "Invalid choice. Please enter Y or N."
		exit 0
		;;
    esac
}

clone_git_repo() {

	clone_cmd="$1"

	outputMsg="cloning from repository $GREEN$1$NC"

	if [ -n "$2" ]; then
		branch=$(echo $2 | cut -d : -f 2)
		if [ ! -n "$branch" ]; then 
			branch=$2
		fi
		clone_cmd="$clone_cmd -b $branch"
		outputMsg="$outputMsg branch $GREEN$branch$NC"
    fi

	echo -e $outputMsg

	git clone $clone_cmd

	# Check if the clone was successful
	if [ $? -eq 0 ]; then
		echo -e $GREEN"Git clone successful!$NC"
	else
		error_message "Git clone failed!"
		exit 0
	fi
}

if [ $# -eq 0 ]; then
    # No arguments provided, print help menu
    print_help
    exit 1
fi
if [[ "$1" =~ \.git$ ]]; then
    gitRepo=$1
    gitBranch=$2
elif [[ "$2" =~ \.git$ ]]; then
    gitRepo=$2
    gitBranch=$1
else
    error_message "One of the arguments must end with '.git'"
    print_help
    exit 1
fi

repo_name=$(basename "$gitRepo" .git)
echo -e "checking if directory$GREEN $repo_name$NC exists"

# Check if the destination folder already exists
if [ -d "$repo_name" ]; then
	confirm_delete "$repo_name"
else 
	echo -e "The folder$GREEN $repo_name$NC does not exist. Cloning..."
fi

clone_git_repo $gitRepo $gitBranch



