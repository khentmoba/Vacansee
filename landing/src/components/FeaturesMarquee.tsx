import React from 'react';
import { ScrollReveal } from './ScrollReveal';

export const FeaturesMarquee: React.FC = () => {
  const row1 = [
    'Free High-Speed WiFi',
    'No Curfew Rules',
    'Cooking Allowed',
    'Inclusive Utility Bills',
    'CCTV Security 24/7',
    'In-house Laundry Space',
    'Solo Rooms Available',
  ];

  const row2 = [
    'Study Table Included',
    'AC Rooms Available',
    'Visitors Allowed',
    'Shared Kitchen Space',
    'Motorcycle Parking',
    'Water Purifier Access',
    'Male & Female Orientation',
  ];

  const marqueeRow1 = [...row1, ...row1, ...row1];
  const marqueeRow2 = [...row2, ...row2, ...row2];

  return (
    <section className="bg-white py-20 border-t border-b border-slate-100 overflow-hidden">
      <div className="max-w-[88rem] mx-auto px-6 mb-12">
        <ScrollReveal className="max-w-xl">
          <span className="text-brand-500 font-bold uppercase tracking-wider text-xs block mb-3">Custom Amenities</span>
          <h2 className="text-slate-900 text-3xl md:text-4xl font-bold tracking-tight font-heading">
            Filter by what matters to you.
          </h2>
          <p className="text-slate-500 text-base mt-2">
            Every boarding house features detailed tags, letting you filter and find matching options instantly.
          </p>
        </ScrollReveal>
      </div>

      <div className="flex flex-col gap-6 select-none">
        {/* Row 1: Left-to-Right Marquee */}
        <div className="overflow-hidden w-full relative py-2">
          {/* Subtle gradient mask to fade items on left and right edges */}
          <div className="absolute inset-y-0 left-0 w-24 bg-gradient-to-r from-white to-transparent z-10 pointer-events-none" />
          <div className="absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-white to-transparent z-10 pointer-events-none" />
          
          <div className="marquee-track-ltr">
            {marqueeRow1.map((item, idx) => (
              <div
                key={idx}
                className="mx-4 shrink-0 bg-slate-50 border border-slate-200/80 text-slate-700 hover:text-brand-500 hover:border-brand-500/30 hover:bg-brand-500/5 px-6 py-3 rounded-full text-sm font-semibold tracking-wide transition-all duration-300 cursor-default shadow-sm shadow-slate-100/50"
              >
                {item}
              </div>
            ))}
          </div>
        </div>

        {/* Row 2: Right-to-Left Marquee */}
        <div className="overflow-hidden w-full relative py-2">
          <div className="absolute inset-y-0 left-0 w-24 bg-gradient-to-r from-white to-transparent z-10 pointer-events-none" />
          <div className="absolute inset-y-0 right-0 w-24 bg-gradient-to-l from-white to-transparent z-10 pointer-events-none" />

          <div className="marquee-track-rtl">
            {marqueeRow2.map((item, idx) => (
              <div
                key={idx}
                className="mx-4 shrink-0 bg-slate-50 border border-slate-200/80 text-slate-700 hover:text-brand-500 hover:border-brand-500/30 hover:bg-brand-500/5 px-6 py-3 rounded-full text-sm font-semibold tracking-wide transition-all duration-300 cursor-default shadow-sm shadow-slate-100/50"
              >
                {item}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};
