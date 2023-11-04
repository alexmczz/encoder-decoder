#!/bin/bash

# URL encode function
urlencode() {
    # Usage: urlencode "string"
    local string="${1}"
    local strlen=${#string}
    local encoded=""
    local pos c o

    for (( pos = 0 ; pos < strlen ; pos++ )); do
        c=${string:$pos:1}
        case "$c" in
            [-_.~a-zA-Z0-9] ) o="${c}" ;;
            * )               printf -v o '%%%02x' "'$c"
        esac
        encoded+="${o}"
    done
    echo "${encoded}"
}

# URL decode function
urldecode() {
    # Usage: urldecode "string"
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

# Function to encode the passphrase from file
encode_passphrase() {
    echo "Enter the file path with the passphrase you want to encode: "
    read -r file_path
    if [ -f "$file_path" ]; then
        phrase=$(cat "$file_path")
        newph="$phrase"
        for i in $(seq 1 10)
        do
            newph=$(echo "$newph" | base64) 
            for j in $(seq 1 10)
            do
                newph=$(urlencode "$newph")
            done
        done
        echo "Encoded passphrase: $newph"
    else
        echo "File not found. Please enter a valid file path."
    fi
}

# Function to decode the passphrase
decode_passphrase() {
    echo "Enter the encoded passphrase file path: "
    read -r file_path
    if [ -f "$file_path" ]; then
        encoded_passphrase=$(cat "$file_path" )
        decoded_passphrase="$encoded_passphrase"
        for j in $(seq 1 10)
        do
            decoded_passphrase=$(urldecode "$decoded_passphrase")
        done
        decoded_passphrase=$(echo "$decoded_passphrase" | base64 --decode)
        echo "Decoded passphrase: $decoded_passphrase"
    else
        echo "File not found. Please enter a valid file path."
    fi
}

# Function to encode the contents of a file
encode_file() {
    echo "Enter the file path you want to encode: "
    read -r file_path
    if [ -f "$file_path" ]; then
        # Read content from the file
        content=$(cat "$file_path")

        # Ask for confirmation
        echo "Are you sure you want to encode the file? (yes/no)"
        read -r confirmation

        if [ "$confirmation" = "yes" ]; then
            # Encode the content
            encoded_content=$(echo "$content" | base64)

            # Update the file with the encoded content
            echo "$encoded_content" > "$file_path"
            echo "File encoded successfully."
        else
            echo "Operation canceled."
        fi
    else
        echo "File not found. Please enter a valid file path."
    fi
}

# Function to decode the contents of a file
decode_file() {
    echo "Enter the file path you want to decode: "
    read -r file_path
    if [ -f "$file_path" ]; then
        # Read content from the file
        encoded_content=$(cat "$file_path")

        # Decode the content
        decoded_content=$(echo "$encoded_content" | base64 --decode)

        # Update the file with the decoded content
        echo "$decoded_content" > "$file_path"
        echo "File decoded successfully."
    else
        echo "File not found. Please enter a valid file path."
    fi
}

# Ask user for operation
echo "Choose an operation: encode or decode"
read -r operation

if [ "$operation" = "encode" ]; then
    encode_file
elif [ "$operation" = "decode" ]; then
    decode_file
else
    echo "Invalid operation. Please choose 'encode' or 'decode'."
fi

# Ask user for operation
echo "Choose an operation: encode or decode"
read -r operation

if [ "$operation" = "encode" ]; then
    encode_passphrase
elif [ "$operation" = "decode" ]; then
    decode_passphrase
else
    echo "Invalid operation. Please choose 'encode' or 'decode'."
fi
