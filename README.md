# LeaseLedger Lite 🏢

A professional property management demo application showcasing Rent Roll and Accounts Receivable Aging reports - perfect for Yardi interview demonstrations.

## 🎯 Features

- **FastAPI Backend**: High-performance REST API with SQLite (default) or Oracle database support
- **Angular Frontend**: Modern, Apple-inspired UI with multiple analytics dashboards
- **Multi-Page Reports**: 
  - Dashboard with Rent Roll and A/R Aging
  - Tenant Management & Analysis
  - Financial Insights & Projections
  - Property Analytics & Performance
- **Data Caching**: Instant page navigation with intelligent caching
- **Production Ready**: Complete AWS EC2 deployment scripts included

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- Node.js 20+
- npm or yarn

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/leaseledger-lite.git
   cd leaseledger-lite
   ```

2. **Set up Python backend**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   pip install -r requirements.txt
   python -m uvicorn app.main:app --reload
   ```

3. **Set up Angular frontend** (in a new terminal)
   ```bash
   cd leaseledger-web
   npm install
   ng serve
   ```

4. **Access the application**
   - Frontend: http://localhost:4200
   - API: http://localhost:8000
   - API Docs: http://localhost:8000/docs

## 📊 Project Structure

```
leaseledger-lite/
├── app/                    # FastAPI backend
│   ├── main.py            # Main API application
│   ├── schema.sql         # SQLite schema
│   ├── seed.sql           # Sample data
│   └── templates/       # HTML templates
├── leaseledger-web/       # Angular frontend
│   └── src/app/
│       ├── dashboard/     # Dashboard component
│       ├── tenant-management/  # Tenant analytics
│       ├── financial-analysis/ # Financial insights
│       └── property-analytics/ # Property metrics
├── db/oracle/             # Oracle database scripts
├── scripts/               # PowerShell helper scripts
├── deploy/                # AWS EC2 deployment scripts
└── requirements.txt       # Python dependencies
```

## 🗄️ Database Modes

### SQLite (Default)
Automatically creates and seeds the database on first run.

### Oracle Mode
1. Install Docker Desktop
2. Run setup script:
   ```powershell
   ./scripts/setup-oracle.ps1
   ```
3. Set environment variable: `DB_DRIVER=oracle`

## 🐳 Docker

```bash
# Build image
docker build -t leaseledger-lite .

# Run container
docker run -p 8000:8000 leaseledger-lite

# With docker-compose (Oracle mode)
docker-compose up
```

## ☁️ AWS EC2 Deployment

### Quick Deploy

1. **Launch EC2 Instance**
   - Ubuntu 22.04 LTS
   - t3.small or larger (2GB+ RAM)
   - Security Group: SSH (22), HTTP (80)

2. **Deploy**
   ```bash
   # Upload files
   scp -r -i your-key.pem . ubuntu@YOUR_EC2_IP:/opt/leaseledger
   
   # SSH and deploy
   ssh -i your-key.pem ubuntu@YOUR_EC2_IP
   cd /opt/leaseledger
   chmod +x deploy/*.sh
   ./deploy/quick-deploy.sh
   ```

3. **Access**
   ```
   http://YOUR_EC2_PUBLIC_IP
   ```

See [deploy/AWS_DEPLOYMENT.md](deploy/AWS_DEPLOYMENT.md) for detailed instructions.

## 📡 API Endpoints

### Core Endpoints
- `GET /health` - Health check
- `GET /rent-roll` - Rent roll report
- `GET /ar-aging` - A/R aging report

### Analytics Endpoints
- `GET /api/tenant-analysis` - Tenant insights
- `GET /api/financial-insights` - Financial metrics
- `GET /api/property-metrics` - Property analytics
- `GET /api/lease-details` - Detailed lease information

## 🛠️ Technology Stack

- **Backend**: FastAPI, Python 3.11, SQLite/Oracle
- **Frontend**: Angular 20, TypeScript, RxJS
- **Deployment**: Nginx, Systemd, Docker
- **CI/CD**: GitHub Actions (configured)

## 📝 Development

### Running Tests
```bash
# Backend tests (if available)
pytest

# Frontend tests
cd leaseledger-web
ng test
```

### Code Style
- Python: Follows PEP 8
- TypeScript: Uses Angular style guide

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is created for demonstration purposes.

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/yourprofile)

## 🙏 Acknowledgments

- Built for Yardi interview demonstration
- Inspired by modern property management systems
- Uses Apple's design philosophy for UI/UX

## 📞 Support

For questions or issues, please open an issue on GitHub.

---

⭐ If you find this project helpful, please consider giving it a star!
