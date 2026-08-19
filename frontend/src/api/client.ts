import axios from "axios";
import i18n from "../i18n";

const baseURL = import.meta.env.VITE_API_BASE_URL ?? "/api/v1";

const client = axios.create({ baseURL });

client.interceptors.request.use((cfg) => {
  const token = localStorage.getItem("jwt");
  if (token) {
    cfg.headers.Authorization = `Bearer ${token}`;
  }
  cfg.headers["Accept-Language"] = i18n.language;
  return cfg;
});

client.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem("jwt");
      localStorage.removeItem("user");
      if (window.location.pathname !== "/login") {
        window.location.assign("/login");
      }
    }
    return Promise.reject(err);
  },
);

export default client;
