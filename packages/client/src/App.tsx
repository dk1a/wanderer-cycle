import React from "react";
import { BrowserRouter as Router } from "react-router-dom";
import { Navbar } from "./components/Navbar/Navbar";
import AppRouter from "./AppRouter";

export const App = () => {
  return (
    <Router>
      <div className="app flex flex-col overflow-y-auto">
        <Navbar
          className={
            "bg-dark-400 border-dark-400 text-dark-300 p-6 flex items-center justify-center w-full"
          }
        />
        <div className="max-w-[1296px] overflow-y-auto">
          <AppRouter />
        </div>
      </div>
    </Router>
  );
};
