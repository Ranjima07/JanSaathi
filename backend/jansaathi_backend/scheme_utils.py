def normalize_text(text):
    return text.lower()


# Simple synonym mapping (can expand later)
SYNONYM_MAP = {
    "farmer": ["agriculture", "crop", "rural"],
    "student": ["education", "college", "school"],
    "women": ["girl", "female", "mother"],
    "health": ["medical", "hospital", "cancer"],
    "job": ["employment", "skill", "training"]
}


def expand_keywords(query):
    words = query.lower().split()
    expanded = set(words)

    for word in words:
        if word in SYNONYM_MAP:
            expanded.update(SYNONYM_MAP[word])

    return expanded


# 🔍 SEARCH
def search_schemes(query, data):
    keywords = expand_keywords(query)
    results = []

    for block in data:
        category_name = str(block.get("category", "")).lower()

        schemes = block.get("schemes", [])
        if not isinstance(schemes, list):
            continue

        for scheme in schemes:
            title = str(scheme.get("title", ""))
            content = scheme.get("content", {})

            full_text = title + " " + category_name + " "

            if isinstance(content, dict):
                for value in content.values():
                    if isinstance(value, list):
                        for item in value:
                            full_text += str(item) + " "
                    elif isinstance(value, str):
                        full_text += value + " "

            full_text = full_text.lower()

            if any(keyword in full_text for keyword in keywords):
                results.append({
                    "title": title,
                    "scheme_url": scheme.get("scheme_url"),
                    "is_closed": scheme.get("is_closed", False)
                })

    return results


# 📂 CATEGORY FILTER
def get_schemes_by_category(category, data):
    def normalize(text):
        return (
            text.lower()
            .replace(" ", "")
            .replace(",", "")
            .replace("&", "")
        )

    requested = normalize(category)
    results = []

    for block in data:
        block_category = normalize(block.get("category", ""))

        if requested == block_category:
            schemes = block.get("schemes", [])
            if not isinstance(schemes, list):
                continue

            for scheme in schemes:
                results.append({
                    "title": scheme.get("title"),
                    "scheme_url": scheme.get("scheme_url"),
                    "is_closed": scheme.get("is_closed", False)
                })

    return results



# 📄 SINGLE SCHEME
def get_scheme_by_title(title, data):
    for block in data:
        for scheme in block["schemes"]:
            if scheme["title"] == title:
                return {
                    "title": scheme["title"],
                    "category": block["category"],
                    "scheme_url": scheme.get("scheme_url"),
                    "is_closed": scheme.get("is_closed", False),
                    "content": scheme["content"]
                }

    return None

