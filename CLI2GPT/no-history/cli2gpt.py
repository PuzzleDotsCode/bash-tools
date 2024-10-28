#!/usr/bin/env python3

from dotenv import load_dotenv
import openai
import sys
import argparse
import os

# Load environment variables from .env file
load_dotenv()

# Set OpenAI API key from environment variable
openai.api_key = os.getenv("CLI2GPT")

# Check if the API key is set
if openai.api_key is None:
    print("Error: OpenAI API key is not set. Please set it in your environment variables or in a .env file.")
    sys.exit(1)

# Function to display help information
def display_help():
    help_message = """
Usage: cli2gpt [options]

Options:
  -u, --usage               Show this help message and exit.
  -q, --question STRING      The question to ask ChatGPT.
  -i, --input FILE          File input for CLI output (if needed).
  -f, --file FILE           A related file to provide context for the CLI output.

API Key:
To use this script, set your OpenAI API key in your environment variables or in a .env file:
.env/CLI2GPT="your-api-key-here"
export CLI2GPT="your-api-key-here"

Ask a question - examples:
1. Pipe in stdout into GPT and do a question:
   $ ls -la | cli2gpt -q "What does this directory listing mean?"

2. Ask a question without input:
   $ cli2gpt -q "What is TCP/IP?"

3. Pipe in stdout into GPT and relate a file:
   $ ls -la | cli2gpt -f /bin/ls
   $ cli2gpt -i myfile.txt -f /path/to/related/file

4. Display help:
   $ cli2gpt -u
    """
    print(help_message)

# Argument parser setup
parser = argparse.ArgumentParser(description="Ask ChatGPT with optional CLI input.")
parser.add_argument("-q", "--question", type=str, help="The question to ask ChatGPT.")
parser.add_argument("-i", "--input", type=argparse.FileType('r'), help="File input for CLI output (if needed).")
parser.add_argument("-f", "--file", type=str, help="A related file to provide context for the CLI output.")
parser.add_argument("-u", "--usage", action="store_true", help="Display help message.")

args = parser.parse_args()

# Display help if -u or --usage is called
if args.usage:
    display_help()
    sys.exit(0)

# Check if a question is provided
if not args.question:
    print("Error: You must provide a question using '--question' or '-q'.")
    display_help()
    sys.exit(1)

# Read the CLI output from stdin (default behavior)
cli_output = sys.stdin.read() if not args.input else args.input.read()

# If no input is provided (i.e., no piped input and no input file), throw an error
if not cli_output:
    print("Error: You must provide input from a pipe or a file.")
    display_help()
    sys.exit(1)

# Load related file content if provided
related_file_content = ""
if args.file:
    try:
        with open(args.file, 'r') as f:
            related_file_content = f.read()
    except Exception as e:
        print(f"Error reading file '{args.file}': {e}")
        sys.exit(1)

# Combine the CLI output, user question, and related file content for the API call
combined_input = (
    f"CLI Output:\n{cli_output}\n\n"
    f"Related File Content:\n{related_file_content}\n\n"
    f"User Question: {args.question}"
)

# Call the OpenAI API
response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": combined_input}
    ]
)

# Print the response from ChatGPT
print("ChatGPT's response:", response.choices[0].message['content'])
