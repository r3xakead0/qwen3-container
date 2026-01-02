FROM ollama/ollama:latest

# Expose the port of Ollama
EXPOSE 11434

# Download the model at build time
RUN ollama serve & \
    sleep 5 && \
    ollama pull qwen3:4b

# Data Directory
VOLUME ["/root/.ollama"]
