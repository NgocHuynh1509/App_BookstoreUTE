import React, { useMemo, useEffect, useState } from "react";
import { SafeAreaView } from "react-native-safe-area-context";
import { View, Text, StyleSheet, TouchableOpacity, ActivityIndicator } from "react-native";
import { useNavigation, useRoute } from "@react-navigation/native";
import { WebView } from "react-native-webview";
import { Ionicons } from "@expo/vector-icons";

// ─── Không dùng expo-file-system (API thay đổi mạnh ở v19),
//     thay bằng fetch() + FileReader sẵn có trong React Native ───────────────

const C = {
  primary: "#0D5CB6",
  primaryMid: "#1A94FF",
  bg: "#F5F7FA",
  text1: "#1F2937",
  text2: "#6B7280",
};

// ─── Google Drive helpers ────────────────────────────────────────────────────

/**
 * Trích xuất file ID từ bất kỳ dạng URL Drive nào:
 *   /d/FILE_ID/view  |  /d/FILE_ID  |  ?id=FILE_ID
 */
function extractDriveId(url: string): string | null {
  if (!url) return null;
  const m1 = url.match(/\/d\/([a-zA-Z0-9_-]+)/);
  if (m1?.[1]) return m1[1];
  const m2 = url.match(/[?&]id=([a-zA-Z0-9_-]+)/);
  if (m2?.[1]) return m2[1];
  return null;
}

/**
 * Chuyển Google Drive share link thành URL direct-download.
 * Dùng drive.usercontent.google.com (domain mới 2024) + confirm=t
 * để bypass trang cảnh báo virus scan với file nhỏ/vừa.
 */
function toDirectDownloadUrl(url: string): string {
  if (!url) return url;
  const id = extractDriveId(url);
  if (id) {
    return `https://drive.usercontent.google.com/download?id=${id}&export=download&authuser=0&confirm=t`;
  }
  return url;
}

// ─── Tải PDF dưới dạng base64 (không cần expo-file-system) ──────────────────

async function fetchPdfAsBase64(url: string): Promise<string> {
  const resp = await fetch(url, {
    headers: { Accept: "application/pdf, application/octet-stream, */*" },
  });
  if (!resp.ok) {
    throw new Error(`Tải file thất bại (HTTP ${resp.status})`);
  }
  const blob = await resp.blob();
  return new Promise<string>((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => {
      const result = reader.result as string;
      // Bỏ prefix "data:application/pdf;base64," lấy phần base64 thuần
      resolve(result.replace(/^data:[^;]*;base64,/, ""));
    };
    reader.onerror = () => reject(new Error("Lỗi đọc dữ liệu file (FileReader)"));
    reader.readAsDataURL(blob);
  });
}

// ─── WebView HTML + pdf.js viewer ────────────────────────────────────────────

function buildFlipHtml(base64Pdf: string): string {
  return `<!doctype html>
<html lang="vi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1" />
  <style>
    html, body {
      margin: 0; padding: 0; width: 100%; height: 100%;
      background: #0f172a; overflow: hidden;
    }
    #root { width: 100%; height: 100%; position: relative; }
    #book {
      width: 100%; height: 100%;
      perspective: 1200px;
      display: flex; align-items: center; justify-content: center;
    }
    #pageWrap {
      width: 96%; height: 96%;
      transform-style: preserve-3d;
      transition: transform 0.22s cubic-bezier(0.4,0,0.2,1);
    }
    #pageWrap.flip-next { transform: rotateY(-16deg) scale(0.97); }
    #pageWrap.flip-prev { transform: rotateY(16deg)  scale(0.97); }
    canvas {
      width: 100%; height: 100%;
      object-fit: contain;
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 14px 40px rgba(0,0,0,.45);
      display: block;
    }
    #hud {
      position: absolute; left: 12px; right: 12px; bottom: 14px;
      display: flex; justify-content: space-between; align-items: center;
      color: #fff; font-family: Arial, sans-serif; font-size: 12px;
      pointer-events: none; user-select: none;
    }
    #pager { background: rgba(0,0,0,.45); padding: 2px 8px; border-radius: 10px; }
    #swipeHint { opacity: .7; font-size: 11px; }
    /* loading overlay */
    #loading {
      position: absolute; inset: 0; z-index: 20;
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      color: #fff; font-family: Arial, sans-serif;
      background: #0f172a;
    }
    .sp {
      width: 40px; height: 40px;
      border: 4px solid rgba(255,255,255,.15);
      border-top-color: #1A94FF;
      border-radius: 50%;
      animation: spin .75s linear infinite;
      margin-bottom: 14px;
    }
    @keyframes spin { to { transform: rotate(360deg); } }
    #loadTxt { font-size: 14px; opacity: .85; }
    /* error overlay */
    #errBox {
      display: none; position: absolute; inset: 0; z-index: 20;
      flex-direction: column; align-items: center; justify-content: center;
      color: #fff; font-family: Arial, sans-serif;
      background: #0f172a; padding: 28px; text-align: center;
    }
    #errBox h3 { margin: 0 0 10px; font-size: 16px; }
    #errMsg { font-size: 13px; opacity: .8; line-height: 1.5; }
  </style>
</head>
<body>
  <div id="root">
    <div id="book">
      <div id="pageWrap">
        <canvas id="canvas"></canvas>
      </div>
    </div>
    <div id="loading">
      <div class="sp"></div>
      <span id="loadTxt">Đang tải trang đọc thử...</span>
    </div>
    <div id="errBox">
      <h3>Không thể hiển thị đọc thử</h3>
      <p id="errMsg"></p>
    </div>
    <div id="hud">
      <span id="pager"></span>
      <span id="swipeHint">&#8592; Vuốt để lật trang &#8594;</span>
    </div>
  </div>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js"></script>
  <script>
  (function () {
    /* eslint-disable no-undef */
    const rnwv = window['ReactNativeWebView'];
    const send = function (type, msg) {
      try {
        if (rnwv && rnwv.postMessage) {
          rnwv.postMessage(JSON.stringify({ type: type, message: String(msg) }));
        }
      } catch (_) {}
    };

    const loadingEl = document.getElementById('loading');
    const loadTxtEl  = document.getElementById('loadTxt');
    const errBoxEl   = document.getElementById('errBox');
    const errMsgEl   = document.getElementById('errMsg');
    const pagerEl    = document.getElementById('pager');
    const wrapEl     = document.getElementById('pageWrap');
    const canvas     = document.getElementById('canvas');
    const ctx        = canvas.getContext('2d');

    function showErr(msg) {
      loadingEl.style.display = 'none';
      errBoxEl.style.display  = 'flex';
      errMsgEl.textContent    = msg || '';
      send('error', msg);
    }

    window.addEventListener('error', function (e) {
      send('error', e.message || 'js_error');
    });

    /* ── Kiểm tra pdf.js đã load chưa ── */
    if (typeof window.pdfjsLib === 'undefined') {
      showErr('Không tải được thư viện PDF (cdnjs). Vui lòng kiểm tra kết nối mạng.');
      return;
    }

    const pdfjs = window.pdfjsLib;
    pdfjs.GlobalWorkerOptions.workerSrc =
      'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js';

    let pdfDoc      = null;
    let currentPage = 1;
    let totalPages  = 1;
    let startX      = 0;
    let busy        = false;

    function renderPage(num) {
      if (!pdfDoc) return Promise.resolve();
      busy = true;
      return pdfDoc.getPage(num).then(function (page) {
        const vp   = page.getViewport({ scale: 1 });
        const maxW = window.innerWidth  * 0.96;
        const maxH = window.innerHeight * 0.96;
        const sc   = Math.min(maxW / vp.width, maxH / vp.height);
        const svp  = page.getViewport({ scale: sc });
        canvas.width  = svp.width;
        canvas.height = svp.height;
        return page.render({ canvasContext: ctx, viewport: svp }).promise;
      }).then(function () {
        pagerEl.textContent = currentPage + ' / ' + totalPages;
        busy = false;
      });
    }

    function flipNext() {
      if (busy || currentPage >= totalPages) return;
      wrapEl.classList.add('flip-next');
      setTimeout(function () {
        currentPage += 1;
        renderPage(currentPage).then(function () {
          setTimeout(function () { wrapEl.classList.remove('flip-next'); }, 30);
        });
      }, 160);
    }

    function flipPrev() {
      if (busy || currentPage <= 1) return;
      wrapEl.classList.add('flip-prev');
      setTimeout(function () {
        currentPage -= 1;
        renderPage(currentPage).then(function () {
          setTimeout(function () { wrapEl.classList.remove('flip-prev'); }, 30);
        });
      }, 160);
    }

    document.addEventListener('touchstart', function (e) {
      startX = e.changedTouches[0].clientX;
    }, { passive: true });

    document.addEventListener('touchend', function (e) {
      const diff = e.changedTouches[0].clientX - startX;
      if (Math.abs(diff) < 40) return;
      if (diff < 0) flipNext(); else flipPrev();
    }, { passive: true });

    /* ── Load base64 → ArrayBuffer → pdf.js ── */
    const b64 = ${JSON.stringify(base64Pdf)};
    loadTxtEl.textContent = 'Đang xử lý tài liệu...';

    fetch('data:application/pdf;base64,' + b64)
      .then(function (r) { return r.arrayBuffer(); })
      .then(function (buf) {
        return pdfjs.getDocument({ data: buf, disableWorker: true }).promise;
      })
      .then(function (doc) {
        pdfDoc      = doc;
        totalPages  = Math.min(doc.numPages, 40);
        loadTxtEl.textContent = 'Đang hiển thị trang...';
        return renderPage(1);
      })
      .then(function () {
        loadingEl.style.display = 'none';
        send('ready', 'ok');
      })
      .catch(function (err) {
        showErr('Lỗi render PDF: ' + String(err));
      });
  }());
  </script>
</body>
</html>`;
}

// ─── Component ───────────────────────────────────────────────────────────────

export default function BookPreviewScreen() {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const title: string = route.params?.title ?? "Đọc thử";
  const rawUrl: string = route.params?.pdfUrl ?? "";

  // Chuyển share link → direct download URL
  const pdfUrl = useMemo(() => toDirectDownloadUrl(rawUrl), [rawUrl]);

  const [pdfBase64, setPdfBase64]     = useState<string | null>(null);
  const [loading, setLoading]         = useState(false);
  const [errorText, setErrorText]     = useState<string | null>(null);
  const [viewerReady, setViewerReady] = useState(false);
  const [retrySeed, setRetrySeed]     = useState(0);

  // Tải PDF khi URL hoặc retry thay đổi
  useEffect(() => {
    let mounted = true;
    if (!pdfUrl) return;

    setLoading(true);
    setErrorText(null);
    setPdfBase64(null);
    setViewerReady(false);

    fetchPdfAsBase64(pdfUrl)
      .then((base64) => {
        if (mounted) setPdfBase64(base64);
      })
      .catch((err: unknown) => {
        if (mounted) {
          const msg = err instanceof Error ? err.message : "Không thể tải bản đọc thử.";
          setErrorText(msg);
        }
      })
      .finally(() => {
        if (mounted) setLoading(false);
      });

    return () => {
      mounted = false;
    };
  }, [pdfUrl, retrySeed]);

  // Timeout 20s nếu viewer không phản hồi
  useEffect(() => {
    if (!pdfBase64 || viewerReady || errorText) return;
    const t = setTimeout(() => {
      setErrorText("WebView không phản hồi, vui lòng thử lại.");
    }, 20000);
    return () => clearTimeout(t);
  }, [pdfBase64, viewerReady, errorText]);

  return (
    <SafeAreaView style={s.container}>
      {/* Header */}
      <View style={s.header}>
        <TouchableOpacity onPress={() => navigation.goBack()} style={s.backBtn}>
          <Ionicons name="chevron-back" size={22} color="#FFFFFF" />
        </TouchableOpacity>
        <Text style={s.headerTitle} numberOfLines={1}>{title}</Text>
        <View style={{ width: 36 }} />
      </View>

      {/* Body */}
      {!pdfUrl ? (
        <View style={s.center}>
          <Text style={s.emptyTitle}>Chưa có dữ liệu đọc thử</Text>
          <Text style={s.sub}>Vui lòng thử lại sau hoặc chọn sách khác.</Text>
        </View>
      ) : loading ? (
        <View style={s.center}>
          <ActivityIndicator size="large" color={C.primaryMid} />
          <Text style={s.loadTxt}>Đang tải bản đọc thử...</Text>
        </View>
      ) : pdfBase64 ? (
        <WebView
          style={{ flex: 1 }}
          originWhitelist={["*"]}
          source={{
            html: buildFlipHtml(pdfBase64),
            // baseUrl bắt buộc để WebView cho phép load script từ cdnjs CDN
            baseUrl: "https://cdnjs.cloudflare.com",
          }}
          javaScriptEnabled
          domStorageEnabled
          // Android: cho phép mixed HTTP/HTTPS content
          mixedContentMode="always"
          allowFileAccess
          allowUniversalAccessFromFileURLs
          allowFileAccessFromFileURLs
          thirdPartyCookiesEnabled
          onMessage={(e) => {
            try {
              const p = JSON.parse(e.nativeEvent.data) as { type: string };
              if (p?.type === "ready") setViewerReady(true);
              if (p?.type === "error") setErrorText("Không thể render PDF. Hãy thử lại.");
            } catch {
              /* ignore */
            }
          }}
        />
      ) : (
        <View style={s.center}>
          <Text style={s.sub}>Không tải được bản đọc thử.</Text>
        </View>
      )}

      {/* Error overlay */}
      {errorText && (
        <View style={s.errOverlay}>
          <Text style={s.errTitle}>Không thể hiển thị đọc thử</Text>
          <Text style={s.errSub}>{errorText}</Text>
          <TouchableOpacity
            style={s.retryBtn}
            onPress={() => setRetrySeed((v) => v + 1)}
          >
            <Text style={s.retryTxt}>Thử lại</Text>
          </TouchableOpacity>
        </View>
      )}
    </SafeAreaView>
  );
}

const s = StyleSheet.create({
  container: { flex: 1, backgroundColor: C.bg },
  header: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: C.primary,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  backBtn: {
    width: 36, height: 36, borderRadius: 18,
    alignItems: "center", justifyContent: "center",
    backgroundColor: "rgba(255,255,255,0.18)",
  },
  headerTitle: {
    flex: 1, color: "#FFF", fontSize: 16, fontWeight: "700", marginLeft: 10,
  },
  center: { flex: 1, alignItems: "center", justifyContent: "center", padding: 24 },
  emptyTitle: { fontSize: 16, fontWeight: "700", color: C.text1, marginBottom: 6 },
  sub: { fontSize: 13, color: C.text2, textAlign: "center" },
  loadTxt: { marginTop: 10, color: C.text2 },
  errOverlay: {
    position: "absolute", left: 16, right: 16, bottom: 24,
    backgroundColor: "rgba(13,92,182,0.95)",
    padding: 14, borderRadius: 12,
  },
  errTitle: { color: "#FFF", fontSize: 14, fontWeight: "700", marginBottom: 4 },
  errSub: { color: "#EAF2FF", fontSize: 12, lineHeight: 18 },
  retryBtn: {
    marginTop: 10, alignSelf: "flex-start",
    backgroundColor: "#FFF", borderRadius: 10,
    paddingHorizontal: 12, paddingVertical: 8,
  },
  retryTxt: { color: C.primary, fontWeight: "700", fontSize: 13 },
});
