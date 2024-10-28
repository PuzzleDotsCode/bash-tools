# CLI2GPT

Using the OpenAI API to pipe CLI results into ChatGPT.

1. Set Up an OpenAI API Key: You'll need an API key from OpenAI, which you can generate from your OpenAI account.

```sh
export CLI2GPT="yOuR_aPi_KeY"
```

2. Installation: setup.py or requirements.txt

```sh
# some systems either require/not virtual environment
pip install -r requirements.txt
pip install .
```

3. Pipe the Output of a CLI Command into the Script: You can pipe the output of any CLI command directly to this script. For example:

```sh
ls -la | python cli2gpt.py
```


* Alternative Using cURL (if you don't want to write a Python script): You can also use cURL directly to call the API. Here’s how you might do it:

```sh
ls -la | curl https://api.openai.com/v1/chat/completions \
-H "Authorization: Bearer $CLI2GPT" \
-H "Content-Type: application/json" \
-d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "'"$(</dev/stdin)"'"}]
}'
```

This method allows you to take CLI outputs and process or analyze them using ChatGPT effectively.






