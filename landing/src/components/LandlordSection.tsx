import { ArrowRight } from 'lucide-react';
import { ScrollReveal } from './ScrollReveal';

export const LandlordSection: React.FC = () => {
  return (
    <section className="bg-[#F0F9FF] px-6 py-28" id="landlords">
      <div className="max-w-[88rem] mx-auto grid grid-cols-1 lg:grid-cols-2 gap-16 items-center">
        {/* Left Column: Context Copy */}
        <ScrollReveal className="lg:pr-12">
          <span className="inline-block text-brand-500 font-semibold tracking-wider text-sm uppercase mb-4">
            The Platform in Practice
          </span>
          <h2 
            className="text-black text-5xl md:text-6xl font-semibold leading-[1.05] mb-8"
            style={{ letterSpacing: '-0.04em' }}
          >
            Built for Everyone
          </h2>
          <p className="text-black/60 text-base md:text-lg leading-relaxed max-w-md mb-8" style={{ fontFamily: "'Inter', sans-serif" }}>
            Whether you are a student looking for a secure place to stay or a property owner managing multiple rooms, the platform adapts to your needs.
          </p>
          <div className="border-t border-brand-500/10 pt-8 flex gap-8">
            <div>
              <div className="text-3xl font-semibold text-black tracking-tight mb-1">0%</div>
              <p className="text-black/50 text-xs uppercase font-medium tracking-wide">Listing Fees</p>
            </div>
            <div>
              <div className="text-3xl font-semibold text-black tracking-tight mb-1">100%</div>
              <p className="text-black/50 text-xs uppercase font-medium tracking-wide">Verified Landlords</p>
            </div>
            <div>
              <div className="text-3xl font-semibold text-black tracking-tight mb-1">Real-time</div>
              <p className="text-black/50 text-xs uppercase font-medium tracking-wide">Vacancy Status</p>
            </div>
          </div>
        </ScrollReveal>

        {/* Right Column: Hero Landlord Card Container */}
        <ScrollReveal delay={2} className="relative rounded-3xl overflow-hidden min-h-[560px] shadow-xl group cursor-pointer border border-brand-500/10">
          {/* Background image */}
          <img 
            src="/images/property-owner.png" 
            alt="Beautiful property entry" 
            className="absolute inset-0 w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-700 select-none"
          />
          {/* Overlay gradient */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/90 via-black/50 to-transparent z-10" />

          {/* Card Content Overlay */}
          <div className="relative z-20 p-10 md:p-14 h-full flex flex-col justify-end min-h-[560px]">
            <span className="self-start bg-brand-500 text-white text-xs font-semibold px-4 py-1.5 rounded-full tracking-wide uppercase mb-6">
              Owner Dashboard
            </span>
            <h3 
              className="text-white text-4xl md:text-5xl font-semibold leading-tight mb-4"
              style={{ letterSpacing: '-0.03em' }}
            >
              For Property Owners
            </h3>
            <p className="text-white/80 text-base leading-relaxed max-w-md mb-8" style={{ fontFamily: "'Inter', sans-serif" }}>
              Fill your vacant beds faster. Showcase your property with high-quality galleries, list clear house rules, and manage tenant inquiries directly from your customized owner dashboard.
            </p>
            
            <div>
              <a 
                href="/app/signup.html?role=owner" 
                className="group inline-flex items-center gap-3.5 text-white font-medium text-base hover:text-brand-400 transition-colors duration-200"
              >
                <span>List your property</span>
                <span className="w-10 h-10 rounded-full bg-white/10 group-hover:bg-white text-white group-hover:text-black flex items-center justify-center transition-all duration-300">
                  <ArrowRight className="w-5 h-5" />
                </span>
              </a>
            </div>
          </div>
        </ScrollReveal>
      </div>
    </section>
  );
};
