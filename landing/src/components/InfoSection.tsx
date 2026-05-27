import React from 'react';
import { ArrowRight, ShieldCheck, MapPin, AppWindow } from 'lucide-react';
import { ScrollReveal } from './ScrollReveal';

export const InfoSection: React.FC = () => {
  return (
    <section className="bg-gradient-to-b from-[#FAFDFE] to-white px-6 py-28" id="features">
      <div className="max-w-[88rem] mx-auto">
        {/* Row 1: Heading + Paragraph Intro */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-20 items-end">
          <ScrollReveal>
            <span className="text-brand-500 font-bold uppercase tracking-wider text-xs block mb-3">Core Features</span>
            <h2
              className="text-slate-900 text-4xl md:text-5xl lg:text-6xl font-bold leading-tight tracking-tight font-heading"
              style={{ letterSpacing: '-0.03em' }}
            >
              Smart Student Living.
            </h2>
            <div className="mt-6">
              <a
                href="/app/map"
                className="group inline-flex items-center gap-3 bg-brand-500 hover:bg-brand-600 text-white text-sm font-semibold pl-5 pr-1.5 py-1.5 rounded-full transition-all duration-300 cursor-pointer shadow-md shadow-brand-500/10 hover:shadow-lg hover:shadow-brand-500/20"
              >
                <span>Explore map view</span>
                <span className="bg-white rounded-full p-2 text-brand-500 transition-transform duration-300 group-hover:translate-x-0.5">
                  <ArrowRight className="w-4 h-4" />
                </span>
              </a>
            </div>
          </ScrollReveal>
          <ScrollReveal delay={1}>
            <p className="text-slate-500 text-xl md:text-2xl md:leading-relaxed font-light mt-1">
              Find verified boarding houses that fit your budget, complete with transparent pricing, accurate amenity filters, and direct landlord contact.
            </p>
          </ScrollReveal>
        </div>

        {/* Row 2: Bento Grid Layout */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Card 1: Designed for focus (occupies 2 columns on md/lg) */}
          <ScrollReveal delay={1} className="relative md:col-span-2 rounded-[2rem] overflow-hidden min-h-[380px] p-8 flex flex-col justify-between shadow-sm hover:shadow-xl transition-all duration-500 cursor-pointer border border-sky-500/5 group">
            {/* Background Image */}
            <img 
              src="/images/desk-setup.png" 
              alt="Cozy study area" 
              className="absolute inset-0 w-full h-full object-cover object-center group-hover:scale-[1.03] transition-transform duration-700 select-none"
            />
            {/* Elegant glass overlay to ensure text contrast */}
            <div className="absolute inset-0 bg-gradient-to-tr from-white/95 via-white/80 md:via-white/30 to-transparent z-10" />

            <div className="relative z-20 flex justify-start items-center">
              <span className="bg-brand-500/10 backdrop-blur-md text-brand-700 text-xs font-semibold px-4 py-1.5 rounded-full tracking-wide uppercase border border-brand-500/25">
                Amenities Focus
              </span>
            </div>

            <div className="relative z-20 mt-auto flex flex-col items-start gap-4">
              <h3 
                className="text-slate-900 text-3xl font-bold leading-snug tracking-tight font-heading"
                style={{ letterSpacing: '-0.02em' }}
              >
                Designed for focus
              </h3>
              <p 
                className="text-slate-600 text-sm md:text-base max-w-md bg-white/70 backdrop-blur-md rounded-2xl p-4 border border-white"
              >
                Filter by essential amenities like inclusive WiFi, study areas, and curfew rules to match your academic schedule.
              </p>
            </div>
          </ScrollReveal>

          {/* Card 2: Walk to class */}
          <ScrollReveal delay={2} className="glass-card-light rounded-[2rem] p-8 min-h-[380px] flex flex-col justify-between cursor-pointer group">
            <div className="bg-brand-500/10 border border-brand-500/20 w-12 h-12 rounded-2xl flex items-center justify-center text-brand-500 mb-6 group-hover:scale-105 transition-transform duration-300">
              <MapPin className="w-6 h-6" />
            </div>

            <div className="mt-auto">
              <h3 className="text-slate-900 text-2xl font-bold leading-snug tracking-tight mb-3 font-heading">
                Walk to class,<br />save time.
              </h3>
              <p className="text-slate-500 text-sm md:text-base leading-relaxed">
                View exact distances to major university gates and local transport routes.
              </p>
            </div>
          </ScrollReveal>

          {/* Card 3: Verified listings */}
          <ScrollReveal delay={3} className="glass-card-light rounded-[2rem] p-8 min-h-[380px] flex flex-col justify-between cursor-pointer group">
            <div className="bg-brand-500/10 border border-brand-500/20 w-12 h-12 rounded-2xl flex items-center justify-center text-brand-500 mb-6 group-hover:scale-105 transition-transform duration-300">
              <ShieldCheck className="w-6 h-6" />
            </div>

            <div className="mt-auto">
              <h3 className="text-slate-900 text-2xl font-bold leading-snug tracking-tight mb-3 font-heading">
                Verified<br />listings.
              </h3>
              <p className="text-slate-500 text-sm md:text-base leading-relaxed">
                Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.
              </p>
            </div>
          </ScrollReveal>

          {/* Card 4: Platform statistics or secondary info badge - Desktop only */}
          <ScrollReveal delay={4} className="glass-card-light rounded-[2rem] p-8 min-h-[380px] flex flex-col justify-between cursor-pointer group">
            <div className="bg-brand-500/10 border border-brand-500/20 w-12 h-12 rounded-2xl flex items-center justify-center text-brand-500 mb-6 group-hover:scale-105 transition-transform duration-300">
              <AppWindow className="w-6 h-6" />
            </div>

            <div className="mt-auto">
              <h3 className="text-slate-900 text-2xl font-bold leading-snug tracking-tight mb-3 font-heading">
                Interactive<br />Dashboard.
              </h3>
              <p className="text-slate-500 text-sm md:text-base leading-relaxed">
                A simple dashboard to save favorites, apply for rooms, and trace your applications.
              </p>
            </div>
          </ScrollReveal>
        </div>
      </div>
    </section>
  );
};
