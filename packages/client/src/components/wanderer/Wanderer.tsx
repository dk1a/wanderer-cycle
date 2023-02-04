import classes from './wandarer.module.scss'
const Wanderer = ({children}: any) => {
  return (
    <div className={classes.wanderer__container}>
      {children}
    </div>
    );
};

export default Wanderer;