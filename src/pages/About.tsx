import Navbar from '../components/Navbar';
import Footer from '../components/Footer';

export default function About() {
  const team = [
    { name: 'المهندس: عبدالله غازي', role: 'المدير العام', icon: '👨‍💻', color: 'primary' },
    { name: 'المهندس: محمد غازي', role: 'مدير المبيعات', icon: '👨‍💼', color: 'accent' },
    { name: 'المصمم: علي الصماط', role: 'المصمم المتألق', icon: '👨‍💻', color: 'primary' }
  ];

  return (
    <div className="min-h-screen bg-background text-white overflow-hidden">
      <Navbar />

      <div className="container mt-20 mb-20 relative px-3 md:px-0">
        {/* Hero Section */}
        <section className="about-hero mb-8 md:mb-16">
          <div className="about-glow-sphere about-glow-sphere-primary"></div>
          <div className="about-glow-sphere about-glow-sphere-accent"></div>
          <div className="about-hero-ring about-hero-ring-1"></div>
          <div className="about-hero-ring about-hero-ring-2"></div>

          <div className="relative z-10 text-center">
            <p className="text-xs md:text-sm uppercase tracking-[0.2em] md:tracking-[0.4em] text-primary/75 mb-3 md:mb-6 animate-fade-in-up">أثناء القيادة نحو المستقبل</p>
            <h1 className="text-2xl md:text-4xl lg:text-5xl font-bold mb-3 md:mb-6 animate-fade-in-up">اكتشف عالم <span className="glow-text">التميز</span> الخيالي</h1>
            <p className="text-sm md:text-base lg:text-lg text-muted-foreground mb-6 md:mb-8 animate-fade-in-up leading-relaxed">
              هنا في بوقاتي كار، ندمج الأناقة التقنية مع تجربة مستخدم سريعة وممتعة، ونبني لكل عميل رحلة مميزة في عالم السيارات الفاخرة.
            </p>
            <div className="mt-6 md:mt-10 flex flex-wrap justify-center gap-2 md:gap-4 animate-fade-in-up">
              <span className="glow-pill text-xs md:text-sm">🚀 أداء فائق</span>
              <span className="glow-pill text-xs md:text-sm">✨ تصميم متألق</span>
              <span className="glow-pill text-xs md:text-sm">🔒 ضمان الثقة</span>
            </div>
          </div>
        </section>

        {/* Highlights */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3 md:gap-6 mb-12 md:mb-20">
          <div className="about-card about-card-pulse animate-fade-in-up">
            <div className="about-card-top"></div>
            <h2 className="text-xl md:text-3xl font-bold mb-3 md:mb-4 text-primary">شغف في كل رحلة</h2>
            <p className="text-muted-foreground leading-relaxed text-sm md:text-base">
              نقدّم أفضل الخيارات المستوردة والمحلية مع تجربة شراء سلسة تبدأ من أول نقرة.
            </p>
          </div>
          <div className="about-card about-card-glow animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
            <div className="about-card-top"></div>
            <h2 className="text-xl md:text-3xl font-bold mb-3 md:mb-4 text-accent">خدمة بخبرة</h2>
            <p className="text-muted-foreground leading-relaxed text-sm md:text-base">
              فريقنا يجد لك السيارة المناسبة ويضمن لك شروط بيع واضحة وأسعار تنافسية.
            </p>
          </div>
          <div className="about-card about-card-spark animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
            <div className="about-card-top"></div>
            <h2 className="text-xl md:text-3xl font-bold mb-3 md:mb-4 text-primary">رحلة غير منتهية</h2>
            <p className="text-muted-foreground leading-relaxed text-sm md:text-base">
              تصميم الصفحة والتفاعل هنا مصنوع ليجعل تجربة الزائر أكثر إشراقًا وحيوية.
            </p>
          </div>
        </div>

        {/* Stats Section */}
        <section className="about-stats mb-12 md:mb-20">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-6 text-center">
            <div className="about-stat animate-fade-in-up" style={{ animationDelay: '0.1s' }}>
              <div className="about-stat-number text-xl md:text-3xl">+5000</div>
              <div className="about-stat-label text-xs md:text-base">عميل راضي</div>
            </div>
            <div className="about-stat animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
              <div className="about-stat-number text-xl md:text-3xl">+2000</div>
              <div className="about-stat-label text-xs md:text-base">سيارة مباعة</div>
            </div>
            <div className="about-stat animate-fade-in-up" style={{ animationDelay: '0.3s' }}>
              <div className="about-stat-number text-xl md:text-3xl">+100</div>
              <div className="about-stat-label text-xs md:text-base">ماركة عالمية</div>
            </div>
            <div className="about-stat animate-fade-in-up" style={{ animationDelay: '0.4s' }}>
              <div className="about-stat-number text-xl md:text-3xl">24/7</div>
              <div className="about-stat-label text-xs md:text-base">دعم فني</div>
            </div>
          </div>
        </section>

        {/* Team Section */}
        <div className="text-center mb-8 md:mb-16">
          <h2 className="text-3xl md:text-5xl font-bold mb-2 md:mb-4 glow-text">نخبة القيادة</h2>
          <div className="w-20 md:w-32 h-1.5 mx-auto rounded-full bg-linear-to-r from-primary to-accent"></div>
          <p className="mt-3 md:mt-6 text-muted-foreground text-sm md:text-base">الفريق الذي يقود غازي كار نحو مستقبل أكثر تألقًا.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:gap-10">
          {team.map((member, i) => (
            <div key={i} className="about-team-card group">
              <div className={`about-team-banner ${member.color === 'primary' ? 'about-team-banner-primary' : 'about-team-banner-accent'}`}>
                <span className="about-team-icon text-3xl md:text-4xl">{member.icon}</span>
              </div>
              <div className="p-4 md:p-8 text-center">
                <h3 className="text-lg md:text-2xl font-bold mb-1 md:mb-2 group-hover:text-primary transition-colors">{member.name}</h3>
                <p className="text-muted-foreground font-semibold mb-3 md:mb-6 text-xs md:text-sm">{member.role}</p>
                <div className="flex justify-center gap-2 md:gap-4">
                  <a href="http://www.facebook.com" className="footer-social-link">f</a>
                  <a href="http://www.x.com" className="footer-social-link">𝕏</a>
                  <a href="http://www.instgram.com" className="footer-social-link">📷</a>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <Footer />
    </div>
  );
}
