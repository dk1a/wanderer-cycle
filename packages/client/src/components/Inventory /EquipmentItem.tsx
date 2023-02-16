import { TokenData } from "../../utils/tokenBases";
import BaseLootItem from "./BaseLootItem";
import { useUriJson } from "../../hooks/uri/useUriJson";

interface EquipmentItemProps {
  tokenData: TokenData;
  className?: string;
  children?: React.ReactNode;
}

export default function EquipmentItem({ tokenData, className, children }: EquipmentItemProps) {
  const json = useUriJson(tokenData.tokenId);

  return BaseLootItem({ tokenData, showSymbol: false, json: json.data, className, children });
}
