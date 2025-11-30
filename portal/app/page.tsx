async function fetchStats() {
  try {
    const apiBase = process.env.NEXT_PUBLIC_API_BASE || "http://localhost:5000";
    const res = await fetch(`${apiBase}/api/stats`, { cache: "no-store", next: { revalidate: 5 } });
    if (!res.ok) return null;
    return res.json();
  } catch {
    return null;
  }
}

export default async function Home() {
  const stats = await fetchStats();
  return (
    <main className="min-h-screen">
      {/* Hero Section */}
      <section className="relative min-h-screen flex items-center justify-center overflow-hidden bg-gradient-to-br from-purple-900 via-black to-indigo-900">
        <div className="absolute inset-0 opacity-20" style={{
          backgroundImage: `url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%239C92AC' fill-opacity='0.1'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")`
        }}></div>
        <div className="relative z-10 text-center px-6 max-w-5xl mx-auto">
          <h1 className="text-6xl md:text-8xl font-extrabold mb-6 bg-gradient-to-r from-purple-400 via-pink-400 to-red-400 bg-clip-text text-transparent">
            SafeHavenWS
          </h1>
          <p className="text-2xl md:text-3xl text-gray-300 mb-8 font-light">
            Empowering Safety Through Blockchain Transparency
          </p>
          <p className="text-lg md:text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
            A decentralized emergency response system that ensures immutable, tamper-proof records of SOS cases, 
            enabling transparent crisis response and volunteer coordination.
          </p>
          <div className="flex flex-wrap gap-4 justify-center">
            <a href="#demo" className="px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 rounded-lg font-semibold hover:from-purple-700 hover:to-pink-700 transition-all transform hover:scale-105">
              View Demo
            </a>
            <a href="/ngo" className="px-8 py-4 bg-gray-800 border border-gray-700 rounded-lg font-semibold hover:bg-gray-700 transition-all">
              NGO Portal
            </a>
            <a href="https://github.com" className="px-8 py-4 bg-gray-800 border border-gray-700 rounded-lg font-semibold hover:bg-gray-700 transition-all">
              GitHub
            </a>
          </div>
          {stats?.success && (
            <div className="mt-16 grid grid-cols-2 md:grid-cols-4 gap-6 max-w-3xl mx-auto">
              <StatCard label="Total Cases" value={stats.total} color="purple" />
              <StatCard label="Open" value={stats.open} color="red" />
              <StatCard label="Acknowledged" value={stats.acknowledged} color="blue" />
              <StatCard label="Resolved" value={stats.resolved} color="green" />
            </div>
          )}
        </div>
      </section>

      {/* About Section */}
      <section id="about" className="py-24 px-6 bg-gray-950">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-4 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            About SafeHavenWS
          </h2>
          <div className="grid md:grid-cols-2 gap-12 mt-16">
            <div className="space-y-6">
              <h3 className="text-2xl font-semibold text-purple-400">The Problem</h3>
              <p className="text-gray-300 leading-relaxed">
                Women's safety reporting systems often suffer from lack of transparency, 
                potential for data tampering, and limited accountability. Traditional centralized 
                systems can be manipulated, and critical emergency information may be lost or altered.
              </p>
              <p className="text-gray-300 leading-relaxed">
                Emergency response systems need immutable records, real-time coordination, and 
                transparent verification to ensure victims receive timely help and incidents are 
                properly documented for legal and safety purposes.
              </p>
            </div>
            <div className="space-y-6">
              <h3 className="text-2xl font-semibold text-purple-400">Our Solution</h3>
              <p className="text-gray-300 leading-relaxed">
                SafeHavenWS leverages blockchain technology to create an immutable, transparent 
                emergency response ecosystem. Every SOS case is permanently recorded on-chain, 
                ensuring data integrity and full traceability.
              </p>
              <p className="text-gray-300 leading-relaxed">
                Our decentralized approach enables real-time coordination between victims, volunteers, 
                and NGOs while maintaining privacy for sensitive user data. Smart contracts enforce 
                role-based access and automate critical workflows like escalation and verification.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Workflow Section */}
      <section id="workflow" className="py-24 px-6 bg-black">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            How It Works
          </h2>
          <div className="space-y-8">
            {[
              { step: "1", title: "User Registration", desc: "Users register securely via Firebase Auth and receive blockchain-based role assignment", icon: "👤" },
              { step: "2", title: "Send SOS Alert", desc: "One-tap SOS button captures GPS location and creates immutable case on blockchain", icon: "🚨" },
              { step: "3", title: "Backend Processing", desc: "Node.js backend receives request, validates data, and interacts with smart contracts via Web3.js", icon: "⚙️" },
              { step: "4", title: "Smart Contract Execution", desc: "CaseContract creates case, CaseRegistry indexes it, and events are emitted for transparency", icon: "🔗" },
              { step: "5", title: "Volunteer Verification", desc: "Verified volunteers can view nearby cases, accept assignments, and submit reports", icon: "✅" },
              { step: "6", title: "NGO Coordination", desc: "NGOs monitor cases, acknowledge incidents, assign volunteers, and track resolution", icon: "🏢" },
              { step: "7", title: "Permanent Record", desc: "All case data, volunteer reports, and status changes are permanently stored on blockchain", icon: "📜" },
            ].map((item, idx) => (
              <div key={idx} className="flex items-start gap-6 p-6 rounded-xl bg-gray-900 border border-gray-800 hover:border-purple-600 transition-all">
                <div className="flex-shrink-0 w-16 h-16 rounded-full bg-gradient-to-r from-purple-600 to-pink-600 flex items-center justify-center text-2xl">
                  {item.icon}
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <span className="text-purple-400 font-bold text-lg">Step {item.step}</span>
                    <h3 className="text-xl font-semibold">{item.title}</h3>
                  </div>
                  <p className="text-gray-400">{item.desc}</p>
                </div>
                {idx < 6 && (
                  <div className="absolute left-1/2 transform -translate-x-1/2 mt-20 w-0.5 h-8 bg-gradient-to-b from-purple-600 to-pink-600 hidden md:block"></div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Tech Stack Section */}
      <section id="tech" className="py-24 px-6 bg-gray-950">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            Tech Stack
          </h2>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {[
              { name: "Flutter", desc: "Cross-platform mobile app for iOS and Android", icon: "📱" },
              { name: "Node.js + Express", desc: "RESTful API backend with Web3.js integration", icon: "⚙️" },
              { name: "Firebase Auth", desc: "Secure user authentication and identity management", icon: "🔐" },
              { name: "Solidity", desc: "Smart contracts for case management and role enforcement", icon: "💎" },
              { name: "Hardhat", desc: "Development environment and testing framework", icon: "🔧" },
              { name: "Web3.js", desc: "Blockchain interaction library for Ethereum-compatible chains", icon: "🌐" },
              { name: "Next.js", desc: "React framework for the presentation website", icon: "⚡" },
              { name: "Tailwind CSS", desc: "Utility-first CSS for modern UI design", icon: "🎨" },
              { name: "Polygon Mumbai", desc: "Testnet for deployment (or local Hardhat for offline)", icon: "🔷" },
            ].map((tech, idx) => (
              <div key={idx} className="p-6 rounded-xl bg-gray-900 border border-gray-800 hover:border-purple-600 transition-all">
                <div className="text-4xl mb-4">{tech.icon}</div>
                <h3 className="text-xl font-semibold mb-2">{tech.name}</h3>
                <p className="text-gray-400 text-sm">{tech.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section id="team" className="py-24 px-6 bg-black">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            Our Team
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            {[
              { name: "Team Member 1", role: "Blockchain Developer", desc: "Smart contract development and Web3 integration" },
              { name: "Team Member 2", role: "Full-Stack Developer", desc: "Backend API and Flutter mobile app" },
              { name: "Team Member 3", role: "Frontend Developer", desc: "Web portal and UI/UX design" },
            ].map((member, idx) => (
              <div key={idx} className="p-6 rounded-xl bg-gray-900 border border-gray-800 text-center">
                <div className="w-24 h-24 rounded-full bg-gradient-to-r from-purple-600 to-pink-600 mx-auto mb-4 flex items-center justify-center text-3xl">
                  👤
                </div>
                <h3 className="text-xl font-semibold mb-2">{member.name}</h3>
                <p className="text-purple-400 mb-3">{member.role}</p>
                <p className="text-gray-400 text-sm">{member.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Journey Section */}
      <section id="journey" className="py-24 px-6 bg-gray-950">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            Development Journey
          </h2>
          <div className="space-y-6">
            {[
              { phase: "Phase 1", title: "Smart Contract Development", desc: "Designed and implemented RoleManagerContract, CaseContract, CaseRegistry, and VolunteerReportContract with comprehensive testing" },
              { phase: "Phase 2", title: "Backend API Implementation", desc: "Built Express.js server with Web3.js integration, case management endpoints, volunteer routes, and automatic escalation worker" },
              { phase: "Phase 3", title: "Flutter Mobile App", desc: "Developed cross-platform app with Firebase Auth, SOS functionality, GPS integration, volunteer dashboard, and case management" },
              { phase: "Phase 4", title: "Web Portal & Dashboard", desc: "Created Next.js presentation website and NGO dashboard with real-time case monitoring, timers, and action controls" },
              { phase: "Phase 5", title: "Integration & Testing", desc: "End-to-end testing with 3 test users and 2 volunteers, verified all workflows including false alarm marking and volunteer reporting" },
            ].map((item, idx) => (
              <div key={idx} className="flex gap-6 p-6 rounded-xl bg-gray-900 border-l-4 border-purple-600">
                <div className="flex-shrink-0">
                  <div className="w-12 h-12 rounded-full bg-gradient-to-r from-purple-600 to-pink-600 flex items-center justify-center font-bold">
                    {idx + 1}
                  </div>
                </div>
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <span className="text-purple-400 font-semibold">{item.phase}</span>
                    <h3 className="text-xl font-semibold">{item.title}</h3>
                  </div>
                  <p className="text-gray-400">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Live Demo Section */}
      <section id="demo" className="py-24 px-6 bg-black">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-4xl font-bold text-center mb-16 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            Live Demo & Results
          </h2>
          <div className="grid md:grid-cols-2 gap-8 mb-12">
            <div className="p-6 rounded-xl bg-gray-900 border border-gray-800">
              <h3 className="text-xl font-semibold mb-4">📱 Flutter Mobile App</h3>
              <p className="text-gray-400 mb-4">
                The SafeHavenWS mobile app allows users to send SOS alerts with GPS coordinates, 
                view their case history, and mark false alarms. Volunteers can view nearby cases 
                and submit reports.
              </p>
              <div className="space-y-2 text-sm text-gray-500">
                <p>• User registration and login</p>
                <p>• One-tap SOS with GPS location</p>
                <p>• My Cases page with case history</p>
                <p>• Volunteer nearby cases view</p>
                <p>• Report submission interface</p>
              </div>
            </div>
            <div className="p-6 rounded-xl bg-gray-900 border border-gray-800">
              <h3 className="text-xl font-semibold mb-4">🔗 Blockchain Integration</h3>
              <p className="text-gray-400 mb-4">
                All SOS cases are stored immutably on the blockchain. Smart contracts enforce 
                role-based permissions and automate case lifecycle management.
              </p>
              <div className="space-y-2 text-sm text-gray-500">
                <p>• Immutable case records</p>
                <p>• Role-based access control</p>
                <p>• Event emission for transparency</p>
                <p>• Volunteer report logging</p>
                <p>• Automatic escalation system</p>
              </div>
            </div>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            <div className="p-6 rounded-xl bg-gradient-to-br from-purple-900/50 to-black border border-purple-800">
              <div className="text-3xl mb-3">✅</div>
              <h4 className="font-semibold mb-2">Functional MVP</h4>
              <p className="text-gray-400 text-sm">All core features implemented and tested</p>
            </div>
            <div className="p-6 rounded-xl bg-gradient-to-br from-purple-900/50 to-black border border-purple-800">
              <div className="text-3xl mb-3">🔒</div>
              <h4 className="font-semibold mb-2">Secure & Private</h4>
              <p className="text-gray-400 text-sm">User identity stored off-chain, only GPS on-chain</p>
            </div>
            <div className="p-6 rounded-xl bg-gradient-to-br from-purple-900/50 to-black border border-purple-800">
              <div className="text-3xl mb-3">🌐</div>
              <h4 className="font-semibold mb-2">Deployable</h4>
              <p className="text-gray-400 text-sm">Works offline with Hardhat or online on Polygon Mumbai</p>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-12 px-6 bg-gray-950 border-t border-gray-800">
        <div className="max-w-6xl mx-auto text-center">
          <h3 className="text-2xl font-bold mb-4 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">
            SafeHavenWS
          </h3>
          <p className="text-gray-400 mb-6">
            Empowering Safety Through Blockchain Transparency
          </p>
          <div className="flex flex-wrap justify-center gap-6 mb-6">
            <a href="https://github.com" className="text-purple-400 hover:text-purple-300 transition-colors">
              GitHub Repository
            </a>
            <a href="/ngo" className="text-purple-400 hover:text-purple-300 transition-colors">
              NGO Dashboard
            </a>
            <a href="#about" className="text-purple-400 hover:text-purple-300 transition-colors">
              About
            </a>
            <a href="#tech" className="text-purple-400 hover:text-purple-300 transition-colors">
              Tech Stack
            </a>
          </div>
          <p className="text-gray-500 text-sm">
            © 2024 SafeHavenWS. Built with ❤️ for women's safety.
          </p>
        </div>
      </footer>
    </main>
  );
}

function StatCard({ label, value, color }: { label: string; value: number; color: string }) {
  const colorClasses = {
    purple: "from-purple-600 to-purple-800",
    red: "from-red-600 to-red-800",
    blue: "from-blue-600 to-blue-800",
    green: "from-green-600 to-green-800",
  };
  return (
    <div className={`p-6 rounded-xl bg-gradient-to-br ${colorClasses[color as keyof typeof colorClasses]} border border-${color}-700`}>
      <div className="text-3xl font-bold mb-2">{value}</div>
      <div className="text-sm text-gray-200">{label}</div>
    </div>
  );
}
