import React from 'react';

export const FeaturesMarquee: React.FC = () => {
  const items = [
    { name: 'Free High-Speed WiFi', style: { fontFamily: '"Times New Roman", Times, serif', fontWeight: 400, letterSpacing: '0.02em', fontSize: '14px' } },
    { name: 'No Curfew', style: { fontFamily: '"Arial Black", Gadget, sans-serif', fontWeight: 900, letterSpacing: '0.08em', fontSize: '16px' } },
    { name: 'Cooking Allowed', style: { fontFamily: 'Impact, Charcoal, sans-serif', fontWeight: 700, letterSpacing: '0.05em', fontSize: '18px' } },
    { name: 'Inclusive Utilities', style: { fontFamily: 'Georgia, serif', fontWeight: 600, letterSpacing: '-0.02em', fontSize: '17px' } },
    { name: 'CCTV Security', style: { fontFamily: '"Helvetica Neue", Helvetica, Arial, sans-serif', fontWeight: 700, letterSpacing: '-0.01em', fontSize: '15px' } },
    { name: 'In-house Laundry', style: { fontFamily: 'Verdana, Geneva, sans-serif', fontWeight: 700, letterSpacing: '0.06em', fontSize: '14px', textTransform: 'uppercase' as const } },
    { name: 'Solo Rooms', style: { fontFamily: 'Palatino, "Palatino Linotype", serif', fontWeight: 500, letterSpacing: '0.03em', fontSize: '15px' } },
  ];

  // Tripled for seamless scrolling
  const marqueeItems = [...items, ...items, ...items];

  return (
    <section className="bg-[#F5F5F5] py-16 border-t border-b border-black/5 overflow-hidden" id="neighborhoods">
      <div className="max-w-[88rem] mx-auto px-6 grid grid-cols-1 md:grid-cols-4 gap-8 items-center">
        {/* Left Side: Short Description Column */}
        <div className="md:col-span-1">
          <p 
            className="text-black/70 text-base leading-relaxed"
            style={{ fontFamily: "'Inter', sans-serif" }}
          >
            Filter by the amenities<br />that matter most to you.
          </p>
        </div>

        {/* Right Side: Continuous Marquee Column */}
        <div className="md:col-span-3 overflow-hidden select-none">
          <div className="backers-track">
            {marqueeItems.map((item, idx) => (
              <div
                key={idx}
                style={item.style}
                className="mx-10 shrink-0 text-black/50 hover:text-brand-500 hover:scale-105 transition-all duration-200 cursor-default"
              >
                {item.name}
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
};
