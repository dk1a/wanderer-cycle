export default function CombatTab({ tab }: { tab: { id: number; label: string } }) {
  return (
    <div className="border border-dark-400 text-dark-200 w-1/3 text-center flex">
      <span>{tab.label}</span>
    </div>
  );
}
