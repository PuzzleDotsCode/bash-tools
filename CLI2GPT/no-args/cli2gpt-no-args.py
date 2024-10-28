from dotenv import load_dotenv
import openai
import sys
import os

openai.api_key = os.getenv("CLI2GPT")

# Read the input from the command line
input_text = sys.stdin.read()

extra_definition = ""
main_definition = "You are a helpfull expert mentor in offensive cybersecurity from the special unit you and me belong where you are mentoring me as a sub officer of cybersecurity special Mossad/NSA unit."
system_definition = ""

# Update system_definition based on extra_definition
if extra_definition:
    system_definition = f"{main_definition} {extra_definition}"
else:
    system_definition = main_definition


# Call the OpenAI API
response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo",
    messages=[
        # {"role": "system", "content": "You are a helpful assistant."},
        {"role": "system", "content": system_definition},
        {"role": "user", "content": input_text}
    ]
)

# Print the response
print(response.choices[0].message['content'])
