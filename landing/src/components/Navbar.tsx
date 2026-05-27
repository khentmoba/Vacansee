import { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';
import { LogoIcon } from './LogoIcon';

const navLinks = [
  { href: '#map-view', label: 'Map View' },
  { href: '#neighborhoods', label: 'Neighborhoods' },
  { href: '#landlords', label: 'Landlords' },
  { href: '#help', label: 'Help' },
];

export const Navbar: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  return (
    <nav className="absolute top-0 left-0 right-0 z-20 px-6 py-5">
      <div className="max-w-[88rem] mx-auto flex items-center justify-between">
        {/* Left: Logo + Brand Name */}
        <div className="flex items-center gap-2.5 cursor-pointer">
          <div className="text-black">
            <LogoIcon className="w-7 h-7" />
          </div>
          <span className="text-2xl font-semibold tracking-tight text-black">
            VacanSee
          </span>
        </div>

        {/* Center: Navigation Links (desktop) */}
        <div className="hidden md:flex items-center gap-8">
          {navLinks.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="text-base text-gray-700 hover:text-brand-500 font-medium transition-colors duration-200"
            >
              {link.label}
            </a>
          ))}
        </div>

        {/* Right: CTA Button (desktop) + Hamburger (mobile) */}
        <div className="flex items-center gap-4">
          <a
            href="/login.html"
            className="hidden md:inline-block bg-brand-500 text-white text-base font-medium px-7 py-2.5 rounded-full hover:bg-brand-600 transition-colors duration-200 cursor-pointer shadow-sm shadow-brand-500/30"
          >
            Find a Room
          </a>
          <button
            onClick={() => setIsOpen(true)}
            className="md:hidden p-2 text-black hover:text-brand-500 transition-colors duration-200"
            aria-label="Open menu"
          >
            <Menu className="w-6 h-6" />
          </button>
        </div>
      </div>

      {/* Mobile Drawer */}
      {isOpen && (
        <>
          {/* Backdrop */}
          <div
            className="fixed inset-0 bg-black/40 z-40 md:hidden"
            onClick={() => setIsOpen(false)}
          />
          {/* Panel */}
          <div className="nav-drawer open fixed top-0 right-0 bottom-0 w-[280px] bg-[#F0F9FF] z-50 md:hidden shadow-2xl flex flex-col">
            <div className="flex items-center justify-between px-6 py-5 border-b border-brand-500/10">
              <span className="text-xl font-semibold text-black">Menu</span>
              <button
                onClick={() => setIsOpen(false)}
                className="p-2 text-black hover:text-brand-500 transition-colors duration-200"
                aria-label="Close menu"
              >
                <X className="w-6 h-6" />
              </button>
            </div>
            <div className="flex-1 flex flex-col px-6 pt-8 gap-6">
              {navLinks.map((link) => (
                <a
                  key={link.href}
                  href={link.href}
                  onClick={() => setIsOpen(false)}
                  className="text-lg text-gray-700 hover:text-brand-500 font-medium transition-colors duration-200"
                >
                  {link.label}
                </a>
              ))}
            </div>
            <div className="px-6 pb-8 pt-4 border-t border-brand-500/10">
              <a
                href="/login.html"
                className="block w-full text-center bg-brand-500 text-white text-base font-medium px-7 py-3 rounded-full hover:bg-brand-600 transition-colors duration-200 cursor-pointer shadow-sm shadow-brand-500/30"
              >
                Find a Room
              </a>
            </div>
          </div>
        </>
      )}
    </nav>
  );
};
