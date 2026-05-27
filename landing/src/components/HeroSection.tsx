import React from 'react';
import { ArrowRight } from 'lucide-react';

export const HeroSection: React.FC = () => {
  const locations = [
    { name: 'USTP Campus', style: { fontFamily: 'Georgia, serif', fontWeight: 700, letterSpacing: '-0.02em', fontSize: '15px' } },
    { name: 'Limketkai Center', style: { fontFamily: 'Arial, sans-serif', fontWeight: 900, letterSpacing: '0.08em', fontSize: '13px', textTransform: 'uppercase' as const } },
    { name: 'Divisoria', style: { fontFamily: 'Trebuchet MS, sans-serif', fontWeight: 600, letterSpacing: '0.01em', fontSize: '15px', fontStyle: 'italic' } },
    { name: 'Xavier University', style: { fontFamily: 'Courier New, monospace', fontWeight: 700, letterSpacing: '0.12em', fontSize: '13px', textTransform: 'uppercase' as const } },
    { name: 'Liceo de Cagayan', style: { fontFamily: 'Palatino, "Book Antiqua", serif', fontWeight: 400, letterSpacing: '-0.01em', fontSize: '16px' } },
    { name: 'Carmen Market', style: { fontFamily: '"Impact", "Arial Narrow", sans-serif', fontWeight: 400, letterSpacing: '0.04em', fontSize: '14px' } },
  ];

  // Duplicate for seamless looping
  const marqueeItems = [...locations, ...locations, ...locations, ...locations];

  return (
    <section className="flex-1 px-6 pt-24 pb-6 flex items-end min-h-[600px]">
      <div 
        className="relative w-full rounded-3xl overflow-hidden shadow-2xl flex items-center"
        style={{ height: 'calc(100vh - 120px)', minHeight: '520px' }}
      >
        {/* Background Image with optimized layout */}
        <img 
          src="/images/hero-bg.png" 
          alt="Modern study space" 
          className="absolute inset-0 w-full h-full object-cover object-center select-none"
        />
        
        {/* Editorial style gradient overlay */}
        <div className="absolute inset-0 z-10 bg-gradient-to-r from-[#F0F9FF]/95 via-[#F0F9FF]/75 to-transparent" />

        {/* Content Container */}
        <div className="relative z-10 w-full max-w-[88rem] mx-auto px-12 md:px-20 h-full flex flex-col justify-center pt-16">
          <div className="max-w-2xl">
            <h1 
              className="text-black text-5xl md:text-7xl font-semibold leading-[1.08] mb-6 tracking-tight"
              style={{ letterSpacing: '-0.04em' }}
            >
              Your Next Home<br />Awaits
            </h1>
            
            <p 
              className="text-black/80 text-lg md:text-xl max-w-lg mb-10 leading-relaxed font-normal"
              style={{ fontFamily: "'Inter', ui-sans-serif, system-ui, sans-serif" }}
            >
              A seamless, map-driven tracker to find the best boarding houses, dorms, and pad spaces near USTP and across Cagayan de Oro.
            </p>

            <div className="flex flex-wrap gap-4 items-center mb-16">
              <a
                href="/signup.html"
                className="group inline-flex items-center gap-4 bg-brand-500 text-white text-base md:text-lg font-medium pl-8 pr-2.5 py-2.5 rounded-full hover:bg-brand-600 transition-all duration-300 cursor-pointer shadow-lg hover:shadow-xl shadow-brand-500/30"
              >
                <span>Start browsing</span>
                <span className="bg-white rounded-full p-2.5 text-brand-500 group-hover:translate-x-1 transition-transform duration-300">
                  <ArrowRight className="w-5 h-5" />
                </span>
              </a>
              
              <a
                href="#map-view"
                className="text-black/80 hover:text-brand-500 font-semibold text-base py-3 px-6 hover:underline transition-colors duration-200"
              >
                View map first
              </a>
            </div>
          </div>

          {/* Location Brand Marquee Container */}
          <div className="mt-auto w-full max-w-4xl overflow-hidden border-t border-black/10 pt-6 pb-2">
            <div className="marquee-track">
              {marqueeItems.map((item, idx) => (
                <div
                  key={idx}
                  style={item.style}
                  className="mx-8 shrink-0 text-black/60 hover:text-brand-500 transition-colors duration-200 select-none cursor-default"
                >
                  {item.name}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
