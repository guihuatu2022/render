# Green Earth Blog

A sustainable living blog platform built with modern web technologies.

## About

Green Earth Blog is a personal blogging platform focused on environmental conservation, sustainable living, and eco-friendly practices. The blog features articles on:

- Ocean cleanup initiatives
- Zero waste kitchen practices
- Sustainable transportation
- Urban gardening
- Renewable energy at home
- Pollinator-friendly gardening

## Features

- 📱 Responsive design that works on all devices
- 🎨 Beautiful eco-themed interface with green color palette
- 📝 Full-featured blog with detailed articles
- 🔍 Easy navigation between home, blog, about, and contact pages
- ♻️ Optimized for performance and minimal resource usage

## Tech Stack

- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **Web Server**: Nginx
- **Deployment**: Docker containerized application
- **CI/CD**: GitHub Actions for automated builds

## Deployment

### Using Docker

The application is containerized and can be deployed to any Docker-compatible platform:

1. Build the Docker image:
   ```bash
   docker build -t green-earth-blog .
   ```

2. Run the container:
   ```bash
   docker run -p 80:80 green-earth-blog
   ```

### Deploying to Koyeb

Click the button below to deploy to Koyeb:

[![Deploy to Koyeb](https://www.koyeb.com/static/images/deploy/button.svg)](https://app.koyeb.com/deploy?type=docker&name=green-earth-blog&ports=80;http;/&image=ghcr.io/YOUR_USERNAME/YOUR_REPO:latest)

**Configuration:**
- Port: `80`
- Protocol: `HTTP`
- Health check path: `/`

### Optional Monitoring

You can integrate monitoring agents by setting the following environment variables (optional):

| Variable | Description | Required |
|----------|-------------|----------|
| NEZHA_SERVER | Monitoring server domain or IP | No |
| NEZHA_PORT | Monitoring server port | No |
| NEZHA_KEY | Monitoring agent key | No |

## Local Development

To run locally for development:

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```

2. Open `index.html` in your browser or use a local server:
   ```bash
   python -m http.server 8000
   ```

3. Visit `http://localhost:8000`

## Project Structure

```
.
├── Dockerfile          # Docker configuration
├── nginx.conf          # Nginx server configuration
├── entrypoint.sh       # Container startup script
├── index.html          # Main blog application
└── README.md           # This file
```

## Contributing

This is a personal blog project, but suggestions and feedback are welcome! Feel free to open an issue if you find any bugs or have ideas for improvements.

## License

This project is open source and available for educational purposes.

## Acknowledgments

Inspired by the global movement toward sustainable living and environmental consciousness.

---

**Live sustainably for a better tomorrow** 🌍💚
