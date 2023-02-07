import { Link } from "react-router-dom";

const NotFound = () => {
  return (
    <div>
      This page doesn&apos;t exist. Go <Link to="/">Home</Link>
    </div>
  );
};

export default NotFound;
