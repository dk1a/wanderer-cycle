import Combat from "../components/Combat";

export default function CombatPage() {
  return (
    <div className="w-full h-screen flex justify-center relative">
      <div className="flex">
        Map
        <div className="w-full flex-grow">
          <Combat />
        </div>
      </div>
    </div>
  );
}
