import os

import streamlit as st
from openai import OpenAI

HF_MODEL_NAME = os.getenv("HF_MODEL_NAME", None)
SERVED_MODEL_NAME = os.getenv("SERVED_MODEL_NAME", None)
API_ENDPOINT = os.getenv("API_ENDPOINT", None)

if HF_MODEL_NAME is None or SERVED_MODEL_NAME is None or API_ENDPOINT is None:
    st.error(
        "Please set the HF_MODEL_NAME, SERVED_MODEL_NAME and API_ENDPOINT environment variables."
    )
    st.stop()

st.title("VLLM Server Test")

client = OpenAI(api_key="NONE", base_url=f"{API_ENDPOINT}/v1")

if "messages" not in st.session_state:
    st.session_state.messages = []

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

if prompt := st.chat_input("What is up?"):
    st.session_state.messages.append({"role": "user", "content": prompt})
    with st.chat_message("user"):
        st.markdown(prompt)

    with st.chat_message("assistant"):
        stream = client.chat.completions.create(
            model=SERVED_MODEL_NAME,
            messages=[
                {"role": m["role"], "content": m["content"]}
                for m in st.session_state.messages
            ],
            stream=True,
        )
        response = st.write_stream(stream)
    st.session_state.messages.append({"role": "assistant", "content": response})
