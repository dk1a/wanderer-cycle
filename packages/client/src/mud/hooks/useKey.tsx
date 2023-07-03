import { useEffect } from "react";

type KeyEventHandler = (event: KeyboardEvent) => void;

const useKey = (key: string, handler: KeyEventHandler) => {
  useEffect(() => {
    const eventListener = (event: KeyboardEvent) => {
      if (event.key === key) {
        handler(event);
      }
    };

    document.addEventListener("keydown", eventListener);

    return () => {
      document.removeEventListener("keydown", eventListener);
    };
  }, [key, handler]);

  useEffect(() => {
    const clearKeyPressed = (event: KeyboardEvent) => {
      if (event.key === "Alt") {
        handler(event);
      }
    };

    document.addEventListener("keyup", clearKeyPressed);

    return () => {
      document.removeEventListener("keyup", clearKeyPressed);
    };
  }, [handler]);
};

export default useKey;
