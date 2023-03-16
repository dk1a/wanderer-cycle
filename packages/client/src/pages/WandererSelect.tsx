import { useWandererEntities } from "../mud/hooks/useWandererEntities";
import WandererSpawn from "../components/WandererSpawn";
import Wanderer from "../components/Wanderer";
import Modal from "../components/UI/Modal/Modal";
import { useEffect, useState } from "react";
import CustomButton from "../components/UI/Button/CustomButton";
import CustomInput from "../components/UI/Input/CustomInput";
import useTransferFrom from "../mud/hooks/transfer";
import { useWandererContext } from "../contexts/WandererContext";
import { useActiveGuise } from "../mud/hooks/guise";
import { useMUD } from "../mud/MUDContext";
import { EntityID } from "@latticexyz/recs";

export default function WandererSelect() {
  const wandererEntities = useWandererEntities();
  const transfer = useTransferFrom();
  const { selectedWandererEntity } = useWandererContext();
  const { world, systems } = useMUD();

  const [active, setActive] = useState(false);
  const [search, setSearch] = useState<EntityID>(null);
  const [token, setToken] = useState("");

  useEffect(() => {
    (async () => {
      if (selectedWandererEntity == undefined) return {};
      const entityId = world.entities[selectedWandererEntity];
      const uri = await systems["system.WNFT"].callStatic.tokenURI(entityId);
      const json = await (await fetch(uri)).json();
      return setToken(json);
    })();
  }, [world, systems, selectedWandererEntity]);

  const transferTo = () => {
    transfer(search, "0x8d6d0733");
    setActive(false);
    setSearch("");
  };

  return (
    <div>
      <section>
        <div className="flex justify-around">
          {wandererEntities.length > 0 && (
            <div className="flex flex-col w-1/2 ml-5">
              <h3 className="m-10 text-2xl font-bold text-dark-comment text-center">{"// select a wanderer"}</h3>
              <div className="flex flex-wrap gap-x-4 gap-y-4 mt-2 justify-around">
                {wandererEntities.map((wandererEntity) => (
                  <Wanderer
                    key={wandererEntity}
                    wandererEntity={wandererEntity}
                    active={active}
                    setActive={setActive}
                  />
                ))}
              </div>
            </div>
          )}
          <div className="flex flex-col w-1/2 mr-5">
            <h3 className=" mt-10 text-2xl font-bold text-dark-comment mb-10 text-center">
              {"// select a guise to spawn a new wanderer"}
            </h3>
            <WandererSpawn disabled={wandererEntities.length >= 3 ? true : false} />
          </div>
        </div>
      </section>
      <Modal active={active} setActive={setActive}>
        <span className="text-dark-300 mb-3">Transfer your Wanderer to...</span>
        <CustomInput placeholder={"Transfer to.."} onChange={(e) => setSearch(e.target.value)} value={search} />
        <CustomButton style={{ marginTop: "10px" }} onClick={transferTo}>
          transfer
        </CustomButton>
      </Modal>
    </div>
  );
}
