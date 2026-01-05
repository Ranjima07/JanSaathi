import json
import os
import uuid
import time
from pathlib import Path
from dotenv import load_dotenv
import ollama
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

# 1. PATH SETUP
BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(dotenv_path=BASE_DIR / '.env')

QDRANT_URL = os.getenv("QDRANT_URL")
QDRANT_API_KEY = os.getenv("QDRANT_API_KEY")
COLLECTION_NAME = "schemes"

# Timeout set to 120s to give the network plenty of breathing room
client = QdrantClient(url=QDRANT_URL, api_key=QDRANT_API_KEY, timeout=120)

def split_content_by_headers(content):
    headers = ["Details", "Benefits", "Eligibility", "Exclusions", 
               "Application Process", "Documents Required", "Frequently Asked Questions"]
    sections = {}
    current_header = "General"
    lines = content.split('\n')
    for line in lines:
        clean_line = line.strip()
        if clean_line in headers:
            current_header = clean_line
            sections[current_header] = []
        else:
            if current_header not in sections:
                sections[current_header] = []
            sections[current_header].append(clean_line)
    return {k: "\n".join(v).strip() for k, v in sections.items() if v}

def safe_upsert(points, batch_num):
    """Attempts to upload a batch of 5 schemes with 5 retries on failure."""
    max_retries = 5
    for attempt in range(max_retries):
        try:
            client.upsert(collection_name=COLLECTION_NAME, points=points)
            print(f"   ✅ Batch {batch_num} uploaded successfully ({len(points)} vectors).")
            return True
        except Exception as e:
            print(f"   ⚠️ Connection dropped on batch {batch_num} (Attempt {attempt+1}/{max_retries}). Retrying in 10s...")
            time.sleep(10)
    return False

def run_ingestion():
    json_path = BASE_DIR.parent / "data" / "scheme.json"
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    all_points = []
    batch_counter = 1
    print(f"🔍 Starting batch ingestion (5 schemes per batch) for {len(data)} items...")

    for i, scheme in enumerate(data):
        title = scheme.get("title", "").strip()
        content = scheme.get("content", "").strip()
        if not title and not content: continue

        print(f"➡️ [{i+1}/{len(data)}] Processing: {title}")
        sections = split_content_by_headers(content)

        for section_name, section_text in sections.items():
            if len(section_text) < 10: continue
            
            text_to_embed = f"Scheme: {title} | Section: {section_name} | Content: {section_text}"
            
            try:
                embed_res = ollama.embeddings(model="nomic-embed-text", prompt=text_to_embed)
                vector = embed_res["embedding"]
                all_points.append(PointStruct(
                    id=str(uuid.uuid4()),
                    vector=vector,
                    payload={
                        "title": title,
                        "category": scheme.get("category"),
                        "section": section_name,
                        "text": section_text,
                        "url": scheme.get("scheme_url")
                    }
                ))
            except Exception as e:
                print(f"❌ Ollama local error: {e}")

        # Upload every 5 schemes
        if (i + 1) % 5 == 0 and all_points:
            success = safe_upsert(all_points, batch_counter)
            if not success:
                print(f"🛑 Error: Failed to upload batch {batch_counter} after multiple retries.")
            all_points = []
            batch_counter += 1

    # Final check for remaining points
    if all_points:
        safe_upsert(all_points, "Final")

    print("🎉 All schemes processed!")

if __name__ == "__main__":
    # Ensure collection exists
    try:
        collections = client.get_collections().collections
        if not any(c.name == COLLECTION_NAME for c in collections):
            client.create_collection(
                collection_name=COLLECTION_NAME,
                vectors_config=VectorParams(size=768, distance=Distance.COSINE),
            )
    except Exception as e:
        print(f"Initial connection error: {e}")
        
    run_ingestion()