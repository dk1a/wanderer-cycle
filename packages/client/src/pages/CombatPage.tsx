import { Combat } from "../components/Combat/Combat";

export default function CombatPage() {
  return (
    <div className="w-full h-screen flex justify-center relative">
      <div className="w-full flex-grow">
        <Combat />
      </div>
    </div>
  );
}
