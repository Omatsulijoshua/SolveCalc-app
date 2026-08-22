const sharp = require('sharp');
const path = require('path');
const fs = require('fs');

const srcImage = path.resolve('C:/Users/Joshua/.gemini/antigravity/brain/9664ef33-96e1-4d93-84ac-3672f8f177a0/solvecalc_app_icon_1787393601104.jpg');
const appDir = path.resolve(__dirname, '../../app');

const androidRes = path.join(appDir, 'android/app/src/main/res');
const iosAppIcon = path.join(appDir, 'ios/Runner/Assets.xcassets/AppIcon.appiconset');
const macosAppIcon = path.join(appDir, 'macos/Runner/Assets.xcassets/AppIcon.appiconset');
const webIcons = path.join(appDir, 'web/icons');

const targets = [
  // Android Mipmaps
  { dir: path.join(androidRes, 'mipmap-mdpi'), file: 'ic_launcher.png', size: 48 },
  { dir: path.join(androidRes, 'mipmap-hdpi'), file: 'ic_launcher.png', size: 72 },
  { dir: path.join(androidRes, 'mipmap-xhdpi'), file: 'ic_launcher.png', size: 96 },
  { dir: path.join(androidRes, 'mipmap-xxhdpi'), file: 'ic_launcher.png', size: 144 },
  { dir: path.join(androidRes, 'mipmap-xxxhdpi'), file: 'ic_launcher.png', size: 192 },

  // iOS App Icons
  { dir: iosAppIcon, file: 'Icon-App-1024x1024@1x.png', size: 1024 },
  { dir: iosAppIcon, file: 'Icon-App-83.5x83.5@2x.png', size: 167 },
  { dir: iosAppIcon, file: 'Icon-App-76x76@2x.png', size: 152 },
  { dir: iosAppIcon, file: 'Icon-App-76x76@1x.png', size: 76 },
  { dir: iosAppIcon, file: 'Icon-App-60x60@3x.png', size: 180 },
  { dir: iosAppIcon, file: 'Icon-App-60x60@2x.png', size: 120 },
  { dir: iosAppIcon, file: 'Icon-App-40x40@3x.png', size: 120 },
  { dir: iosAppIcon, file: 'Icon-App-40x40@2x.png', size: 80 },
  { dir: iosAppIcon, file: 'Icon-App-40x40@1x.png', size: 40 },
  { dir: iosAppIcon, file: 'Icon-App-29x29@3x.png', size: 87 },
  { dir: iosAppIcon, file: 'Icon-App-29x29@2x.png', size: 58 },
  { dir: iosAppIcon, file: 'Icon-App-29x29@1x.png', size: 29 },
  { dir: iosAppIcon, file: 'Icon-App-20x20@3x.png', size: 60 },
  { dir: iosAppIcon, file: 'Icon-App-20x20@2x.png', size: 40 },
  { dir: iosAppIcon, file: 'Icon-App-20x20@1x.png', size: 20 },

  // macOS App Icons
  { dir: macosAppIcon, file: 'app_icon_1024.png', size: 1024 },
  { dir: macosAppIcon, file: 'app_icon_512.png', size: 512 },
  { dir: macosAppIcon, file: 'app_icon_256.png', size: 256 },
  { dir: macosAppIcon, file: 'app_icon_128.png', size: 128 },
  { dir: macosAppIcon, file: 'app_icon_64.png', size: 64 },
  { dir: macosAppIcon, file: 'app_icon_32.png', size: 32 },
  { dir: macosAppIcon, file: 'app_icon_16.png', size: 16 },

  // Web Icons & Favicon
  { dir: webIcons, file: 'Icon-192.png', size: 192 },
  { dir: webIcons, file: 'Icon-512.png', size: 512 },
  { dir: webIcons, file: 'Icon-maskable-192.png', size: 192 },
  { dir: webIcons, file: 'Icon-maskable-512.png', size: 512 },
  { dir: path.join(appDir, 'web'), file: 'favicon.png', size: 64 },
];

async function generate() {
  console.log(`Processing SolveCalc Logo from: ${srcImage}`);
  for (const t of targets) {
    if (!fs.existsSync(t.dir)) {
      fs.mkdirSync(t.dir, { recursive: true });
    }
    const dest = path.join(t.dir, t.file);
    await sharp(srcImage)
      .resize(t.size, t.size)
      .png()
      .toFile(dest);
    console.log(`✓ Generated ${t.file} (${t.size}x${t.size}) -> ${path.relative(appDir, dest)}`);
  }
  console.log('Successfully generated all application launcher icons!');
}

generate().catch(console.error);
