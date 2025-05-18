import { getCookie } from "./cookies";

const API_URL = "http://192.168.100.8:5000";

// utils/api.js

const CSRF_HEADER = "X-CSRF-TOKEN";
const MUTATING_METHODS = ["POST", "PUT", "PATCH", "DELETE"];
const CSRF_COOKIE = {
  access: "csrf_access_token",
  refresh: "csrf_refresh_token",
};

export function getCsrfHeader(path, method) {
  if (!MUTATING_METHODS.includes(method)) {
    return {};
  }

  // Pick the right CSRF cookie for refresh vs. other endpoints
  const cookieName = path.startsWith("/auth/refresh")
    ? CSRF_COOKIE.refresh
    : CSRF_COOKIE.access;

  const token = getCookie(cookieName);
  return token ? { [CSRF_HEADER]: token } : {};
}


/**
 * Universal API request.
 * @param {string} path
 * @param {object} options - { method, data, formData, withCredentials, headers }
 */
export async function apiRequest(
  path,
  { method = "GET", data = null, formData = null, withCredentials = true, ...rest } = {}
) {
  let headers = rest.headers || {};
  let body;

  // Support both JSON and FormData
  if (formData) {
    body = formData;
    // Do NOT set Content-Type header for FormData! Browser will set it with the correct boundary.
  } else if (data) {
    body = JSON.stringify(data);
    headers["Content-Type"] = "application/json";
  }

  // Add CSRF automatically if required
  headers = { ...headers, ...getCsrfHeader(path, method) };

  const options = {
    method,
    headers,
    credentials: withCredentials ? "include" : "same-origin",
    ...rest,
  };
  if (body) options.body = body;

  const res = await fetch(API_URL + path, options);

  // Try to auto-parse JSON, fall back to blob for images/files
  const contentType = res.headers.get("Content-Type") || "";
  if (!res.ok) {
    // Try to parse JSON error
    let err;
    try { err = await res.json(); } catch { err = { message: res.statusText }; }
    throw err;
  }
  if (contentType.includes("application/json")) {
    return res.json();
  } else if (contentType.startsWith("image/")) {
    return res.blob();
  } else {
    return res.text();
  }
}