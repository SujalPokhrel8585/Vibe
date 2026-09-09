# Vibe

A full-stack real-time chat application with private & group messaging, reactions, file attachments, live notifications, typing indicators, online presence, and **WebRTC audio/video calling**.

🔗 **Live demo:** [https://vibe-app.duckdns.org](https://vibe-app.duckdns.org) (http://vibe-chat.duckdns.org)

---

## ✨ Features

| Feature                 | Description                                                                       |
| ----------------------- | --------------------------------------------------------------------------------- |
| **Authentication**      | Register / Login with JWT (`x-auth-token`); guest routes redirect logged-in users |
| **Private Chat**        | 1-on-1 conversations with duplicate prevention                                    |
| **Group Chat**          | Named groups with admin roles, add/remove members, leave group, admin transfer    |
| **Messaging**           | Real-time text messages, edit, soft-delete, reply context preserved               |
| **Reactions**           | Emoji reactions on messages (toggle)                                              |
| **Attachments**         | Image, PDF and other file uploads                                                 |
| **Notifications**       | Real-time + grouped unread notifications                                          |
| **Presence**            | Online / offline status + typing indicators                                       |
| **Read Receipts**       | `readBy` tracking on messages                                                     |
| **Audio / Video Calls** | WebRTC 1-1 calls with mute, camera toggle, and TURN fallback                      |
| **Profiles**            | Avatar, banner, bio — view and edit your own or others' profiles                  |
| **Legal Pages**         | Privacy Policy and Terms of Service pages                                         |

---

## 🧰 Tech Stack

### Backend

| Technology         | Version | Purpose                                       |
| ------------------ | ------- | --------------------------------------------- |
| Node.js            | 18+     | Runtime                                       |
| Express.js         | ^5.2    | HTTP API framework                            |
| MongoDB + Mongoose | ^9.8    | Database & ODM                                |
| Socket.io          | ^4.8    | Real-time messaging, presence, call signaling |
| JWT + bcrypt       | —       | Authentication & password hashing             |
| Multer             | ^2.2    | File uploads (local storage)                  |
| dotenv             | ^17.4   | Environment variable management               |

### Frontend

| Technology       | Version | Purpose                            |
| ---------------- | ------- | ---------------------------------- |
| React            | ^19.2   | UI library                         |
| Vite             | ^8.2    | Build tool & dev server            |
| React Router DOM | ^7.18   | Client-side routing                |
| socket.io-client | ^4.8    | Real-time events                   |
| Axios            | ^1.19   | HTTP requests                      |
| Bootstrap 5      | ^5.3    | UI component base & layout         |
| Bootstrap Icons  | ^1.13   | Icon set                           |
| Font Awesome     | ^7.3    | Additional icons                   |
| Native WebRTC    | —       | Audio / video peer-to-peer calls   |
| Context API      | —       | Global state (auth, socket, calls) |

### External Services

| Service                      | Purpose             | Notes                                         |
| ---------------------------- | ------------------- | --------------------------------------------- |
| **MongoDB Atlas** (or local) | Database            | Connection string in `.env`                   |
| **Metered.ca**               | STUN / TURN servers | Required for reliable WebRTC calls behind NAT |
| **Google STUN**              | Free fallback STUN  | `stun:stun.l.google.com:19302`                |

### Infrastructure & Deployment

| Technology              | Purpose                                                                                            |
| ----------------------- | -------------------------------------------------------------------------------------------------- |
| Docker                  | Multi-stage build for the backend API                                                              |
| Amazon ECR              | Container image registry                                                                           |
| Amazon EC2              | Application host (Ubuntu, provisioned via Terraform)                                               |
| Terraform               | Infrastructure as code (EC2, security group, Elastic IP)                                           |
| Nginx                   | Reverse proxy — static frontend, `/api`, `/uploads`, `/socket.io` (with WebSocket upgrade support) |
| Let's Encrypt / Certbot | Free TLS certificate, auto-renewing                                                                |
| GitHub Actions          | CI/CD — builds, pushes to ECR, and redeploys on every push to `main`                               |

---

## 📁 Project Structure

```
Vibe/
├── .github/workflows/     # CI/CD pipeline (GitHub Actions)
├── infra/                 # Terraform infrastructure-as-code
├── Vibe-backend-api/      # Express + Socket.io + MongoDB
├── Vibe-frontend/         # React + Vite
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── .gitignore
└── README.md              # ← you are here
```

---

## 🚀 Installation & Setup (local development)

### Prerequisites

- Node.js 18+
- MongoDB (local or Atlas)
- Git

### 1. Clone the repository

```bash
git clone https://github.com/SujalPokhrel8585/Vibe.git
cd Vibe
```

### 2. Backend setup

```bash
cd Vibe-backend-api
npm install
cp .env.example .env   # then fill in your own values
npm run dev             # development (nodemon)
```

API available at `http://localhost:3000`. See [`Vibe-backend-api/README.md`](./Vibe-backend-api/README.md) for the full list of environment variables.

### 3. Frontend setup

```bash
cd ../Vibe-frontend
npm install
cp .env.example .env   # then fill in your own values
npm run dev
```

App available at `http://localhost:5173`. See [`Vibe-frontend/README.md`](./Vibe-frontend/README.md) for details.

---

## ☁️ Deployment

The live demo runs on a single EC2 instance:

```
Browser ──HTTPS──▶ Nginx (reverse proxy + TLS) ──▶ Docker container (Express + Socket.io)
                       │                                    │
                       └──serves──▶ React static build      └──▶ MongoDB Atlas (external)
```

- Backend runs as a Docker container, pulled from Amazon ECR
- Frontend is a static Vite build served directly by Nginx
- Nginx handles TLS termination (Let's Encrypt) and proxies `/api`, `/uploads`, and `/socket.io` (with WebSocket upgrade headers) to the backend container
- Infrastructure (EC2 instance, security group, Elastic IP) is provisioned via Terraform (`infra/`)
- GitHub Actions builds and redeploys automatically on every push to `main`

> **Note:** file uploads are currently stored on the server via a Docker volume rather than object storage. Migrating to Amazon S3 is a planned improvement — see [Known limitations](./SECURITY.md#known-limitations).

---

## 🔑 Authentication

- Protected HTTP routes require header: `x-auth-token: <jwt>`
- Obtain token via:
  - `POST /api/users/register`
  - `POST /api/users/login`
- Socket.io connections authenticate with the same JWT:
  ```js
  io("http://localhost:3000", { auth: { token: "<jwt>" } });
  ```

---

## 📡 API Overview

| Module        | Base Route           | Key Endpoints                                 |
| ------------- | -------------------- | --------------------------------------------- |
| Users         | `/api/users`         | register, login, profile, avatar, password    |
| Conversations | `/api/chats`         | create private/group, list, add/remove member |
| Messages      | `/api/messages`      | create, paginated get, edit, soft-delete      |
| Reactions     | `/api/reactions`     | add/toggle, get by message                    |
| Attachments   | `/api/attachments`   | upload, get by message                        |
| Notifications | `/api/notifications` | list (grouped), unread count, mark read       |

Static files are served from:

```
/uploads/<avatars|attachments|banners|groupAvatars>/<filename>
```

---

## 🔌 Real-Time Events (Socket.io)

### Messaging & Presence

| Event                    | Direction | Description                       |
| ------------------------ | --------- | --------------------------------- |
| `joinConversation`       | C → S     | Join a conversation room          |
| `leaveConversation`      | C → S     | Leave a conversation room         |
| `newMessage`             | S → C     | New message broadcast             |
| `newNotification`        | S → C     | Personal notification push        |
| Typing / presence events | both      | Online status + typing indicators |

### WebRTC Call Signaling

| Event                           | Direction | Description                    |
| ------------------------------- | --------- | ------------------------------ |
| `call:invite`                   | C → S → C | Notify callee of incoming call |
| `call:offer`                    | C → S → C | SDP offer                      |
| `call:answer`                   | C → S → C | SDP answer                     |
| `call:ice-candidate`            | C → S → C | ICE candidate exchange         |
| `call:accept` / `call:accepted` | both      | Call accepted                  |
| `call:reject` / `call:rejected` | both      | Call rejected / busy           |
| `call:end`                      | both      | Hang up                        |
| `call:unavailable`              | S → C     | Callee offline                 |

---

## 🗄️ Business Rules (Quick Reference)

**Private Chat**

- Exactly one other member, `isGroup: false`
- Duplicate private conversations are prevented

**Group Chat**

- Requires a name, creator becomes `admin`
- Only admins can add/remove members
- Members can leave; admin transfer supported

**Messages**

- Soft-deleted messages are masked (`"This message was deleted"`)
- Edited messages set `isEdited: true`

**Notifications**

- One notification per recipient per message
- Grouped at read-time (conversations with 4+ unread collapse)

**Calls**

- 1-1 audio or video via WebRTC
- Signaling over existing Socket.io connection
- TURN fallback via Metered.ca when direct P2P fails

---

## 🤝 Contributing

Contributions, bug reports, and suggestions are welcome — see [CONTRIBUTING.md](./Contributing.md).

## 🔒 Security

Found a vulnerability? Please see [SECURITY.md](./Security.md) rather than opening a public issue.

## 📄 License

Released under the [MIT License](./LICENSE).
