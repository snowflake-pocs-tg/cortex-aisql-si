# Snowflake Intelligence Agent Configuration

## Purpose
This folder contains the configuration files needed to set up an AI agent that can answer questions about your banking data in natural language. Think of it as creating a knowledgeable assistant that understands your financial data.

## What's Inside

### Setup Scripts
- **01_SETUP.sql** - Initial configuration to prepare your environment
- **02_DDL.sql** - Creates the data structures the agent needs
- **03_DML.sql** - Loads initial data and configurations

### Agent Documentation (docs/ folder)
- **AGENT_DESCRIPTION.md** - The "personality" and capabilities you give to your AI assistant
- **AGENT_CONFIGURATION.md** - Technical settings that control how the agent works
- **AGENT_SIMPLE_CONFIG.md** - A simplified version for quick setup
- **TOOL_DESCRIPTIONS.md** - Defines special capabilities the agent can use

## What This Agent Can Do

### Answer Questions Like:
- "What are the most profitable banks in my state?"
- "Show me banks that might be acquisition targets"
- "Which institutions have strong capital positions?"
- "What's the trend in bank branch closures?"
- "Alert me to banks with rising risk indicators"

### Provide Analysis On:
- Financial performance metrics
- Market concentration and competition
- Risk indicators and compliance
- M&A opportunities
- Geographic expansion patterns

## How to Set Up the Agent

### Step 1: Run the SQL Scripts
Execute the three SQL files in order (01, 02, 03) in your Snowflake environment.

### Step 2: Configure the Agent
1. Open Snowflake Intelligence in your Snowflake interface
2. Create a new agent
3. Copy the content from AGENT_DESCRIPTION.md as the agent's description
4. Apply the configuration settings from AGENT_CONFIGURATION.md

### Step 3: Test the Agent
Try asking questions like:
- "Show me the top 5 banks by efficiency ratio"
- "What's the average ROA for banks in Texas?"
- "Which banks have increased their branch networks this year?"

## Customization Options

### Adjust the Agent's Focus
Edit AGENT_DESCRIPTION.md to emphasize different aspects:
- More focus on risk analysis
- Emphasis on growth opportunities
- Concentration on regulatory compliance

### Add Custom Tools
Modify TOOL_DESCRIPTIONS.md to give the agent new capabilities:
- Custom calculations
- Specific report formats
- Integration with other systems

### Simplify or Enhance
- Use AGENT_SIMPLE_CONFIG.md for a basic setup
- Use AGENT_CONFIGURATION.md for advanced features

## Best Practices

### For Business Users
- Ask clear, specific questions
- Start with simple queries and build complexity
- Use the terminology defined in the agent description

### For Administrators
- Test the agent with sample questions before deployment
- Monitor usage to understand what users are asking
- Refine the configuration based on user needs

## Maintenance
The agent configuration should be reviewed quarterly to:
- Add new metrics as they become available
- Adjust for changes in business priorities
- Incorporate user feedback and common questions

## Support
If the agent doesn't understand a question:
- Try rephrasing using terms from the agent description
- Check that the underlying data is available
- Verify the semantic views are properly created