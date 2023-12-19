#!/bin/bash

# Define command version
VERSION="v0.1.0"

# Show manual page
function man() {
  cat <<EOF
NAME
     internsctl - A command for managing server information and tasks.

SYNOPSIS
     internsctl [OPTIONS] [COMMAND] [SUBCOMMAND] [ARGUMENTS]

DESCRIPTION
     internsctl is a CLI tool aimed at simplifying server management tasks
     for interns. It provides commands for retrieving system information,
     managing users, and more.

OPTIONS
     -h, --help       Show this help message and exit
     -V, --version    Show version information and exit

COMMANDS
     cpu             Manage CPU information
          getinfo      Get detailed CPU information

     memory         Manage memory information
          getinfo      Get detailed memory information

     user            Manage system users
          create        Create a new user
          list          List all users
               --sudo-only Show only users with sudo permissions

     file            Get information about files
          getinfo      Get details about a file
               [OPTIONS] [FILE] 
                  -s|--size    Print file size only
                  -p|--permissions  Print file permissions only
                  -o|--owner    Print file owner only
                  -m|--last-modified  Print last modified time only

SEE ALSO
     man ls, man free

EXAMPLES
     Get CPU information: internsctl cpu getinfo
     Get memory usage: internsctl memory getinfo
     Create a new user: internsctl user create username
     List all users: internsctl user list
     List users with sudo: internsctl user list --sudo-only
     Get file size: internsctl file getinfo --size /path/to/file

AUTHORS
     [Your Name/Organization]

EOF
}

# Show help message
function help() {
  echo "Usage: internsctl [OPTIONS] [COMMAND] [SUBCOMMAND] [ARGUMENTS]"
  echo "See 'man internsctl' for detailed help and documentation."
}

# Show version information
function version() {
  echo "internsctl $VERSION"
}

# Main command logic
if [[ $# -eq 0 ]]; then
  help
  exit 0
fi

case $1 in
  -h|--help)
    help
    ;;
  -V|--version)
    version
    ;;
  cpu)
    shift
    case $1 in
      getinfo)
        # Use lscpu to get detailed CPU information
        lscpu
        ;;
      *)
        echo "Invalid subcommand for 'cpu': '$1'"
        exit 1
        ;;
    esac
    ;;
  memory)
    shift
    case $1 in
      getinfo)
        # Use free command to get memory information
        free -mh
        ;;
      *)
        echo "Invalid subcommand for 'memory': '$1'"
        exit 1
        ;;
    esac
    ;;
  user)
    shift
    case $1 in
      create)
        if [[ $# -ne 2 ]]; then
          echo "Invalid usage: Please provide username as argument."
          exit 1
        fi
        # Create user with home directory and set random password
        useradd -m $2
        passwd $2 - << EOF
$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8)
EOF
        echo "User '$2' created successfully."
        ;;
      list)
        if [[ $2 == "--sudo-only" ]]; then
          # Use id command to filter users with sudo access
          id | grep sudo | awk '{print $1}'
        else
          # List all users
          cat /etc/passwd | cut -d':' -f1
        fi
        ;;
      *)
        echo "Invalid subcommand for 'user': '$1'"
        exit 1
        ;;
    esac
    ;;
  file)
    shift
    if [[ $1 == "getinfo" ]]; then
      if [[ $# -lt 2 ]]; then
        echo "Please provide a file path as argument."
        exit 1
      fi
      # Use stat command to get