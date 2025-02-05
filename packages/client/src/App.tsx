import React from "react";
import { BrowserRouter as Router } from "react-router-dom";
import { Navbar } from "./components/Navbar/Navbar";
import AppRouter from "./AppRouter";

export const App = () => {
  return (
    <Router>
      <div className="flex flex-col h-full">
        <Navbar className="bg-dark-400 border-dark-400 text-dark-300 md:p-6 p-4 flex items-center justify-start md:justify-center w-full" />
        <div className="flex-1 overflow-y-auto ">
          <AppRouter />
        </div>
      </div>
    </Router>
  );
};
