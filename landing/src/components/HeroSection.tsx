import React from 'react';
import { ArrowRight, Sparkles, MapPin } from 'lucide-react';

export const HeroSection: React.FC = () => {
  const locations = [
    { name: 'USTP Campus', style: { fontWeight: 700, letterSpacing: '-0.02em', fontSize: '15px' } },
    { name: 'Limketkai Center', style: { fontWeight: 900, letterSpacing: '0.08em', fontSize: '13px', textTransform: 'uppercase' as const } },
    { name: 'Divisoria', style: { fontWeight: 600, letterSpacing: '0.01em', fontSize: '15px', fontStyle: 'italic' } },
    { name: 'Xavier University', style: { fontWeight: 700, letterSpacing: '0.12em', fontSize: '13px', textTransform: 'uppercase' as const } },
    { name: 'Liceo de Cagayan', style: { fontWeight: 400, letterSpacing: '-0.01em', fontSize: '16px' } },
    { name: 'Carmen Market', style: { fontWeight: 400, letterSpacing: '0.04em', fontSize: '14px' } },
  ];

  // Duplicate for seamless looping
  const marqueeItems = [...locations, ...locations, ...locations, ...locations];

  return (
    <section className="px-4 md:px-6 pt-28 pb-6 flex items-center min-h-[640px] max-w-[88rem] mx-auto">
      <div 
        className="relative w-full rounded-[2.5rem] overflow-hidden shadow-xl border border-sky-500/10 flex items-center bg-[#f0f9ff]"
        style={{ height: 'calc(100vh - 140px)', minHeight: '560px' }}
      >
        {/* Background Image with optimized layout */}
        <img 
          src="/images/hero-bg.png" 
          alt="Modern study space" 
          className="absolute inset-0 w-full h-full object-cover object-center select-none opacity-90"
        />
        
        {/* Premium Soft Editorial Overlay */}
        <div className="absolute inset-0 z-10 bg-gradient-to-r from-white via-white/90 md:via-white/80 to-transparent" />
        <div className="absolute inset-0 z-10 bg-gradient-to-t from-white/35 via-transparent to-transparent" />

        {/* Content Container */}
        <div className="relative z-20 w-full px-8 md:px-16 lg:px-24 h-full flex flex-col justify-center pt-8">
          <div className="max-w-2xl">
            {/* Soft floating pill element */}
            <div className="inline-flex items-center gap-2 bg-brand-500/10 border border-brand-500/20 rounded-full px-4 py-1.5 text-brand-700 text-xs font-semibold uppercase tracking-wider mb-6 animate-float">
              <Sparkles className="w-3.5 h-3.5" />
              <span>Real-time vacancy tracker</span>
            </div>

            <h1 
              className="text-slate-900 text-5xl md:text-7xl font-bold leading-[1.05] mb-6 tracking-tight font-heading"
              style={{ letterSpacing: '-0.04em' }}
            >
              Your Next Home<br />
              <span className="text-brand-500 bg-gradient-to-r from-brand-500 to-sky-400 bg-clip-text text-transparent">Awaits.</span>
            </h1>
            
            <p 
              className="text-slate-600 text-base md:text-lg max-w-lg mb-8 leading-relaxed font-normal"
            >
              A seamless, map-driven tracker to find the best boarding houses, dorms, and pad spaces near USTP and across Cagayan de Oro.
            </p>

            <div className="flex flex-wrap gap-4 items-center mb-12">
              <a
                href="/app/signup.html"
                className="group inline-flex items-center gap-3 bg-brand-500 hover:bg-brand-600 text-white text-base font-semibold pl-6 pr-2 py-2 rounded-full transition-all duration-300 cursor-pointer shadow-lg shadow-brand-500/20 hover:shadow-xl hover:shadow-brand-500/30 hover:scale-[1.02]"
              >
                <span>Start browsing</span>
                <span className="bg-white rounded-full p-2 text-brand-500 transition-transform duration-300 group-hover:translate-x-1">
                  <ArrowRight className="w-4 h-4" />
                </span>
              </a>
              
              <a
                href="/app/map"
                className="group inline-flex items-center gap-1.5 text-slate-700 hover:text-brand-500 font-semibold text-base py-3 px-5 transition-colors duration-200"
              >
                <MapPin className="w-4.5 h-4.5" />
                <span>View map first</span>
              </a>
            </div>
          </div>

          {/* Location Brand Marquee Container */}
          <div className="mt-auto w-full max-w-3xl overflow-hidden border-t border-slate-200/60 pt-6 pb-2">
            <div className="marquee-track-ltr">
              {marqueeItems.map((item, idx) => (
                <div
                  key={idx}
                  style={item.style}
                  className="mx-8 shrink-0 text-slate-400 hover:text-brand-500 transition-colors duration-200 select-none cursor-default font-heading"
                >
                  {item.name}
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Premium Floating Indicator Card - Desktop only */}
        <div className="hidden lg:flex absolute right-16 bottom-24 z-20 glass-card-light p-5 rounded-2xl flex-col gap-1.5 shadow-xl border border-white/60 animate-float-delayed max-w-[200px]">
          <span className="text-slate-400 text-xs font-bold uppercase tracking-wider">Active Rooms</span>
          <span className="text-3xl font-black text-slate-900 tracking-tight font-heading">120+</span>
          <p className="text-slate-500 text-xs leading-normal">Verified vacancies around Cagayan de Oro.</p>
        </div>
      </div>
    </section>
  );
};
