import { Navbar } from './components/Navbar';
import { HeroSection } from './components/HeroSection';
import { InfoSection } from './components/InfoSection';
import { FeaturesMarquee } from './components/FeaturesMarquee';
import { LandlordSection } from './components/LandlordSection';
import { Footer } from './components/Footer';

function App() {
  return (
    <div className="flex flex-col bg-[#F5F5F5] min-h-screen">
      {/* Navbar + Hero Container */}
      <div className="h-screen flex flex-col overflow-hidden relative select-none">
        <Navbar />
        <HeroSection />
      </div>

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
