# AutoMaxKB 
AI-Powered Automated Shipping Coordination Platform</h3>

## Overview

MaxKB = Max Knowledge Brain, it is a powerful AI assistant that integrates Retrieval-Augmented Generation (RAG) pipelines,

AutoMaxKB = Powerful AI-driven shipping coordination platform that seamlessly integrates with communication and CRM tools to automate shipping workflows. Built as a fork of the [MaxKB](https://github.com/1Panel-dev/MaxKB) project, AutoMaxKB transforms MaxKB's RAG capabilities into a specialized solution for shipping and logistics management.

## Key Features

- **Multi-Platform Integration**: Connect with Dialpad (voice/calls), Slack (team messaging), and BatsCRM (customer management) to create a unified shipping coordination experience.

- **Intelligent Shipping Management**: Leverage RAG (Retrieval-Augmented Generation) and LLMs to automate shipping status updates, quote generation, and logistics coordination.

- **Automated Workflow Engine**: Handle the entire shipping process from inquiry to delivery with predefined and customizable workflows.

- **Contextual Understanding**: Process natural language queries about shipping statuses, create new shipments, and update existing ones across all integrated platforms.

- **Shipping Knowledge Base**: Built-in shipping terminology, carrier information, and logistics best practices to provide accurate responses.

## Integration Capabilities

### Dialpad Integration

- Process call transcripts for shipping inquiries
- Automatically extract shipping information from voice conversations
- Send shipping updates and tracking information via SMS or call

### Slack Integration

- Respond to shipping inquiries in channels or direct messages
- Provide shipping status updates with rich formatting
- Create shipping requests directly from Slack conversations

### BatsCRM Integration 

- Sync customer shipping information between systems
- Automatically update customer records with shipping statuses
- Generate shipping documentation directly from customer information

## Quick Start

Execute the script below to start an AutoMaxKB container using Docker:

```bash
docker run -d --name=automaxkb --restart=always \
  -p 8080:8080 \
  -v ~/.automaxkb:/var/lib/postgresql/data \
  -v ~/.python-packages:/opt/maxkb/app/sandbox/python-packages \
  -e DIALPAD_API_KEY=your_dialpad_api_key \
  -e SLACK_BOT_TOKEN=your_slack_bot_token \
  -e BATSCRM_API_KEY=your_batscrm_api_key \
  yourdockerhub/automaxkb
```

Alternatively, use Docker Compose:

```bash
# Clone the repository
git clone https://github.com/yourusername/automaxkb.git
cd automaxkb

# Create .env file with your API keys
cp .env.example .env
# Edit the .env file with your API credentials

# Start the containers
docker compose up -d
```

Access the AutoMaxKB web interface at `http://your_server_ip:8080` with default admin credentials:

- Username: admin
- Password: AutoMaxKB@123..

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DIALPAD_API_KEY` | Dialpad API authentication key | Yes, for Dialpad integration |
| `DIALPAD_WEBHOOK_URL` | URL for Dialpad webhook callbacks | Yes, for Dialpad integration |
| `DIALPAD_TEAM_ID` | Dialpad team identifier | Yes, for Dialpad integration |
| `SLACK_BOT_TOKEN` | Slack bot authentication token | Yes, for Slack integration |
| `SLACK_SIGNING_SECRET` | Secret for validating Slack requests | Yes, for Slack integration |
| `SLACK_APP_TOKEN` | Slack application token | Yes, for Slack integration |
| `BATSCRM_API_KEY` | BatsCRM API authentication key | Yes, for BatsCRM integration |
| `BATSCRM_BASE_URL` | Base URL for BatsCRM API | Yes, for BatsCRM integration |
| `BATSCRM_WEBHOOK_SECRET` | Secret for validating BatsCRM webhooks | Yes, for BatsCRM integration |

### Platform Setup

#### Dialpad Setup

1. Create a Dialpad API application at https://developers.dialpad.com/
2. Configure webhook URL to point to your AutoMaxKB instance: `https://your-domain.com/webhooks/dialpad/`
3. Enable necessary scopes for call transcripts and messaging

#### Slack Setup

1. Create a Slack App at https://api.slack.com/apps
2. Add Bot Token Scopes: `chat:write`, `im:history`, `channels:history`
3. Enable Event Subscriptions and point to webhook URL: `https://your-domain.com/webhooks/slack/`
4. Subscribe to events: `message.channels`, `message.im`

#### BatsCRM Setup

1. Generate API credentials in your BatsCRM admin portal
2. Configure webhook URL in BatsCRM: `https://your-domain.com/webhooks/batscrm/`
3. Enable necessary notification events for shipping-related activities

## Technical Architecture

AutoMaxKB enhances MaxKB's core architecture with specialized shipping coordination services:

- **Frontend**: Vue.js-based dashboard for configuration and monitoring
- **Backend**: Python/Django with custom integration services
- **LLM Framework**: LangChain with shipping-specific prompts and tools
- **Database**: PostgreSQL + pgvector for storing shipping data with semantic search
- **Integration Layer**: Custom webhook handlers and API clients for third-party services

## Development and Customization

### Adding New Shipping Carriers

```python
# Example for adding a new carrier integration
from apps.shipping.carriers.base import BaseCarrierService

class NewCarrierService(BaseCarrierService):
    def get_tracking_status(self, tracking_number):
        # Implementation for specific carrier API
        pass
        
    def generate_label(self, shipment_data):
        # Implementation for generating shipping labels
        pass
```

### Customizing Shipping Workflows

Workflows can be customized through the web interface or by editing workflow definition files:

```yaml
workflow:
  name: "Express Shipping Processing"
  triggers:
    - source: "slack"
      event: "message.express_shipping"
  steps:
    - name: "Validate Address"
      action: "shipping.validate_address"
    - name: "Generate Quote"
      action: "shipping.generate_quote"
    - name: "Create Shipment"
      action: "shipping.create_shipment"
    - name: "Notify Customer"
      action: "notifications.send_confirmation"
```

## Contributing

We welcome contributions to AutoMaxKB! To contribute:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add some amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## License

AutoMaxKB is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [MaxKB](https://github.com/1Panel-dev/MaxKB) project for the core RAG engine
- [LangChain](https://www.langchain.com/) for LLM orchestration
- Community contributors and testers
