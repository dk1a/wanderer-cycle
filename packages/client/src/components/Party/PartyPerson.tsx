import { useCallback, useState } from "react";

export default function PartyPerson({ name }: { name: string | undefined }) {
  const [invite, setInvite] = useState(false);

  const onSelect = useCallback(() => {
    setInvite(!invite);
  }, [invite, setInvite]);

  const styles = "w-full h-full my-4 text-dark-key flex items-center justify-center cursor-pointer";

  return (
    <>
      <div onClick={onSelect} className={!invite ? styles : styles + " bg-dark-400"}>
        {name}
      </div>
    </>
  );
}
