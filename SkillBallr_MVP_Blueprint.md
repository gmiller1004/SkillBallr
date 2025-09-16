# SkillBallr MVP Blueprint (Updated)

## Overview
SkillBallr is an iOS app designed to empower youth football players (ages 5-14) in Pop Warner and flag football with position-specific education and coaches with playbook management and AI-driven analysis. The MVP now incorporates all previously identified nice-to-have features into the launch scope for a more robust v1.0, including family accounts, progress badges, AR overlays, heatmaps, and more. This expands the timeline to 6-8 months with a lean team (2 devs, 1 designer, product owner), aiming for 300+ player sign-ups, 60% quiz completion, and 50 coach teams in beta. Budget: ~$25K-$30K, including the secured premium domain (SkillBallr.com), Replit hosting, Firebase services, and API costs. Success hinges on engagement (tracked via Firebase Analytics) and feedback from Pop Warner families. Current date: September 16, 2025, 1:41 PM PDT.

## Core Problem and Assumptions

**Problem Solved:** Existing apps (e.g., Hudl, Playmaker X) focus on coach playbooks, not player education. Kids need self-paced, engaging lessons to master positions (QB, WR, LB, RB), while coaches want simple playbook sharing and AI insights to outsmart defenses. Quizzes boost retention by 25-40%; AI analysis adds strategic depth.

**Assumptions:** Players use parent accounts (COPPA-compliant); coaches upload basic play formats (JPEG/PDF); Grok API delivers reliable play analysis. Beta with 30 families validates demand.

## Key MVP Features
All features, including former nice-to-haves, are now must-haves for launch. Features are split into Player Mode (kids) and Coach Mode (adults), with a tabbed SwiftUI interface. Pricing tiers (Free, Player Premium, Coach Pro, Team/Family Unlimited) unlock additional functionality via Apple In-App Purchases (IAP) and subscriptions, styled with the updated color scheme.

| Feature Category | Must-Have Features (Including Former Nice-to-Haves) | Pricing Tier | Rationale & Tech Notes |
|------------------|-----------------------------------------------------|--------------|------------------------|
| **Onboarding & Profiles** | - Dual-role signup: Email/Apple ID; select Player (age/position) or Coach (team name).<br>- Player: Pick QB, WR, LB, RB for a 6-8 module learning path (Premium unlocks all).<br>- Coach: Create team, generate invite links/codes (Pro/Unlimited).<br>- Family accounts (parent links multiple kids, Unlimited).<br>- Position depth charts for coaches (Pro/Unlimited). | Free (basic), $4.99/mo or $29.99/yr (Premium), $9.99/mo or $79.99/yr (Pro), $14.99/mo or $119.99/yr (Unlimited) | Simple flow reduces drop-off; inspired by TeamSnap's roster UX. Core Data for local profiles; Firebase Auth for teams. Styled with skill-blue (#1E3A8A) accents. |
| **Player Education Modules** | - 6 modules/position (e.g., QB: "Role: Reading Defenses," "Throwing Basics"; Free limited to 1 position).<br>- Format: Short text/videos (1-2 min, pre-loaded from USA Football resources) + 2D diagrams.<br>- Quizzes: 5-10 MCQs/module (Free: 3/month; Premium: unlimited) with instant feedback/scores.<br>- Progress badges/streaks (Premium).<br>- Self-review video upload (Premium). | Free (limited), $4.99/mo or $29.99/yr (Premium) | Core loop: Learn → Quiz → Retain. Modeled on SkillShark's evaluations. Static JSON for content; QuizKit or custom SwiftUI. Uses skill-orange (#F97316) for badges. |
| **Playbook Visualization for Players** | - View coach-uploaded plays filtered by position (e.g., WR sees routes; Premium for animations).<br>- 2D viewer: Tap to animate routes, zoom on role, with tooltips (e.g., "Slant at 45°"; Premium).<br>- Animation speed controls (Premium).<br>- AR overlay for real-world play views (using ARKit on compatible devices; Premium). | Free (basic), $4.99/mo or $29.99/yr (Premium) | Ties education to real plays; like Playrbook's sims but position-focused. SVG/Canvas for animations; ARKit for AR. Dark theme grays (#1F2937 for cards). |
| **Coach Playbook Upload & Team Management** | - Upload plays: Drag-drop JPEG/PDF or draw (touch-based lines/routes; Pro/Unlimited).<br>- Assign positions; share via invites (players auto-join; Pro/Unlimited).<br>- Dashboard: Team quiz averages (Pro/Unlimited).<br>- Export plays to wristbands/print (Pro/Unlimited).<br>- Multi-team support (Unlimited). | $9.99/mo or $79.99/yr (Pro), $14.99/mo or $119.99/yr (Unlimited) | Simplifies coaching; echoes FirstDown PlayBook's tools. Firebase Storage (10-play limit/team). Dashboard in gray-800 (#1F2937). |
| **AI Effectiveness Calculator** | - Input: Select play + defense (e.g., "Cover 2 vs. slant"; Pro/Unlimited).<br>- Output: Grok API text analysis (e.g., "65% success—middle gap weak; add hot route"; Pro/Unlimited).<br>- Simple prompt engineering for quick eval.<br>- Visual heatmaps for gaps (Pro/Unlimited).<br>- Historical play success tracking (Unlimited). | $9.99/mo or $79.99/yr (Pro), $14.99/mo or $119.99/yr (Unlimited) | Mimics PFF's matchup tools, youth-friendly. Grok API (https://x.ai/api); free tier for beta. Heatmaps in skill-orange (#F97316). |
| **One-Time Add-Ons (IAPs)** | - Extra position pack (e.g., DB/OL).<br>- Custom AR playbook template.<br>- Lifetime badge unlock. | $2.99 each | Low-commitment upsells; 20% of revenue from add-ons in similar apps. |

## Technical Architecture

### Frontend (iOS App)
SwiftUI for kid-friendly UI (large fonts, vibrant colors: skill-blue #1E3A8A, skill-orange #F97316, dark theme grays #111827 to #D1D5DB) and coach dashboards. Use Cursor with Grok Code 4 Fast for rapid prototyping and Xcode for final builds. Integrate AVKit for videos, ARKit for AR overlays, StoreKit 2 for IAP/subscriptions.

### Backend/Data
Replit hosts the backend server (Node.js/Express with TypeScript, running on port 5000) and production landing page at https://skillballr.com. PostgreSQL via Neon (serverless) with Drizzle ORM for type-safe operations. Database schema: users (players/coaches/parents with auth), teams (with coach relationships), plays (with AI analysis), progress (module tracking/badges), contactSubmissions (marketing), modules (metadata for sync: id, position, version, title, text, videoUrl, quizQuestions, diagrams, updatedAt). Firebase for auth/sync; Core Data for offline modules/quizzes in app.

### AI Integration
Grok API (XAI_API_KEY as Replit secret) for play analysis with structured responses (effectiveness, strengths/weaknesses, recommendations, confidence).

### Security
JWT auth with bcrypt hashing, CORS for iOS, Zod validation, parameterized queries.

### Frontend (Landing Page)
React with TypeScript/Vite, Tailwind CSS with shadcn/ui, TanStack Query for state, Wouter for routing, React Hook Form with Zod. Sections: Hero (logo, headline, CTA), Features (cards for Position Mastery, AI Analysis, AR Learning, Team Management), For Players/Coaches (tailored content), Testimonials (carousel), Contact Form, Footer (links to Privacy, Terms, COPPA). Hosted live at https://skillballr.com with color scheme: skill-blue (#1E3A8A) for accents, skill-orange (#F97316) for CTAs, gray-800 (#1F2937) for cards, gray-300 (#D1D5DB) for text.

### Content
Pre-built modules from USA Football; template-driven quizzes. Modules stored client-side (Core Data/assets) for offline, with Replit sync for updates.

### Tools
Xcode/Cursor for app dev; Replit for web/backend; TestFlight, Firebase Analytics. Follow Apple's educational app guidelines (no ads, COPPA-compliant).

## Development Roadmap (All Features in Launch Scope)

### Weeks 1-3: Planning & Design (Sep-Oct 2025)
- Wireframes (Figma): Player/coach flows, quiz UI, playbook viewer, AR prototypes.
- User stories: "As a player, I quiz on WR routes"; "As a coach, I analyze plays with AI."
- Domain secured: SkillBallr.com purchased and tied to Replit landing page (https://skillballr.com) as production domain.
- Setup Grok API key, Firebase project; initial Replit environment for database and integrations.

### Weeks 4-12: Core Build (Oct-Dec 2025)
- Onboarding, modules, quizzes for 4 positions (QB, WR, LB, RB).
- Coach upload/team invite system; 2D/AR playbook viewer with animations.
- Integrate Grok API for AI analysis (text + heatmaps).
- Add family accounts, badges, self-review uploads, multi-team support.
- Implement IAP/subscription tiers (Free, Player Premium, Coach Pro, Team Unlimited) with StoreKit 2, using skill-blue (#1E3A8A) and skill-orange (#F97316) for UI elements.

### Weeks 13-20: Advanced Integration & Polish (Jan-Feb 2026)
- Implement AR overlays, wristband exports, historical tracking.
- Setup Replit for confirmation emails (GoDaddy SMTP), Apple Push Notifications, and full database sync.
- Position depth charts, animation controls.

### Weeks 21-26: Testing & Launch (Mar-Apr 2026)
- Beta with 30 coaches/100 players via TestFlight; fix quiz scoring, upload bugs, AR device compatibility.
- End-to-end testing: Emails, notifications, AI accuracy, IAP restores.
- App Store submission; promote via https://skillballr.com landing page with dark theme grays.

### Post-Launch (v1.1, May 2026+)
Iterate based on feedback; expand positions (e.g., DB, OL); prep multi-sport modules.

## Risks & Mitigation

- **Expanded Scope:** Including all features extends timeline—mitigate with Cursor/Grok Code 4 Fast for faster coding; prioritize core (education/AI) in sprints.
- **Domain Cost:** SkillBallr.com secured (~$1K-$5K assumed); budget adjusted—monitor renewal fees.
- **Content Accuracy:** Validate modules with a Pop Warner coach.
- **AI Reliability:** Grok API variance—use guided prompts, static tips as backup. Monitor costs (https://x.ai/api).
- **Engagement Split:** Balance player/coach usage via targeted beta invites.
- **Upload Issues:** Limit file formats (JPEG/PDF); add in-app tutorials.
- **Replit Limits:** Production domain on free tier may cap—upgrade to paid (~$7/month) if needed for database/notifications.
- **IAP Adoption:** Low conversion risk—offer 7-day trial, in-app upsells, family sharing.

## Updated Elevator Pitch
SkillBallr transforms how kids in Pop Warner and flag football learn their game. Players pick their position—QB, WR, LB, or more—and dive into tailored lessons, quizzes, badges, and AR simulations that make routes, tackling, and gaps fun and clear. Coaches upload playbooks, invite teams, export wristbands, and use AI with heatmaps to analyze plays against defenses, ensuring smarter strategies. With 3 million youth players craving engaging tools, SkillBallr (at https://skillballr.com) turns rookies into confident athletes and coaches into game-changers. Start free, unlock premium for $4.99/month—join the huddle!

## Domain Notes
**SkillBallr.com:** Secured premium domain; tied to Replit as production domain (https://skillballr.com). Hosted landing page live with updated color scheme (skill-blue #1E3A8A, skill-orange #F97316, dark theme grays); monitor GoDaddy renewal costs.

**Action:** Integrate GoDaddy SMTP for emails; expand landing page traffic via X campaigns.
