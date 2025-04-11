#!/bin/bash

# Sudo validation
UserID=$(id -u)
if [[ "${UserID}" -ne 0 ]]; then
    echo 'Kindly use sudo or login as root'
    exit 1
fi

# Ask for username/login
read -p 'Enter username: ' USERNAME

# Ask for real name
read -p 'Real name: ' REALNAME

# Ask for password (silently)
read -p 'Enter initial password: ' PASSWORD
echo 'Creating user and setting password....'

# Create new user
useradd -c "${REALNAME}" -m "${USERNAME}"
if [[ $? -ne 0 ]]; then
    echo "Error creating user. Contact admin."
    exit 1
fi

# Function to set password with expect
set_password() {
    /usr/bin/expect <<EOF
spawn passwd "${USERNAME}"
expect "Enter new UNIX password:"
send "${PASSWORD}\r"
expect "Retype new UNIX password:"
send "${PASSWORD}\r"
expect eof
EOF
}

# Check if expect is installed, install if needed
if ! command -v expect &> /dev/null; then
    if command -v yum &> /dev/null; then
        sudo yum install expect -y &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo "Failed to install expect."
            exit 1
        fi
    elif command -v apt &> /dev/null; then
        sudo apt install expect -y &> /dev/null
        if [[ $? -ne 0 ]]; then
            echo "Failed to install expect."
            exit 1
        fi
    else
        echo "Unsupported package manager. Install expect manually."
        exit 1
    fi
fi

# Set the password
set_password &> /dev/null
if [[ $? -ne 0 ]]; then
    echo 'Error creating password.'
    exit 1
fi

# Force password change after first login
passwd -e ${USERNAME} &>/dev/null
if [[ $? -ne 0 ]]; then
	echo 'Error enforcing password change.' 
	exit 1
else
	echo "Password expiry successful."
fi

# Display user information 
echo -e "\n........User Information........."
echo
echo "Username: ${USERNAME}"
echo "Full name:${REALNAME}"
echo "Password: ${PASSWORD}"
echo 'Password change required during first login.'
