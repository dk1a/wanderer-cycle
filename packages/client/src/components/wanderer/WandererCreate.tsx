import plus from '../../utils/img/plus-square.svg'
import classes from './wandarer.module.scss'
const WandererCreate = ({active, setActive}: any) => {
  return (
    <div className={classes.wanderer__container} onClick={() => setActive(true)}>
      <img src={plus} alt="question"/>
      <p className={classes.wanderer__description}>Create a New Wanderer</p>
    </div>
    );
};

export default WandererCreate;