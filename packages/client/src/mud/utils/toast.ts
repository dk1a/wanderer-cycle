import { toast } from "react-toastify";

export const toastCalling = async (
  promise: Promise<unknown> | (() => Promise<unknown>),
  loadingRender: string,
  successRender: string
) => {
  await toast.promise(promise, {
    pending: {
      style: {
        borderRadius: "0",
        padding: "10px",
        border: "1px solid #3c3c3c",
        backgroundColor: "#252526",
      },
      render: loadingRender,
      icon: false,
      position: "bottom-right",
      autoClose: 0,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: false,
      theme: "dark",
    },
    success: {
      style: {
        borderRadius: "0",
        padding: "10px",
        border: "1px solid #3c3c3c",
        backgroundColor: "#252526",
      },
      render: successRender,
      icon: false,
      position: "bottom-right",
      autoClose: 2000,
      closeOnClick: true,
      pauseOnHover: true,
      draggable: false,
      theme: "dark",
    },
    error: "error",
  });
};
