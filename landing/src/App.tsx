import { Navbar } from './components/Navbar';
import { HeroSection } from './components/HeroSection';
import { InfoSection } from './components/InfoSection';
import { FeaturesMarquee } from './components/FeaturesMarquee';
import { LandlordSection } from './components/LandlordSection';
import { Footer } from './components/Footer';

function App() {
  return (
    <div className="flex flex-col bg-[#FAFDFE] min-h-screen text-slate-900 select-none">
      {/* Floating Navbar */}
      <Navbar />

      {/* Hero Section Container */}
      <HeroSection />

      {/* Other Sections */}
      <InfoSection />
      <FeaturesMarquee />
      <LandlordSection />
      
      {/* Footer */}
      <Footer />
    </div>
  );
}

export default App;
