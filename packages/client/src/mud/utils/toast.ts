import { ToastContent } from "react-toastify";

export const defaultToastOptions = {
  style: {
    borderRadius: "0",
    padding: "10px",
    border: "1px solid #3c3c3c",
    backgroundColor: "#252526",
  },
  icon: false,
  position: "bottom-right",
  autoClose: 2500,
  hideProgressBar: true,
  closeOnClick: true,
  pauseOnHover: true,
  draggable: false,
  theme: "dark",
} as const;
