"""Claude Code Proxy

A proxy server that enables Claude Code to work with OpenAI-compatible API providers.
"""

from pathlib import Path
from dotenv import load_dotenv

# Load environment variables from .env file in project root
# Use override=True to ensure .env takes precedence over system environment variables
project_root = Path(__file__).parent.parent
env_path = project_root / '.env'
load_dotenv(dotenv_path=env_path, override=True)

__version__ = "1.0.0"
__author__ = "Claude Code Proxy"
