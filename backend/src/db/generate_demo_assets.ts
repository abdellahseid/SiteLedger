import fs from 'fs';
import path from 'path';

export function generateDemoAssets() {
  const dir = path.join(process.cwd(), 'uploads', 'demo');
  fs.mkdirSync(dir, { recursive: true });

  const files = [
    {
      name: 'waybill-wb-89412.jpg',
      title: 'WAYBILL VERIFICATION: WB-MUG-89412',
      subtitle: 'Muger Cement Enterprise - Dispatch 1,000 Bags',
      color: '#1e293b'
    },
    {
      name: 'truck-plate-84920.jpg',
      title: 'TRUCK LICENSE: ET-3-84920-AA',
      subtitle: 'Trans-Ethiopia Freight SC - Gate 4 Scale',
      color: '#0f172a'
    },
    {
      name: 'damage-cement-caked.jpg',
      title: 'DAMAGE INSPECTION: PALLET #4',
      subtitle: 'Rainwater Ingress Through Tarpaulin - 30 Bags Caked',
      color: '#991b1b'
    }
  ];

  for (const f of files) {
    const svg = `<svg width="600" height="400" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="${f.color}"/>
  <rect x="20" y="20" width="560" height="360" fill="none" stroke="#ffffff" stroke-width="2" stroke-dasharray="6,6"/>
  <text x="50%" y="42%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="22" font-weight="bold" fill="#ffffff">${f.title}</text>
  <text x="50%" y="54%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="15" fill="#e2e8f0">${f.subtitle}</text>
  <text x="50%" y="85%" dominant-baseline="middle" text-anchor="middle" font-family="sans-serif" font-size="11" fill="#94a3b8">SiteLedger Field Evidence Verification System - Ethiopia</text>
</svg>`;
    fs.writeFileSync(path.join(dir, f.name), svg, 'utf8');
  }

  console.log('✅ Demo evidence assets created in uploads/demo/');
}

if (require.main === module) {
  generateDemoAssets();
}
