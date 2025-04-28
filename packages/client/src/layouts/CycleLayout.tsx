import { Outlet } from "react-router-dom";
import { CycleInfo } from "../components/info/CycleInfo";

export function CycleLayout() {
  return (
    <div className="flex">
      <CycleInfo />
      <Outlet />
    </div>
  );
}
