
import os
import pandas as pd
from functools import lru_cache

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd
import os
import sys
import re
print("PYTHON SCRIPT STARTED", file=sys.stderr)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

@lru_cache(maxsize=1)

def load_data():
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
        python_dir = current_dir

        csv_path = os.path.join(python_dir, "books_latest.csv")
        sim_path = os.path.join(python_dir, "sim_matrix.csv")

        if not os.path.exists(csv_path):
            print("CSV not found at:", csv_path, file=sys.stderr)
            return None, None

        print("Reading:", csv_path, file=sys.stderr)
        df = pd.read_csv(csv_path, encoding="utf-8")

        sim_matrix = None
        if os.path.exists(sim_path):
            print("Reading:", sim_path, file=sys.stderr)
            sim_matrix = pd.read_csv(sim_path, index_col=0, encoding="utf-8")
        else:
            print("sim_matrix not found, will rebuild.", file=sys.stderr)

        return df, sim_matrix

    except Exception as e:
        print("Load error:", e, file=sys.stderr)
        return None, None

df, sim_matrix = load_data()

if df is not None:
    df = df.copy()

    # Với dữ liệu sách, thường dùng description
    if "description" in df.columns:
        df["description"] = df["description"].fillna("")
        df = df[df["description"].str.strip() != ""]
        df["description"] = (
            df["description"]
            .str.replace(r"\s+", " ", regex=True)
            .str.lower()
            .str.strip()
        )
# Helper functions
def snippet(text, n=250):
    if not isinstance(text, str):
        return ''
    text = text.strip()
    if len(text) <= n:
        return text
    return text[:n].rstrip() + '...'

def get_field(row, candidates):
    """Lấy giá trị từ các cột có thể có"""
    for c in candidates:
        if c in row.index:
            val = row[c]
            if pd.notna(val) and str(val).strip() != '':
                return val
    return 'Không có'


def clean_text(text):
    if not isinstance(text, str):
        return ""
    text = text.lower()
    text = re.sub(r"[^\w\s]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()

def prepare_ml_text(df):
    df = df.copy()

    df["ml_text"] = (
            df["title"].fillna("") + " " +
            df["author"].fillna("") + " " +
            df["description"].fillna("")
    )

    df["ml_text"] = df["ml_text"].apply(clean_text)
    df = df[df["ml_text"] != ""]

    return df




# def create_models(df):
#
#     # ===== CHECK DATA =====
#     if df.empty or "ml_text" not in df.columns:
#         raise ValueError("DataFrame rỗng hoặc thiếu ml_text")
#
#     # ===== TF-IDF =====
#     tfidf = TfidfVectorizer(
#         max_df=0.95,
#         min_df=3,
#         ngram_range=(1, 3),
#         max_features=5000
#     )
#     tfidf_matrix = tfidf.fit_transform(df["ml_text"])
#
#
#     # ===== COSINE SIMILARITY =====
#     similarity_matrix = cosine_similarity(tfidf_matrix)
#
#     # ===== ĐÂY NÈ – ĐOẠN BẠN HỎI =====
#     BASE_DIR = os.path.dirname(os.path.abspath(__file__))
#     SAVE_PATH = os.path.join(BASE_DIR, "sim_matrix.csv")
#
#     sim_df = pd.DataFrame(
#         similarity_matrix,
#         index=df["bookId"].astype(str),
#         columns=df["bookId"].astype(str)
#     )
#
#     sim_df.to_csv(SAVE_PATH, encoding="utf-8")
#     return df, tfidf_matrix, similarity_matrix
#


def create_models(df):
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.cluster import KMeans
    from sklearn.metrics.pairwise import cosine_similarity
    import pandas as pd
    import numpy as np
    import os

    # ===== CHECK DATA =====
    if df.empty or "ml_text" not in df.columns:
        raise ValueError("DataFrame rỗng hoặc thiếu ml_text")

    # ===== TF-IDF =====
    tfidf = TfidfVectorizer(
        max_df=0.85,
        min_df=2,
        ngram_range=(1, 2),
        max_features=5000
    )
    tfidf_matrix = tfidf.fit_transform(df["ml_text"])

    # ===== K-MEANS =====
    n_clusters = 7
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)

    df = df.copy()
    df["cluster"] = kmeans.fit_predict(tfidf_matrix)

    # ===== COSINE THEO CỤM =====
    n = len(df)
    sim_matrix = np.zeros((n, n))  # khác cluster = 0

    for cluster_id in df["cluster"].unique():
        idxs = df[df["cluster"] == cluster_id].index.tolist()

        if len(idxs) < 2:
            continue

        vecs = tfidf_matrix[idxs]
        cluster_sim = cosine_similarity(vecs)

        # gán vào ma trận lớn
        for i, row_i in enumerate(idxs):
            for j, col_j in enumerate(idxs):
                sim_matrix[row_i, col_j] = cluster_sim[i, j]

    # ===== LƯU FILE =====
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))
    SAVE_PATH = os.path.join(BASE_DIR, "sim_matrix.csv")

    sim_df = pd.DataFrame(
        sim_matrix,
        index=df["bookId"].astype(str),
        columns=df["bookId"].astype(str)
    )

    sim_df.to_csv(SAVE_PATH, encoding="utf-8")

    return df, tfidf_matrix, sim_matrix


# def recommend_books(book_id, df, sim_matrix, top_k=5):
#     if sim_matrix is None or sim_matrix.empty:
#         return []
#
#     book_id = str(book_id)
#
#     if book_id not in sim_matrix.columns:
#         return []
#
#     similarities = sim_matrix[book_id].sort_values(ascending=False)
#     similarities = similarities.iloc[1: top_k + 1]
#
#     results = []
#     for other_id, score in similarities.items():
#         book = df[df["bookId"].astype(str) == other_id]
#         if not book.empty:
#             row = book.iloc[0]
#             results.append({
#                 "bookId": other_id,
#                 "title": row.get("title", ""),
#                 "author": row.get("author", ""),
#                 "score": float(score)
#             })
#
#     return results
def recommend_books(book_id, df, sim_matrix, top_k=6):
    if sim_matrix is None or sim_matrix.empty:
        return []

    book_id = str(book_id)

    if book_id not in sim_matrix.columns:
        return []


    similarities = sim_matrix[book_id].sort_values(ascending=False)

    results = []
    # lấy sách gốc
    book = df[df["bookId"].astype(str) == str(book_id)]
    if not book.empty:
        row = book.iloc[0]
        results.append({
            "bookId": str(book_id),
            "title": row.get("title", ""),
            "author": row.get("author", ""),
            "score": 1.0       # điểm tương đồng tuyệt đối cho sách gốc
        })



    for other_id, score in similarities.items():
        if other_id == book_id:
            continue


        book = df[df["bookId"].astype(str) == str(other_id)]
        if book.empty:
            continue

        row = book.iloc[0]

        # Nếu dùng cluster thì lọc cùng cluster
        # if use_cluster and base_cluster is not None:
        #     if row.get("cluster", None) != base_cluster:
        #         continue

        results.append({
            "bookId": str(other_id),
            "title": row.get("title", ""),
            "author": row.get("author", ""),
            "score": float(score)
        })

        if len(results) >= top_k:
            break

    return results
# ================== MODE BACKEND (Spring Boot gọi) ==================
if __name__ == "__main__":
    import sys
    import json

    if df is None:
        print("[]")
        sys.exit(0)

    df = prepare_ml_text(df)
    df, tfidf_matrix, sim_global = create_models(df)

    book_id = sys.argv[1] if len(sys.argv) > 1 else ""

    if not book_id:
        print("[]")
        sys.exit(0)

    sim_df = pd.DataFrame(
        sim_global,
        index=df["bookId"].astype(str),
        columns=df["bookId"].astype(str)
    )

    recs = recommend_books(book_id, df, sim_df, top_k=6)

    print(json.dumps(recs, ensure_ascii=False))