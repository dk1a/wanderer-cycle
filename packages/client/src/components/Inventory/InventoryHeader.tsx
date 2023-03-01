type InventoryHeaderProps = {
  children: string | number;
};
export default function InventoryHeader({ children }: InventoryHeaderProps) {
  return <h3 className="text-xl text-dark-200">{children}</h3>;
}
