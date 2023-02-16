const Footer = () => {
  return (
    <div className="w-full flex justify-around border-y-0 bg-dark-500 mt-56">
      <div className="w-64 h-44 mt-16 ml-20">
        <div className="mb-6 text-2xl">Logo</div>
        <p className="text-dark-200 mb-5 text-lg">Copyright 2023. Name</p>
        <p className="text-dark-300 mb-2.5 text-sm">Lorem ipsum dolor sit amet, consectetur.</p>
      </div>
      <div className="w-64 h-44 mt-16 ml-20">
        <h4 className="text-dark-200 mb-5 text-lg">Contact Us</h4>
        <p className="text-dark-300 mb-2.5 text-sm">+777777777</p>
        <p className="text-dark-300 mb-2.5 text-sm">adress. N1</p>
        <p className="text-dark-300 mb-2.5 text-sm">company@company.com</p>
      </div>
      <div className="w-64 h-44 mt-16 ml-20">
        <h4 className="text-dark-200 mb-5 text-lg">Docs</h4>
        <p className="text-dark-300 mb-2.5 text-sm">Game</p>
        <p className="text-dark-300 mb-2.5 text-sm">Development</p>
      </div>
      <div className="w-64 h-44 mt-16 ml-20">
        <h4 className="text-dark-200 mb-5 text-lg">Company info</h4>
        <p className="text-dark-300 mb-2.5 text-sm">About Us</p>
        <p className="text-dark-300 mb-2.5 text-sm">Our Partners</p>
        <p className="text-dark-300 mb-2.5 text-sm">Blog</p>
      </div>
    </div>
  );
};

export default Footer;
