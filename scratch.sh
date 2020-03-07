#!/bin/bash

# Environment Variables
USER_HOME=$HOME
USER_CURRENT_DISTRO=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-
USER_CURRENT_DE=#env | grep XDG_CURRENT_DESKTOP | cut -d '=' -f 2-

# Install Targets
# User Variables

# "Is correct?"
isCorrect () {
  # $1 is initial conditional statement to be answered by this function.
  local conditional_resp
  read -rp "${1}" conditional_resp
  if [ "${conditional_resp,}" == "n" ]; then
    echo 0
  elif [ "${conditional_resp,}" == "y" ]; then
    echo 1
  else
    isCorrect "$1"
  fi
}

# Git Config function
gitConfig () {
  user_confirm=0
  user_condit="Is the above Git Config Correct? [Y/n]"

  printf "Hello, %s\nPlease enter a username and email address to document your Git commits.\n" "${USER}"
  read -rp "Username: " var1
  read -rp "Email Address: " var2
  printf "\n"
  git config --global user.name "${var1}"
  git config --global user.email "${var2}"
  git config --list | grep user

  while [ "${user_confirm}" == 0 ]; do
    user_resp=$(isCorrect "${user_condit}") ##figure out assigning value of func
    user_confirm=$user_resp

    if [ "${user_confirm}" == 0 ]; then
      gitConfig
    elif [ "${user_confirm}" == 1 ]; then
      echo "Git Identity Saved (Globally)"
    else
      echo "Failure at gitConfig()>isCorrect()"
      exit 1;
    fi
  done
}


