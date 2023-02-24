import CycleInfo from "../components/info/CycleInfo";
import SkillList from "../components/SkillList";
import { useWandererContext } from "../contexts/WandererContext";
import WandererSelect from "./WandererSelect";

const SkillPage = () => {
  const { selectedWandererEntity } = useWandererContext();

  return (
    <section className="flex justify-center">
      {selectedWandererEntity === undefined ? (
        <WandererSelect />
      ) : (
        <div className="flex justify-center">
          <CycleInfo />
          <SkillList />
        </div>
      )}
    </section>
  );
};

export default SkillPage;
