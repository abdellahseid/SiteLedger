import fs from 'fs';
import path from 'path';
import multer from 'multer';

const uploadDir = path.resolve(process.cwd(), process.env.UPLOAD_DIR || './uploads');

// Ensure upload directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Ensure demo directory exists with sample evidence
const demoDir = path.join(uploadDir, 'demo');
if (!fs.existsSync(demoDir)) {
  fs.mkdirSync(demoDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname) || '.jpg';
    const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, `evidence-${uniqueSuffix}${ext}`);
  },
});

export const upload = multer({
  storage,
  limits: { fileSize: 25 * 1024 * 1024 }, // 25MB max
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file format. Only JPEG, PNG, WEBP, and PDF are supported.'));
    }
  },
});

export class StorageService {
  static getPublicUrl(filename: string): string {
    const baseUrl = process.env.BASE_URL || 'http://localhost:4000';
    return `${baseUrl}/uploads/${path.basename(filename)}`;
  }
}
