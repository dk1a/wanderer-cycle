export default function MapTabs({ map }: { map: { id: number; label: string } }) {
  return <div className="text-dark-300 hover:text-dark-200 cursor-pointer ">{map.label}</div>;
}
