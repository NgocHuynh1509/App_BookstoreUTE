import os
import sys
import json
import re
from functools import lru_cache

import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans
from sklearn.metrics.pairwise import cosine_similarity

print("PYTHON SCRIPT STARTED", file=sys.stderr)

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")


BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE_DIR, "books_latest.csv")
SIM_PATH = os.path.join(BASE_DIR, "sim_matrix.csv")


def clean_text(text):
    if not isinstance(text, str):
        return ""
    text = text.lower()
    text = re.sub(r"[^\w\s]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def prepare_ml_text(df):
    df = df.copy()

    # đảm bảo các cột cần thiết tồn tại
    for col in ["bookId", "title", "author", "description"]:
        if col not in df.columns:
            raise ValueError(f"Thiếu cột bắt buộc: {col}")

    df["title"] = df["title"].fillna("")
    df["author"] = df["author"].fillna("")
    df["description"] = df["description"].fillna("")

    df["ml_text"] = (
            df["title"] + " " +
            df["author"] + " " +
            df["description"]
    ).apply(clean_text)

    # bỏ dòng không có nội dung
    df = df[df["ml_text"] != ""].copy()

    # ép bookId về string để đồng nhất key
    df["bookId"] = df["bookId"].astype(str)

    # reset index để ma trận và df luôn khớp 1-1
    df = df.reset_index(drop=True)

    return df


def should_rebuild(csv_path, sim_path):
    if not os.path.exists(csv_path):
        return False

    if not os.path.exists(sim_path):
        print("sim_matrix.csv chưa tồn tại -> cần build", file=sys.stderr)
        return True

    csv_mtime = os.path.getmtime(csv_path)
    sim_mtime = os.path.getmtime(sim_path)

    if csv_mtime > sim_mtime:
        print("books_latest.csv mới hơn sim_matrix.csv -> cần rebuild", file=sys.stderr)
        return True

    return False


def build_similarity_matrix(df):
    if df.empty or "ml_text" not in df.columns:
        raise ValueError("DataFrame rỗng hoặc thiếu ml_text")

    tfidf = TfidfVectorizer(
        max_df=0.85,
        min_df=2,
        ngram_range=(1, 2),
        max_features=5000
    )
    tfidf_matrix = tfidf.fit_transform(df["ml_text"])

    # tránh lỗi nếu số sách quá ít
    n_books = len(df)
    n_clusters = min(7, n_books)

    # nếu chỉ có 1 sách thì ma trận similarity chỉ có 1 phần tử
    if n_books == 1:
        sim_matrix = np.array([[1.0]])
    else:
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        df["cluster"] = kmeans.fit_predict(tfidf_matrix)

        sim_matrix = np.zeros((n_books, n_books))

        for cluster_id in df["cluster"].unique():
            idxs = df[df["cluster"] == cluster_id].index.tolist()

            if len(idxs) == 1:
                sim_matrix[idxs[0], idxs[0]] = 1.0
                continue

            vecs = tfidf_matrix[idxs]
            cluster_sim = cosine_similarity(vecs)

            for i, row_i in enumerate(idxs):
                for j, col_j in enumerate(idxs):
                    sim_matrix[row_i, col_j] = cluster_sim[i, j]

    sim_df = pd.DataFrame(
        sim_matrix,
        index=df["bookId"],
        columns=df["bookId"]
    )

    return df, sim_df


def save_similarity_matrix(sim_df, sim_path):
    sim_df.to_csv(sim_path, encoding="utf-8")
    print(f"Đã lưu sim_matrix tại: {sim_path}", file=sys.stderr)


@lru_cache(maxsize=1)
def load_books():
    if not os.path.exists(CSV_PATH):
        print(f"CSV not found at: {CSV_PATH}", file=sys.stderr)
        return None

    print(f"Reading books from: {CSV_PATH}", file=sys.stderr)
    df = pd.read_csv(CSV_PATH, encoding="utf-8")
    df = prepare_ml_text(df)
    return df


@lru_cache(maxsize=1)
def load_similarity():
    if not os.path.exists(SIM_PATH):
        print(f"sim_matrix not found at: {SIM_PATH}", file=sys.stderr)
        return None

    print(f"Reading similarity from: {SIM_PATH}", file=sys.stderr)
    sim_df = pd.read_csv(SIM_PATH, index_col=0, encoding="utf-8")

    # đồng nhất index/columns về string
    sim_df.index = sim_df.index.astype(str)
    sim_df.columns = sim_df.columns.astype(str)

    return sim_df


def ensure_cache_ready():
    df = load_books()
    if df is None or df.empty:
        return None, None

    if should_rebuild(CSV_PATH, SIM_PATH):
        print("Đang build lại mô hình...", file=sys.stderr)
        df_built, sim_df = build_similarity_matrix(df)
        save_similarity_matrix(sim_df, SIM_PATH)

        # clear cache cũ rồi load lại cho chắc
        load_similarity.cache_clear()
        sim_df = load_similarity()

        return df_built, sim_df

    sim_df = load_similarity()

    # nếu file sim lỗi / thiếu thì build lại
    if sim_df is None:
        print("Không load được sim_matrix, build lại...", file=sys.stderr)
        df_built, sim_df = build_similarity_matrix(df)
        save_similarity_matrix(sim_df, SIM_PATH)

        load_similarity.cache_clear()
        sim_df = load_similarity()

        return df_built, sim_df

    return df, sim_df


def recommend_books(book_id, df, sim_df, top_k=6, include_self=False):
    if df is None or df.empty or sim_df is None or sim_df.empty:
        return []

    book_id = str(book_id)

    if book_id not in sim_df.columns:
        print(f"BookId {book_id} không tồn tại trong sim_matrix", file=sys.stderr)
        return []

    similarities = sim_df[book_id].sort_values(ascending=False)

    results = []

    for other_id, score in similarities.items():
        other_id = str(other_id)

        if not include_self and other_id == book_id:
            continue

        book = df[df["bookId"] == other_id]
        if book.empty:
            continue

        row = book.iloc[0]
        results.append({
            "bookId": other_id,
            "title": row.get("title", ""),
            "author": row.get("author", ""),
            "score": float(score)
        })

        if len(results) >= top_k:
            break

    return results

# Trong ml.py
def load_only_mode():
    """Chế độ chỉ load, không bao giờ build lại"""
    df = load_books()
    sim_df = load_similarity()

    if df is None or sim_df is None:
        # Nếu thiếu file, in ra lỗi để Java bắt được
        print("Error: sim_matrix.csv missing. Please build first.", file=sys.stderr)
        return None, None

    return df, sim_df


if __name__ == "__main__":
    book_id = sys.argv[1] if len(sys.argv) > 1 else ""

    if not book_id:
        print("[]")
        sys.exit(0)

    # Thêm logic này: Nếu truyền vào chữ "BUILD_ONLY" thì chỉ chạy khởi tạo rồi thoát
    if book_id == "BUILD_ONLY":
        try:
            ensure_cache_ready()
            print("SUCCESS")
            sys.exit(0)
        except Exception as e:
            print(f"Build error: {e}", file=sys.stderr)
            sys.exit(1)

    try:
        # df, sim_df = ensure_cache_ready()
        # THAY ĐỔI Ở ĐÂY: Dùng load_only_mode thay vì ensure_cache_ready
        df, sim_df = load_only_mode()

        if df is None or sim_df is None:
            print("[]")
            sys.exit(0)

        recs = recommend_books(book_id, df, sim_df, top_k=6, include_self=True)
        print(json.dumps(recs, ensure_ascii=False))

    except Exception as e:
        print(f"Runtime error: {e}", file=sys.stderr)
        print("[]")
        sys.exit(0)