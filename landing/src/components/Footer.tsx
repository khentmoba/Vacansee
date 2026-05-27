import React from 'react';
import { LogoIcon } from './LogoIcon';

export const Footer: React.FC = () => {
  return (
    <footer className="bg-slate-900 text-slate-400 py-16 px-6 border-t border-slate-800">
      <div className="max-w-[88rem] mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-12 mb-12">
          {/* Logo & Pitch */}
          <div className="flex flex-col gap-4">
            <div className="flex items-center gap-2 text-white">
              <LogoIcon className="w-8 h-8 text-brand-500" />
              <span className="text-xl font-bold tracking-tight font-heading">
                Vacan<span className="text-brand-500">See</span>
              </span>
            </div>
            <p className="text-slate-400 text-sm leading-relaxed max-w-xs">
              A real-time boarding house vacancy tracker designed to help university students find verified housing options near USTP, Xavier, and across Cagayan de Oro.
            </p>
          </div>

          {/* Links 1 */}
          <div>
            <h4 className="text-white text-sm font-semibold tracking-wider uppercase mb-4 font-heading">
              For Tenants
            </h4>
            <ul className="flex flex-col gap-2.5 text-sm">
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Search Map
                </a>
              </li>
              <li>
                <a href="#features" className="hover:text-brand-400 transition-colors duration-200">
                  Core Features
                </a>
              </li>
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Create Tenant Account
                </a>
              </li>
            </ul>
          </div>

          {/* Links 2 */}
          <div>
            <h4 className="text-white text-sm font-semibold tracking-wider uppercase mb-4 font-heading">
              For Landlords
            </h4>
            <ul className="flex flex-col gap-2.5 text-sm">
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  List Your Property
                </a>
              </li>
              <li>
                <a href="#landlords" className="hover:text-brand-400 transition-colors duration-200">
                  Owner Dashboard
                </a>
              </li>
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Sign In
                </a>
              </li>
            </ul>
          </div>

          {/* Links 3 */}
          <div>
            <h4 className="text-white text-sm font-semibold tracking-wider uppercase mb-4 font-heading">
              Neighborhoods
            </h4>
            <ul className="flex flex-col gap-2.5 text-sm">
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Near USTP
                </a>
              </li>
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Limketkai Area
                </a>
              </li>
              <li>
                <a href="/app" className="hover:text-brand-400 transition-colors duration-200">
                  Carmen & Kauswagan
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-slate-800 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs">
          <p className="text-slate-500">
            &copy; {new Date().getFullYear()} VacanSee. All rights reserved.
          </p>
          <div className="flex gap-6">
            <a href="#" className="hover:text-brand-400 transition-colors duration-200">
              Privacy Policy
            </a>
            <a href="#" className="hover:text-brand-400 transition-colors duration-200">
              Terms of Service
            </a>
            <a href="#" className="hover:text-brand-400 transition-colors duration-200">
              Help Center
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
};
