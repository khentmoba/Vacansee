import React from 'react';
import { LogoIcon } from './LogoIcon';

export const Navbar: React.FC = () => {
  return (
    <nav className="absolute top-0 left-0 right-0 z-20 px-6 py-5">
      <div className="max-w-[88rem] mx-auto flex items-center justify-between">
        {/* Left: Logo + Brand Name */}
        <div className="flex items-center gap-2.5 cursor-pointer">
          <div className="text-black">
            <LogoIcon className="w-7 h-7" />
          </div>
          <span className="text-2xl font-semibold tracking-tight text-black">
            CDO PadFinder
          </span>
        </div>

        {/* Center: Navigation Links */}
        <div className="hidden md:flex items-center gap-8">
          <a
            href="#map-view"
            className="text-base text-gray-700 hover:text-black font-medium transition-colors duration-200"
          >
            Map View
          </a>
          <a
            href="#neighborhoods"
            className="text-base text-gray-700 hover:text-black font-medium transition-colors duration-200"
          >
            Neighborhoods
          </a>
          <a
            href="#landlords"
            className="text-base text-gray-700 hover:text-black font-medium transition-colors duration-200"
          >
            Landlords
          </a>
          <a
            href="#help"
            className="text-base text-gray-700 hover:text-black font-medium transition-colors duration-200"
          >
            Help
          </a>
        </div>

        {/* Right: CTA Button */}
        <div>
          <a
            href="/login.html"
            className="inline-block bg-black text-white text-base font-medium px-7 py-2.5 rounded-full hover:bg-gray-800 transition-colors duration-200 cursor-pointer shadow-sm"
          >
            Find a Room
          </a>
        </div>
      </div>
    </nav>
  );
};
