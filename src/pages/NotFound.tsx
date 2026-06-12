import { Link } from 'wouter';

export default function NotFound() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-background">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-primary mb-4">404</h1>
        <p className="text-2xl text-secondary mb-6" style={{ fontFamily: "'Playfair Display', serif" }}>
          الصفحة غير موجودة
        </p>
        <p className="text-muted-foreground mb-8 max-w-md">
          عذراً، الصفحة التي تبحث عنها غير موجودة أو تم نقلها.
        </p>
        <Link href="/" className="btn btn-primary">
  العودة للرئيسية
</Link>
      </div>
    </div>
  );
}
