from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from PIL import Image
import pytesseract
import os
import json
from scheme_utils import (
    search_schemes,
    get_schemes_by_category,
    get_scheme_by_title
)


# =========================
# APP CONFIG
# =========================
app = Flask(__name__)
CORS(app)

# =========================
# SCHEME DATA LOAD
# =========================
with open("schemes.json", "r", encoding="utf-8") as f:
    schemes_data = json.load(f)


app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10 MB

# Windows Tesseract path
pytesseract.pytesseract.tesseract_cmd = r"C:\Program Files\Tesseract-OCR\tesseract.exe"

db = SQLAlchemy(app)
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# =========================
# DATABASE MODEL
# =========================
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    full_name = db.Column(db.String(100), nullable=False)
    dob = db.Column(db.String(20))
    location = db.Column(db.String(100))
    nationality = db.Column(db.String(50))
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    occupation = db.Column(db.String(50))
    qualification = db.Column(db.String(50))
    marital_status = db.Column(db.String(20))
    password = db.Column(db.String(200), nullable=False)

with app.app_context():
    db.create_all()

# =========================
# SIGNUP API
# =========================
@app.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()

    if not data:
        return jsonify(success=False, message="Invalid request"), 400

    if User.query.filter_by(email=data.get('email')).first():
        return jsonify(success=False, message="Email already registered"), 400

    user = User(
        full_name=data.get('full_name'),
        dob=data.get('dob'),
        location=data.get('location'),
        nationality=data.get('nationality'),
        email=data.get('email'),
        phone=data.get('phone'),
        occupation=data.get('occupation'),
        qualification=data.get('qualification'),
        marital_status=data.get('maritalStatus'),
        password=generate_password_hash(data.get('password'))
    )

    db.session.add(user)
    db.session.commit()

    return jsonify(
        success=True,
        message="Signup successful"
    ), 200

# =========================
# LOGIN API
# =========================
@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    if not data:
        return jsonify(success=False, message="Invalid request"), 400

    user = User.query.filter_by(email=data.get('email')).first()

    if not user:
        return jsonify(success=False, message="User not found"), 401

    if not check_password_hash(user.password, data.get('password')):
        return jsonify(success=False, message="Invalid credentials"), 401

    return jsonify(
        success=True,
        message="Login successful",
        user={
            "full_name": user.full_name,
            "email": user.email,
            "dob": user.dob,
            "location": user.location,
            "nationality": user.nationality,
            "phone": user.phone,
            "occupation": user.occupation,
            "qualification": user.qualification,
            "maritalStatus": user.marital_status
        }
    ), 200

# =========================
# MYDOCS OCR UPLOAD API
# =========================
@app.route('/upload-document', methods=['POST'])
def upload_document():
    if 'file' not in request.files:
        return jsonify(success=False, message="No file uploaded"), 400

    file = request.files['file']

    if file.filename == "":
        return jsonify(success=False, message="Empty file"), 400

    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)

    try:
        image = Image.open(filepath)
        extracted_text = pytesseract.image_to_string(image)

        return jsonify(
            success=True,
            extracted_text=extracted_text.strip()
        ), 200

    except Exception as e:
        return jsonify(
            success=False,
            message="OCR failed",
            error=str(e)
        ), 500

# =========================
# SCHEME APIs
# =========================

@app.route("/api/schemes/search", methods=["POST"])
def scheme_search():
    data = request.get_json(force=True)
    query = data.get("query", "")
    return jsonify(search_schemes(query, schemes_data))


@app.route("/api/schemes/category", methods=["POST"])
def scheme_category():
    category_name = request.json.get("category", "")

    # 🔍 DEBUG TESTING (DOES NOT AFFECT LOGIC)
    print("DEBUG /api/schemes/category received:", repr(category_name))

    return jsonify(get_schemes_by_category(category_name, schemes_data))


@app.route("/api/schemes/details", methods=["POST"])
def scheme_details():
    title = request.json.get("title")
    scheme = get_scheme_by_title(title, schemes_data)

    if scheme:
        return jsonify(scheme)
    return jsonify({"error": "Scheme not found"}), 404


@app.route("/api/schemes/carousel", methods=["GET"])
def scheme_carousel():
    titles = []

    for block in schemes_data:
        for scheme in block["schemes"]:
            titles.append(scheme["title"])
            if len(titles) == 5:
                return jsonify(titles)

    return jsonify(titles)

# =========================
# RUN SERVER
# =========================
if __name__ == '__main__':
    app.run(debug=True)
