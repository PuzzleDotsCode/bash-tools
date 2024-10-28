from setuptools import setup, find_packages

setup(
    name="CLI2GPT",
    version="0.1",
    packages=find_packages(),
    install_requires=[
        "openai",
        "python-dotenv",
    ],
    entry_points={
        "console_scripts": [
            "chatgpt_pipe=chatgpt_pipe:main",
        ],
    },
)

