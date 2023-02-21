type InventoryHeaderProps = {
  children: string | number;
};
const InventoryHeader = ({ children }: InventoryHeaderProps) => {
  return <h3 className="text-xl text-dark-200">{children}</h3>;
};

export default InventoryHeader;
