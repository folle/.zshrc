# Prioritize Homebrew OpenSSH
export PATH="/opt/homebrew/opt/openssh/bin:$PATH"

# File to store agent environment variables
SSH_ENV="$HOME/.ssh/agent.env"

# Load existing agent environment if present
if [ -f "$SSH_ENV" ]; then
    source "$SSH_ENV" >/dev/null 2>&1
fi

# Check for stale agent and terminate it
if [ -z "$SSH_AGENT_PID" ] || \
   ! kill -0 "$SSH_AGENT_PID" 2>/dev/null || \
   [ ! -S "$SSH_AUTH_SOCK" ]; then

    kill "$SSH_AGENT_PID" 2>/dev/null || true
    rm -f "$SSH_AUTH_SOCK" 2>/dev/null
    unset SSH_AGENT_PID SSH_AUTH_SOCK

    echo "Terminated stale ssh-agent"
fi

# Start agent if needed
if [ -z "$SSH_AGENT_PID" ]; then
    SSH_VARS=$(ssh-agent -s 2>&1 | grep '^SSH_')

    if [ -n "$SSH_VARS" ]; then
        eval "$SSH_VARS"
        echo "$SSH_VARS" > "$SSH_ENV"
    else
        echo "Failed to start ssh-agent: $AGENT_OUTPUT"
    fi
fi

export SSH_AUTH_SOCK
export SSH_AGENT_PID

# Ensure Git uses Homebrew OpenSSH
export GIT_SSH_COMMAND="/opt/homebrew/bin/ssh"
