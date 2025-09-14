# 🏔️ AvalancheDonate

A blockchain-powered charity donation platform built for the Avalanche Hackathon that intelligently matches users with causes they care about using AI and real-time news analysis.

**🏆 Built at Avalanche Hackathon**  
**📁 Repository:** [https://github.com/aadithyanr/avalanche-final](https://github.com/aadithyanr/avalanche-final)

## ✨ Features

- **Smart Donation Matching**: AI-powered system that matches users with charities based on their interests and current events
- **Avalanche Blockchain Integration**: Secure, transparent donations using Avalanche network and smart contracts
- **Real-time News Analysis**: Automatically processes news feeds to identify relevant causes
- **Cross-platform App**: Flutter app supporting iOS, Android, and Web
- **Portfolio Tracking**: Visualize your donation impact and track your giving history

## 🏗️ Architecture

```
├── app/                    # Flutter mobile/web application
├── api/                    # FastAPI backend service
├── contracts/              # Solidity smart contracts
├── contract_wrapper_api/   # Web3 contract interaction service
├── rss_feed/              # News feed processing service
├── pg_module/             # Database models and operations
└── web3_utils/            # Blockchain utilities
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.1.5+)
- Python 3.8+
- Node.js 16+
- PostgreSQL
- Docker (optional)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aadithyanr/avalanche-final.git
   cd avalanche-final
   ```

2. **Set up the database**
   ```bash
   python setup_database.py
   ```

3. **Install dependencies**
   ```bash
   # Backend services
   pip install -r api/requirements.txt
   pip install -r contract_wrapper_api/requirements.txt
   pip install -r rss_feed/requirements.txt
   
   # Smart contracts
   cd contracts
   npm install
   
   # Flutter app
   cd ../app
   flutter pub get
   ```

4. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

5. **Start services**
   ```bash
   ./start_services.sh
   ```

6. **Run the Flutter app**
   ```bash
   cd app
   flutter run
   ```

## 🔧 Services

### Flutter App (`/app`)
- Cross-platform mobile and web application
- Web3 wallet integration
- Real-time donation tracking
- Beautiful, responsive UI

### API Service (`/api`)
- FastAPI backend
- User preferences management
- Charity data endpoints
- CORS-enabled for web access

### Smart Contracts (`/contracts`)
- Solidity contracts for donation management on Avalanche
- User preference storage on blockchain
- Automated charity distribution

### News Matcher (`/news_charity_matcher.py`)
- RSS feed processing
- AI-powered content analysis
- Charity matching algorithm

## 🛠️ Development

### Running Individual Services

```bash
# API Service
cd api && python main.py

# Contract Wrapper
cd contract_wrapper_api && python main.py

# RSS Feed Processor
cd rss_feed && python rss_script.py

# Flutter App
cd app && flutter run
```

### Database Setup

```bash
python setup_database.py
```

## 🎥 Demo Video

Watch AvalancheDonate in action:

[![AvalancheDonate Demo](https://img.youtube.com/vi/zfhLeEJcJu0/maxresdefault.jpg)](https://youtu.be/zfhLeEJcJu0)

**[▶️ Watch Demo on YouTube](https://youtu.be/zfhLeEJcJu0)**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Avalanche Foundation** for the hackathon platform and blockchain infrastructure
- **OpenAI** for AI capabilities
- **Flutter team** for the amazing framework
- **OpenZeppelin** for smart contract libraries
- **The open-source community**

---

**🏔️ Built at Avalanche Hackathon with ❤️ for making the world a better place**
