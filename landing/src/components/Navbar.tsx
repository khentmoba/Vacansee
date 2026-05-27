import React, { useState, useEffect } from 'react';
import { Menu, X } from 'lucide-react';
import { LogoIcon } from './LogoIcon';

const navLinks = [
  { href: '#map-view', label: 'Map View' },
  { href: '#features', label: 'Features' },
  { href: '#landlords', label: 'Property Owners' },
];

export const Navbar: React.FC = () => {
  const [isOpen, setIsOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 20) {
        setIsScrolled(true);
      } else {
        setIsScrolled(false);
      }
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => { document.body.style.overflow = ''; };
  }, [isOpen]);

  return (
    <nav className={`fixed top-4 left-4 right-4 z-50 transition-all duration-300 max-w-[88rem] mx-auto rounded-full ${
      isScrolled ? 'glass-nav-light py-3 px-6 shadow-lg shadow-sky-500/5' : 'bg-transparent py-5 px-6'
    }`}>
      <div className="flex items-center justify-between">
        {/* Left: Logo + Brand Name */}
        <div className="flex items-center gap-2.5 cursor-pointer group">
          <div className="text-brand-500 group-hover:scale-105 transition-transform duration-300">
            <LogoIcon className="w-8 h-8" />
          </div>
          <span className="text-2xl font-bold tracking-tight text-slate-900 font-heading">
            Vacan<span className="text-brand-500">See</span>
          </span>
        </div>

        {/* Center: Navigation Links */}
        <div className="hidden md:flex items-center gap-8">
          {navLinks.map((link) => (
            <a
              key={link.href}
              href={link.href}
              className="text-sm text-slate-600 hover:text-brand-500 font-medium transition-colors duration-200 relative py-1 group"
            >
              {link.label}
              <span className="absolute bottom-0 left-0 w-0 h-0.5 bg-brand-500 transition-all duration-300 group-hover:w-full" />
            </a>
          ))}
        </div>

        {/* Right: CTA Button */}
        <div className="flex items-center gap-4">
          <a
            href="/app/login.html"
            className="hidden md:inline-flex bg-brand-500 hover:bg-brand-600 text-white text-sm font-semibold px-6 py-2.5 rounded-full transition-all duration-300 cursor-pointer shadow-md shadow-brand-500/10 hover:shadow-lg hover:shadow-brand-500/20 hover:scale-[1.02]"
          >
            Find a Room
          </a>
          <button
            onClick={() => setIsOpen(true)}
            className="md:hidden p-2 text-slate-800 hover:text-brand-500 transition-colors duration-200"
            aria-label="Open menu"
          >
            <Menu className="w-6 h-6" />
          </button>
        </div>
      </div>

      {/* Mobile Drawer */}
      {isOpen && (
        <>
          <div
            className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40 md:hidden"
            onClick={() => setIsOpen(false)}
          />
          <div className="fixed top-0 right-0 bottom-0 w-[290px] bg-white z-50 md:hidden shadow-2xl flex flex-col transition-transform duration-300">
            <div className="flex items-center justify-between px-6 py-5 border-b border-slate-100">
              <span className="text-xl font-bold text-slate-900">Navigation</span>
              <button
                onClick={() => setIsOpen(false)}
                className="p-2 text-slate-800 hover:text-brand-500 transition-colors duration-200"
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
                  className="text-lg text-slate-700 hover:text-brand-500 font-medium transition-colors duration-200"
                >
                  {link.label}
                </a>
              ))}
            </div>
            <div className="px-6 pb-8 pt-4 border-t border-slate-100">
              <a
                href="/app/login.html"
                className="block w-full text-center bg-brand-500 hover:bg-brand-600 text-white text-base font-semibold px-7 py-3.5 rounded-full transition-colors duration-200 cursor-pointer shadow-md shadow-brand-500/10"
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
