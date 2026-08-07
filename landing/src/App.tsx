import { useEffect, useState } from "react";

import envelopesImage from "../assets/envelopes.png";
import emotionsImage from "../assets/emotions.png";
import logoImage from "../assets/keepi-logo.png";
import mascotImage from "../assets/keepi-mascot.png";
import tradesImage from "../assets/trades.png";

type Feature = {
  title: string;
  description: string;
  image: string;
};

type SummaryPoint = {
  label: string;
  description: string;
};

type ReportRow = {
  label: string;
  size: number;
};

const summaryPoints: SummaryPoint[] = [
  {
    label: "Trades",
    description: "Record purchases and investments in the language Keepi uses every day.",
  },
  {
    label: "Envelopes",
    description: "Give each type of spending a clear budget and place to live.",
  },
  {
    label: "Reflection",
    description: "Connect money decisions to the feelings that shaped them.",
  },
];

const features: Feature[] = [
  {
    title: "Record trades",
    description: "Purchases, investments, and financial moves are quick to log and easy to revisit.",
    image: tradesImage,
  },
  {
    title: "Define envelopes",
    description: "Set up spending areas that make your budget visible without turning it into homework.",
    image: envelopesImage,
  },
  {
    title: "Reflect on motives",
    description: "Capture the emotion behind a trade so patterns become personal, not just numerical.",
    image: emotionsImage,
  },
];

const reportRows: ReportRow[] = [
  { label: "Food", size: 82 },
  { label: "Home", size: 54 },
  { label: "Learning", size: 38 },
];

function App() {
  const [isScrolled, setIsScrolled] = useState(false);
  const currentYear = new Date().getFullYear();

  useEffect(() => {
    const syncHeader = () => setIsScrolled(window.scrollY > 24);

    syncHeader();
    window.addEventListener("scroll", syncHeader, { passive: true });

    return () => window.removeEventListener("scroll", syncHeader);
  }, []);

  return (
    <>
      <header className={`site-header ${isScrolled ? "is-scrolled" : ""}`} aria-label="Primary navigation">
        <a className="brand" href="#top" aria-label="Keepi home">
          <img src={logoImage} alt="Keepi" />
        </a>
        <nav className="nav-links" aria-label="Page sections">
          <a href="#how-it-works">How it works</a>
          <a href="#insights">Insights</a>
          <a href="#privacy">Privacy</a>
          <a href="#download">Download</a>
        </nav>
        <a className="header-cta" href="#download">
          Get started
        </a>
      </header>

      <main id="top">
        <Hero />
        <SummaryBand />
        <HowItWorks />
        <Insights />
        <Download />
        <Privacy />
      </main>

      <footer className="site-footer">
        <span>Keepi</span>
        <a href="#privacy">Privacy policy</a>
        <span>{currentYear}</span>
      </footer>
    </>
  );
}

function Hero() {
  return (
    <section className="hero" aria-labelledby="hero-title">
      <div className="hero-inner">
        <div className="hero-copy">
          <p className="eyebrow">Finance tracking with feeling</p>
          <h1 id="hero-title">Keepi</h1>
          <p className="hero-lede">
            Track your trades, organize your envelopes, and reflect on what motivated every purchase.
          </p>
          <div className="hero-actions" aria-label="Primary actions">
            <a className="button primary" href="#download">
              Download on the App Store
            </a>
            <a className="button secondary" href="#how-it-works">
              See how it works
            </a>
          </div>
        </div>

        <div className="product-stage" aria-label="Keepi app preview">
          <div className="phone-shell">
            <div className="phone-screen">
              <div className="app-top">
                <img src={logoImage} alt="" />
                <img className="app-mascot" src={mascotImage} alt="" />
              </div>
              <section className="envelope-panel" aria-label="My envelopes preview">
                <p>My envelopes</p>
                <div className="envelope-row">
                  <span>Groceries</span>
                  <strong>$320</strong>
                </div>
                <div className="envelope-row">
                  <span>Fun</span>
                  <strong>$150</strong>
                </div>
              </section>
              <section className="trade-panel" aria-label="Last trades preview">
                <div className="panel-heading">
                  <h2>Last trades</h2>
                  <span>+</span>
                </div>
                <div className="trade-item">
                  <span className="trade-dot yellow" />
                  <div>
                    <strong>Coffee run</strong>
                    <p>Motivated by comfort</p>
                  </div>
                  <b>$5</b>
                </div>
                <div className="trade-item">
                  <span className="trade-dot red" />
                  <div>
                    <strong>New headphones</strong>
                    <p>Felt excited</p>
                  </div>
                  <b>$89</b>
                </div>
              </section>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function SummaryBand() {
  return (
    <section className="intro-band" aria-label="Keepi summary">
      {summaryPoints.map((point) => (
        <div key={point.label}>
          <strong>{point.label}</strong>
          <span>{point.description}</span>
        </div>
      ))}
    </section>
  );
}

function HowItWorks() {
  return (
    <section className="section split" id="how-it-works">
      <div className="section-copy">
        <p className="eyebrow dark">A calmer money habit</p>
        <h2>Turn everyday purchases into something you can understand.</h2>
        <p>
          Keepi keeps the practical parts simple: add a trade, choose an envelope, set the value, and keep moving. The
          reflection layer helps you notice patterns beyond totals.
        </p>
      </div>
      <div className="feature-grid">
        {features.map((feature) => (
          <article className="feature-card" key={feature.title}>
            <img src={feature.image} alt="" />
            <h3>{feature.title}</h3>
            <p>{feature.description}</p>
          </article>
        ))}
      </div>
    </section>
  );
}

function Insights() {
  return (
    <section className="insights" id="insights">
      <div className="insights-inner">
        <div className="report-preview" aria-label="Spending tendencies preview">
          <p className="report-title">These are your tendencies</p>
          {reportRows.map((row) => (
            <div className="bar-row" key={row.label}>
              <span>{row.label}</span>
              <i style={{ "--size": `${row.size}%` } as React.CSSProperties} />
            </div>
          ))}
        </div>
        <div className="section-copy light">
          <p className="eyebrow">Reports that feel usable</p>
          <h2>See where your money goes and what keeps pulling it there.</h2>
          <p>
            Keepi's reports surface your most common trade categories, helping you spot the envelopes that deserve
            attention before small patterns become expensive ones.
          </p>
        </div>
      </div>
    </section>
  );
}

function Download() {
  return (
    <section className="download" id="download">
      <div className="download-copy">
        <img src={logoImage} alt="Keepi" />
        <h2>Build a better relationship with your money.</h2>
        <p>Start tracking trades with envelopes, emotion check-ins, and clear spending tendencies.</p>
      </div>
      <a className="button primary dark" href="mailto:candidohdiego@gmail.com?subject=Keepi%20App%20Store%20link">
        Ask for the App Store link
      </a>
    </section>
  );
}

function Privacy() {
  return (
    <section className="privacy" id="privacy" aria-labelledby="privacy-title">
      <div>
        <p className="eyebrow dark">Privacy policy</p>
        <h2 id="privacy-title">Your financial reflections stay yours.</h2>
      </div>
      <div className="privacy-copy">
        <p>
          Keepi stores an anonymous account identifier and the entries, envelope budgets, feelings, tags, reflections,
          notes, and journal text you choose to add. Firebase Authentication and Cloud Firestore provide account access
          and syncing.
        </p>
        <p>
          Keepi does not sell your data, serve targeted advertising, or track you across other companies' apps and
          websites. Data remains until you delete it from <strong>Settings &gt; Delete my data</strong> in the app.
        </p>
        <a href="mailto:candidohdiego@gmail.com?subject=Keepi%20Privacy">Contact Keepi about privacy</a>
      </div>
    </section>
  );
}

export default App;
