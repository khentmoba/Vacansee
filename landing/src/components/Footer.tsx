import React from 'react';
import { LogoIcon } from './LogoIcon';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-black text-white px-6 pt-24 pb-12" id="help">
      <div className="max-w-[88rem] mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-12 pb-16 border-b border-white/10">
          
          {/* Brand Info Column */}
          <div className="lg:col-span-2">
            <div className="flex items-center gap-2.5 mb-6">
              <LogoIcon className="w-8 h-8 text-brand-400" />
              <span className="text-2xl font-bold tracking-tight text-white">VacanSee</span>
            </div>
            <p className="text-white/60 text-sm md:text-base leading-relaxed max-w-sm mb-6" style={{ fontFamily: "'Inter', sans-serif" }}>
              Real-time boarding house and dorm tracker for university students in Cagayan de Oro City. Find verified spaces and connect with landlords.
            </p>
          </div>

          {/* Column 1: For Tenants */}
          <div>
            <h4 className="text-sm font-semibold tracking-wider uppercase text-white mb-6">For Tenants</h4>
            <ul className="space-y-4 text-sm text-white/50" style={{ fontFamily: "'Inter', sans-serif" }}>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Search Rooms</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Near USTP</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Near Xavier</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Student Guides</a></li>
            </ul>
          </div>

          {/* Column 2: For Owners */}
          <div>
            <h4 className="text-sm font-semibold tracking-wider uppercase text-white mb-6">For Owners</h4>
            <ul className="space-y-4 text-sm text-white/50" style={{ fontFamily: "'Inter', sans-serif" }}>
              <li><a href="/signup.html?role=owner" className="hover:text-brand-400 transition-colors duration-200">List Property</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Owner Dashboard</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Resource Center</a></li>
              <li><a href="/login.html" className="hover:text-brand-400 transition-colors duration-200">Premium Listing</a></li>
            </ul>
          </div>

          {/* Column 3: Legal & Company */}
          <div>
            <h4 className="text-sm font-semibold tracking-wider uppercase text-white mb-6">Company</h4>
            <ul className="space-y-4 text-sm text-white/50" style={{ fontFamily: "'Inter', sans-serif" }}>
              <li><a href="#" className="hover:text-brand-400 transition-colors duration-200">About Us</a></li>
              <li><a href="#" className="hover:text-brand-400 transition-colors duration-200">Contact Support</a></li>
              <li><a href="#" className="hover:text-brand-400 transition-colors duration-200">Privacy Policy</a></li>
              <li><a href="#" className="hover:text-brand-400 transition-colors duration-200">Terms of Service</a></li>
            </ul>
          </div>

        </div>

        {/* Bottom copyright alignment */}
        <div className="pt-12 flex flex-col sm:flex-row items-center justify-between gap-6 text-xs text-white/40" style={{ fontFamily: "'Inter', sans-serif" }}>
          <div>
            &copy; {new Date().getFullYear()} VacanSee. All rights reserved.
          </div>
          <div className="flex gap-6">
            <span className="hover:text-white transition-colors duration-200 cursor-pointer">Designed for CDO Students</span>
            <span className="hover:text-white transition-colors duration-200 cursor-pointer">Academic Year 2025-2026</span>
          </div>
        </div>
      </div>
    </footer>
  );
};
