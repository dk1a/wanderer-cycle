import classes from "./footer.module.scss";

const Footer = () => {
  return (
    <div className={classes.footer}>
      <div className={classes.footer__item}>
        <div className={classes.footer__logo}>Logo</div>
        <p className={classes.copyright}>Copyright 2023. Name</p>
        <p className={classes.footer__p}>Lorem ipsum dolor sit amet, consectetur.</p>
      </div>
      <div className={classes.footer__item}>
        <h4 className={classes.copyright}>Contact Us</h4>
        <p className={classes.footer__p}>+777777777</p>
        <p className={classes.footer__p}>adress. N1</p>
        <p className={classes.footer__p}>company@company.com</p>
      </div>
      <div className={classes.footer__item}>
        <h4 className={classes.copyright}>Docs</h4>
        <p className={classes.footer__p}>Game</p>
        <p className={classes.footer__p}>Development</p>
      </div>
      <div className={classes.footer__item}>
        <h4 className={classes.copyright}>Company info</h4>
        <p className={classes.footer__p}>About Us</p>
        <p className={classes.footer__p}>Our Partners</p>
        <p className={classes.footer__p}>Blog</p>
      </div>
    </div>
  );
};

export default Footer;
