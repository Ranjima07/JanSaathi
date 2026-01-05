import os
from pathlib import Path
from dotenv import load_dotenv
from qdrant_client import QdrantClient

# This loads the variables from the .env file
env_path = Path(__file__).resolve().parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

def test():
    url = os.getenv("QDRANT_URL")
    api_key = os.getenv("QDRANT_API_KEY")

    print(f"Attempting to connect to: {url}")

    try:
        # Initialize the client
        client = QdrantClient(url=url, api_key=api_key)
        
        # Try to get collections
        response = client.get_collections()
        print("✅ Success! Connection to Qdrant Cloud established.")
        print(f"Current Collections: {response.collections}")
        
    except Exception as e:
        print("❌ Connection Failed.")
        print(f"Error details: {e}")

if __name__ == "__main__":
    test()