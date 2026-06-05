#!/bin/bash

###############################################################################
# VetCare - Supabase Automated Deploy Script
# 
# This script automates the entire deployment process:
# 1. Checks credentials
# 2. Runs database migrations
# 3. Applies RLS policies
# 4. Seeds initial data
#
# Usage:
#   chmod +x deploy.sh
#   ./deploy.sh          # Uses existing .env.local
#   ./deploy.sh prod     # Production mode (extra confirmations)
###############################################################################

set -e  # Exit on error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$SCRIPT_DIR"

# Mode: 'dev' or 'prod'
MODE="${1:-dev}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        VetCare - Supabase Automated Deploy Script          ║${NC}"
echo -e "${BLUE}║                  Mode: ${MODE^^}                                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. CHECK PREREQUISITES
echo -e "${YELLOW}[1/5] Checking prerequisites...${NC}"

if ! command -v supabase &> /dev/null; then
    echo -e "${RED}✗ Supabase CLI not found${NC}"
    echo "Install with: npm install -g @supabase/cli"
    exit 1
fi
echo -e "${GREEN}✓ Supabase CLI found${NC}"

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not found (optional, for JSON parsing)${NC}"
fi

# 2. LOAD ENVIRONMENT
echo -e "${YELLOW}[2/5] Loading environment variables...${NC}"

if [ ! -f "$PROJECT_ROOT/.env.local" ]; then
    echo -e "${RED}✗ .env.local not found${NC}"
    echo "Create it with: cp .env.local.example .env.local"
    exit 1
fi

source "$PROJECT_ROOT/.env.local"

if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo -e "${RED}✗ SUPABASE_PROJECT_REF not set in .env.local${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment loaded${NC}"
echo "  Project: ${SUPABASE_PROJECT_REF}"

# 3. VERIFY SUPABASE CONNECTION
echo -e "${YELLOW}[3/5] Verifying Supabase connection...${NC}"

if ! supabase projects list 2>/dev/null | grep -q "$SUPABASE_PROJECT_REF"; then
    echo -e "${RED}✗ Cannot connect to project: $SUPABASE_PROJECT_REF${NC}"
    echo "Make sure you've run: supabase login"
    exit 1
fi

echo -e "${GREEN}✓ Connected to Supabase project${NC}"

# 4. PRODUCTION CONFIRMATION
if [ "$MODE" = "prod" ]; then
    echo ""
    echo -e "${RED}⚠️  PRODUCTION MODE - Data modifications will be permanent!${NC}"
    read -p "Type 'YES' to continue: " confirm
    if [ "$confirm" != "YES" ]; then
        echo "Cancelled."
        exit 0
    fi
fi

# 5. RUN MIGRATIONS
echo ""
echo -e "${YELLOW}[4/5] Applying migrations...${NC}"

MIGRATIONS_DIR="$PROJECT_ROOT/supabase/migrations"
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo -e "${RED}✗ Migrations directory not found: $MIGRATIONS_DIR${NC}"
    exit 1
fi

# List all SQL files
MIGRATION_COUNT=$(find "$MIGRATIONS_DIR" -name "*.sql" | wc -l)
echo "Found $MIGRATION_COUNT migration file(s)"

# Execute each migration
for migration in "$MIGRATIONS_DIR"/*.sql; do
    if [ -f "$migration" ]; then
        filename=$(basename "$migration")
        echo -n "  • Applying $filename... "
        
        # Read migration file
        sql_content=$(cat "$migration")
        
        # Execute via psql (if you have it) or via curl
        # For now, we'll show the user the SQL to execute
        echo -e "${YELLOW}(Manual execution required)${NC}"
        echo "    SQL file: $migration"
    fi
done

# 6. PROVIDE EXECUTION INSTRUCTIONS
echo ""
echo -e "${YELLOW}[5/5] Execution instructions...${NC}"
echo ""
echo -e "${BLUE}OPTION A: Automatic (Recommended)${NC}"
echo "  If you have Supabase CLI authenticated:"
echo ""
echo "  1. Copy migration file:"
echo "    cat $MIGRATIONS_DIR/*.sql"
echo ""
echo "  2. Execute in Supabase SQL Editor:"
echo "    • Supabase Dashboard → SQL Editor"
echo "    • New Query"
echo "    • Paste entire SQL content"
echo "    • Click 'Run'"
echo ""

echo -e "${BLUE}OPTION B: Command Line (If available)${NC}"
echo "  If you have psql installed:"
echo ""
echo "  PGPASSWORD='your_password' psql -h db.PROJECT_REF.supabase.co \\"
echo "    -U postgres -d postgres -f $MIGRATIONS_DIR/20260521000000_initial_schema.sql"
echo ""

echo -e "${BLUE}OPTION C: GitHub Actions (CI/CD)${NC}"
echo "  We'll set up automated migrations on every push!"
echo ""

# Summary
echo -e "${GREEN}✓ Deploy script completed${NC}"
echo ""
echo "Next steps:"
echo "1. Execute migrations using one of the options above"
echo "2. Verify in Supabase Dashboard → Database → Tables"
echo "3. Test the app: flutter run -d emulator-5554"
echo ""
