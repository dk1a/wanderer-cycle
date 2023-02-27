import CycleInfo from "../components/info/CycleInfo";
import SkillList from "../components/SkillList";
import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";

const SkillPage = () => {
  const { selectedWandererEntity } = useWandererContext();

  return (
    <section className="flex justify-start">
      {selectedWandererEntity === undefined ? (
        <WandererSelect />
      ) : (
        <div className="flex">
          <CycleInfo />
          <SkillList />
        </div>
      )}
    </section>
  );
};

export default SkillPage;
