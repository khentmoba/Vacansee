import React from 'react';
import { ArrowRight, CheckCircle2 } from 'lucide-react';
import { ScrollReveal } from './ScrollReveal';

export const LandlordSection: React.FC = () => {
  return (
    <section className="bg-gradient-to-b from-white to-[#FAFDFE] px-6 py-28" id="landlords">
      <div className="max-w-[88rem] mx-auto grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
        {/* Left Column: Context Copy */}
        <ScrollReveal className="lg:pr-12">
          <span className="inline-block text-brand-500 font-bold tracking-wider text-xs uppercase mb-4">
            The Platform in Practice
          </span>
          <h2 
            className="text-slate-900 text-4xl md:text-5xl lg:text-6xl font-bold leading-[1.1] mb-6 tracking-tight font-heading"
            style={{ letterSpacing: '-0.04em' }}
          >
            Built for Everyone
          </h2>
          <p className="text-slate-500 text-base md:text-lg leading-relaxed max-w-md mb-8">
            Whether you are a student looking for a secure place to stay or a property owner managing multiple rooms, the platform adapts to your needs.
          </p>
          
          <div className="border-t border-slate-100 pt-8 grid grid-cols-3 gap-6">
            <div>
              <div className="text-3xl font-black text-brand-500 tracking-tight mb-1 font-heading">0%</div>
              <p className="text-slate-400 text-[10px] uppercase font-bold tracking-wider">Listing Fees</p>
            </div>
            <div>
              <div className="text-3xl font-black text-brand-500 tracking-tight mb-1 font-heading">100%</div>
              <p className="text-slate-400 text-[10px] uppercase font-bold tracking-wider">Verified Landlords</p>
            </div>
            <div>
              <div className="text-3xl font-black text-brand-500 tracking-tight mb-1 font-heading">Real-time</div>
              <p className="text-slate-400 text-[10px] uppercase font-bold tracking-wider">Vacancy Status</p>
            </div>
          </div>
        </ScrollReveal>

        {/* Right Column: Hero Landlord Card Container */}
        <ScrollReveal delay={2} className="relative rounded-[2.5rem] overflow-hidden min-h-[520px] shadow-xl group border border-sky-500/10">
          {/* Background image */}
          <img 
            src="/images/property-owner.png" 
            alt="Beautiful property entry" 
            className="absolute inset-0 w-full h-full object-cover object-center group-hover:scale-[1.03] transition-transform duration-700 select-none"
          />
          {/* Soft light overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-slate-950 via-slate-900/60 to-transparent z-10" />

          {/* Card Content Overlay */}
          <div className="relative z-20 p-8 md:p-12 h-full flex flex-col justify-end min-h-[520px]">
            <span className="self-start bg-brand-500 text-white text-xs font-semibold px-4 py-1.5 rounded-full tracking-wide uppercase mb-6 shadow-md shadow-brand-500/15">
              Owner Dashboard
            </span>
            <h3 
              className="text-white text-3xl md:text-4xl font-bold leading-tight mb-4 font-heading"
              style={{ letterSpacing: '-0.02em' }}
            >
              For Property Owners
            </h3>
            <p className="text-white/80 text-sm md:text-base leading-relaxed max-w-md mb-8">
              Fill your vacant beds faster. Showcase your property with high-quality galleries, list clear house rules, and manage tenant inquiries directly from your customized owner dashboard.
            </p>
            
            <div className="flex flex-col gap-4 mb-8">
              <div className="flex items-center gap-2.5 text-white/90 text-sm">
                <CheckCircle2 className="w-5 h-5 text-brand-400 shrink-0" />
                <span>Unlimited listings & real-time updates</span>
              </div>
              <div className="flex items-center gap-2.5 text-white/90 text-sm">
                <CheckCircle2 className="w-5 h-5 text-brand-400 shrink-0" />
                <span>Verified Landlord checkmark for authenticity</span>
              </div>
            </div>

            <div>
              <a 
                href="/app/signup.html?role=owner" 
                className="group inline-flex items-center gap-3 bg-white text-slate-900 hover:bg-slate-50 font-semibold text-sm pl-6 pr-2 py-2 rounded-full transition-all duration-300 shadow-lg"
              >
                <span>List your property</span>
                <span className="w-8 h-8 rounded-full bg-slate-900 text-white flex items-center justify-center transition-all duration-300 group-hover:translate-x-0.5">
                  <ArrowRight className="w-4 h-4" />
                </span>
              </a>
            </div>
          </div>
        </ScrollReveal>
      </div>
    </section>
  );
};
