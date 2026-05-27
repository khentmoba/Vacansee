import { ArrowRight, ShieldCheck, MapPin } from 'lucide-react';

export const InfoSection: React.FC = () => {
  return (
    <section className="bg-[#F5F5F5] px-6 py-28" id="map-view">
      <div className="max-w-[88rem] mx-auto">
        {/* Row 1: Heading + Paragraph Intro */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-20 items-start">
          <div>
            <h2 
              className="text-black text-5xl md:text-6xl font-semibold leading-tight mb-8"
              style={{ letterSpacing: '-0.03em' }}
            >
              Smart Student Living.
            </h2>
            <a
              href="/map"
              className="group inline-flex items-center gap-3 bg-black text-white text-sm font-medium pl-6 pr-1.5 py-1.5 rounded-full hover:bg-gray-800 transition-colors duration-200 cursor-pointer"
            >
              <span>Explore map</span>
              <span className="bg-white rounded-full p-2 text-black transition-transform duration-300 group-hover:translate-x-0.5">
                <ArrowRight className="w-4 h-4" />
              </span>
            </a>
          </div>
          <div>
            <p className="text-black/70 text-2xl md:text-3xl md:leading-relaxed font-light mt-1">
              Find verified boarding houses that fit your budget, complete with transparent pricing, accurate amenity filters, and direct landlord contact.
            </p>
          </div>
        </div>

        {/* Row 2: 4-Column Responsive Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {/* Card 1: Designed for focus (Double Column on Large Screens) */}
          <div 
            className="relative lg:col-span-2 rounded-3xl overflow-hidden min-h-[360px] p-8 flex flex-col justify-between shadow-md group hover:shadow-lg transition-all duration-300 cursor-pointer"
          >
            {/* Background Image */}
            <img 
              src="/images/desk-setup.png" 
              alt="Cozy study area" 
              className="absolute inset-0 w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-700 select-none"
            />
            <div className="absolute inset-0 bg-gradient-to-t from-black/40 via-black/10 to-transparent z-10" />

            <div className="relative z-20 flex justify-start items-center">
              <span className="bg-white/90 backdrop-blur text-black text-xs font-semibold px-4 py-1.5 rounded-full tracking-wide uppercase">
                Amenties Focus
              </span>
            </div>

            <div className="relative z-20 mt-auto flex flex-col items-start gap-4">
              <h3 
                className="text-white text-3xl font-semibold leading-snug tracking-tight"
                style={{ letterSpacing: '-0.02em' }}
              >
                Designed for focus
              </h3>
              <p 
                className="text-white/90 text-sm md:text-base max-w-sm bg-black/40 backdrop-blur-md rounded-2xl p-4 border border-white/10"
                style={{ fontFamily: "'Inter', sans-serif" }}
              >
                Filter by essential amenities like inclusive WiFi, study areas, and curfew rules to match your academic schedule.
              </p>
            </div>
          </div>

          {/* Card 2: Walk to class, save time */}
          <div className="bg-[#1E293B] rounded-3xl p-8 min-h-[360px] flex flex-col justify-between shadow-md hover:shadow-xl hover:translate-y-[-4px] transition-all duration-300 cursor-pointer group">
            <div className="bg-white/10 w-12 h-12 rounded-2xl flex items-center justify-center text-white mb-6 group-hover:scale-110 transition-transform duration-300">
              <MapPin className="w-6 h-6 text-brand-400" />
            </div>
            
            <div className="mt-auto">
              <h3 className="text-white text-2xl font-semibold leading-snug tracking-tight mb-3">
                Walk to class,<br />save time.
              </h3>
              <p className="text-white/60 text-base leading-relaxed" style={{ fontFamily: "'Inter', sans-serif" }}>
                View exact distances to major university gates and local transport routes.
              </p>
            </div>
          </div>

          {/* Card 3: Verified listings */}
          <div className="bg-[#1E293B] rounded-3xl p-8 min-h-[360px] flex flex-col justify-between shadow-md hover:shadow-xl hover:translate-y-[-4px] transition-all duration-300 cursor-pointer group">
            <div className="bg-white/10 w-12 h-12 rounded-2xl flex items-center justify-center text-white mb-6 group-hover:scale-110 transition-transform duration-300">
              <ShieldCheck className="w-6 h-6 text-brand-400" />
            </div>

            <div className="mt-auto">
              <h3 className="text-white text-2xl font-semibold leading-snug tracking-tight mb-3">
                Verified<br />listings.
              </h3>
              <p className="text-white/60 text-base leading-relaxed" style={{ fontFamily: "'Inter', sans-serif" }}>
                Every pad is checked for accuracy. Say goodbye to outdated photos and hidden utility fees.
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};
