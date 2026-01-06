import time
import json
import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import TimeoutException, WebDriverException

# -------------------- CONFIG --------------------
TEST_MODE = False
TEST_SCHEMES_LIMIT = 10

BASE_URL = "https://www.myscheme.gov.in/search/category/"

categories = [
    "Agriculture,Rural%20&%20Environment",
    "Banking,Financial%20Services%20and%20Insurance",
    "Business%20&%20Entrepreneurship",
    "Education%20&%20Learning",
    "Health%20&%20Wellness",
    "Housing%20&%20Shelter",
    "Public%20Safety,Law%20&%20Justice",
    "Science,IT%20&%20Communications",
    "Skills%20&%20Employment",
    "Social%20Welfare%20&%20Empowerment",
    "Sports%20&%20Culture",
    "Transport%20&%20Infrastructure",
    "Travel%20&%20Tourism",
    "Utility%20&%20Sanitation",
    "Women%20and%20Child"
]

# -------------------- PATH SETUP (MODIFIED) --------------------
# scraper.py -> scraping -> backend -> JANSATHI
PROJECT_ROOT = os.path.dirname(
    os.path.dirname(
        os.path.dirname(os.path.abspath(__file__))
    )
)

DATA_DIR = os.path.join(PROJECT_ROOT, "data")
os.makedirs(DATA_DIR, exist_ok=True)

OUTPUT_FILE = os.path.join(DATA_DIR, "schemes.json")

# -------------------- DRIVER --------------------
def start_driver():
    options = webdriver.ChromeOptions()
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    driver = webdriver.Chrome(options=options)
    driver.maximize_window()
    return driver

def safe_scroll(driver, times=3):
    for _ in range(times):
        driver.execute_script("window.scrollTo(0, document.body.scrollHeight);")
        time.sleep(2)

# -------------------- TITLE --------------------
def extract_title(driver):
    try:
        return driver.find_element(By.CSS_SELECTOR, "main h1").text.strip()
    except:
        return driver.title.split("|")[0].strip()

# -------------------- CONTENT EXTRACTION --------------------
def extract_tab_content(driver):
    sections = {
        "Details": "details",
        "Benefits": "benefits",
        "Eligibility": "eligibility",
        "Application Process": "application-process",
        "Documents Required": "documents-required"
    }

    content = {}

    for section_name, section_id in sections.items():
        try:
            section = WebDriverWait(driver, 10).until(
                EC.presence_of_element_located((By.ID, section_id))
            )

            driver.execute_script("arguments[0].scrollIntoView(true);", section)
            time.sleep(1)

            section_text = section.text.strip()
            if section_text:
                content[section_name] = [section_text]

        except TimeoutException:
            continue

    return content

# -------------------- SCRAPING --------------------
driver = start_driver()
wait = WebDriverWait(driver, 15)

final_data = []

for category in categories:
    category_name = category.replace("%20", " ")
    print(f"\n📂 CATEGORY: {category_name}")

    category_block = {
        "category": category_name,
        "schemes": []
    }

    try:
        driver.get(BASE_URL + category)
        time.sleep(3)
        safe_scroll(driver, times=4)

        scheme_elements = driver.find_elements(
            By.XPATH, "//a[contains(@href,'/schemes/')]"
        )

        scheme_links = list({
            a.get_attribute("href")
            for a in scheme_elements
            if a.get_attribute("href")
        })[:TEST_SCHEMES_LIMIT]

    except Exception:
        scheme_links = []

    if not scheme_links:
        category_block["schemes"] = "No schemes in this category"
        final_data.append(category_block)
        continue

    for i, url in enumerate(scheme_links, 1):
        print(f"   🔹 Scheme {i}/{len(scheme_links)}")

        try:
            driver.get(url)
            time.sleep(3)
            safe_scroll(driver, times=2)

            scheme_data = {
                "scheme_url": url,
                "title": extract_title(driver),
                "content": extract_tab_content(driver)
            }

            category_block["schemes"].append(scheme_data)

        except WebDriverException:
            print("   ⚠️ Browser crashed, restarting driver...")
            driver.quit()
            driver = start_driver()
            wait = WebDriverWait(driver, 15)
            continue

    final_data.append(category_block)

# -------------------- SAVE --------------------
with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
    json.dump(final_data, f, indent=4, ensure_ascii=False)

driver.quit()
print("\n🎉 SCRAPING COMPLETED SUCCESSFULLY")
